// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

/// A step as the schedule sees it: its own duration and its substeps.
///
/// This is a plain value without database access, so schedules can be calculated and tested
/// without a database. `Recipe.scheduleNodes(db:)` builds the tree for a recipe.
public struct ScheduleNode: Equatable, Sendable {

    /// id of the step this node stands for
    public let stepId: Int64

    /// how long the step itself takes, in seconds
    public let duration: TimeInterval

    /// the substeps of the step. They run in parallel and all end when the step starts.
    public let substeps: [ScheduleNode]

    /// the duration of this step plus its longest substep chain
    public let durationWithSubsteps: TimeInterval

    public init(stepId: Int64, duration: TimeInterval, substeps: [ScheduleNode] = []) {
        self.stepId = stepId
        self.duration = duration
        self.substeps = substeps
        self.durationWithSubsteps = duration + (substeps.map(\.durationWithSubsteps).max() ?? 0)
    }

    /// how long before this step its longest substep chain starts
    var longestSubstepChain: TimeInterval {
        durationWithSubsteps - duration
    }
}

/// When each step of a recipe starts and ends.
public struct Schedule: Equatable, Sendable {

    /// start and duration of one step
    public struct Entry: Equatable, Sendable {
        public let start: Date
        public let duration: TimeInterval

        public var end: Date {
            start.addingTimeInterval(duration)
        }
    }

    /// when the first step starts
    public let startDate: Date

    /// when the last step ends, so the recipe is done
    public let endDate: Date

    /// the start and duration of every step, keyed by step id
    public let entries: [Int64: Entry]

    /// when the step with the given id starts, or nil if it isn't part of the schedule
    public func startDate(ofStepWithId stepId: Int64) -> Date? {
        entries[stepId]?.start
    }
}

/// Works out when each step of a recipe starts.
///
/// The top-level steps run one after another. The substeps of a step run in parallel and all end
/// when that step starts, so its longest substep chain starts first.
public enum ScheduleCalculator {

    /// - Parameters:
    ///   - steps: the top-level steps of the recipe in the order they are done
    ///   - date: the start date, or the end date if `inverted` is true
    ///   - inverted: whether `date` is when the recipe should be done rather than when it starts
    public static func schedule(for steps: [ScheduleNode], date: Date, inverted: Bool) -> Schedule {
        let totalDuration = steps.reduce(0) { $0 + $1.durationWithSubsteps }
        let startDate = inverted ? date.addingTimeInterval(-totalDuration) : date

        var entries = [Int64: Schedule.Entry]()
        var chainStart = startDate
        for step in steps {
            let stepStart = place(step, chainStart: chainStart, into: &entries)
            chainStart = stepStart.addingTimeInterval(step.duration)
        }

        return Schedule(startDate: startDate, endDate: chainStart, entries: entries)
    }

    /// Adds `node` and its substeps to `entries`.
    /// - Parameter chainStart: when the longest substep chain of `node` starts
    /// - Returns: when `node` itself starts, which is when all its substep chains have ended
    private static func place(_ node: ScheduleNode, chainStart: Date, into entries: inout [Int64: Schedule.Entry]) -> Date {
        let stepStart = chainStart.addingTimeInterval(node.longestSubstepChain)
        for substep in node.substeps {
            _ = place(substep, chainStart: stepStart.addingTimeInterval(-substep.durationWithSubsteps), into: &entries)
        }
        entries[node.stepId] = Schedule.Entry(start: stepStart, duration: node.duration)
        return stepStart
    }
}
