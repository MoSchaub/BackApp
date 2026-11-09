// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing
@testable import BakingRecipeFoundation

/// Tests for `ScheduleCalculator` on plain step trees, without a database.
@Suite("Schedule calculator")
struct ScheduleCalculatorTests {

    let date = Date(timeIntervalSince1970: 1_700_000_000)

    /// the offset of each step's start from `reference`, keyed by step id
    func startOffsets(_ schedule: Schedule, from reference: Date) -> [Int64: TimeInterval] {
        schedule.entries.mapValues { $0.start.timeIntervalSince(reference) }
    }

    @Test("A recipe without steps starts and ends at the date", arguments: [false, true])
    func emptyRecipe(inverted: Bool) {
        let schedule = ScheduleCalculator.schedule(for: [], date: date, inverted: inverted)
        #expect(schedule.startDate == date)
        #expect(schedule.endDate == date)
        #expect(schedule.entries.isEmpty)
    }

    @Test("Top-level steps follow one another")
    func sequentialSteps() {
        let steps = [
            ScheduleNode(stepId: 1, duration: 600),
            ScheduleNode(stepId: 2, duration: 1200),
            ScheduleNode(stepId: 3, duration: 60),
        ]
        let schedule = ScheduleCalculator.schedule(for: steps, date: date, inverted: false)

        #expect(schedule.startDate == date)
        #expect(schedule.endDate == date + 1860)
        #expect(startOffsets(schedule, from: date) == [1: 0, 2: 600, 3: 1800])
        #expect(schedule.entries[2]?.end == date + 1800)
    }

    @Test("An inverted schedule ends at the date")
    func invertedSchedule() {
        let steps = [
            ScheduleNode(stepId: 1, duration: 600),
            ScheduleNode(stepId: 2, duration: 1200),
        ]
        let schedule = ScheduleCalculator.schedule(for: steps, date: date, inverted: true)

        #expect(schedule.startDate == date - 1800)
        #expect(schedule.endDate == date)
        #expect(startOffsets(schedule, from: date) == [1: -1800, 2: -1200])
    }

    @Test("Parallel substeps all end when their step starts")
    func parallelSubsteps() {
        let steps = [
            ScheduleNode(stepId: 1, duration: 600, substeps: [
                ScheduleNode(stepId: 2, duration: 1200),
                ScheduleNode(stepId: 3, duration: 300),
            ]),
            ScheduleNode(stepId: 4, duration: 60),
        ]
        #expect(steps[0].durationWithSubsteps == 1800)

        let schedule = ScheduleCalculator.schedule(for: steps, date: date, inverted: false)

        // the long substep starts first, the short one so both end at +1200 s
        #expect(startOffsets(schedule, from: date) == [2: 0, 3: 900, 1: 1200, 4: 1800])
        #expect(schedule.entries[2]?.end == schedule.entries[1]?.start)
        #expect(schedule.entries[3]?.end == schedule.entries[1]?.start)
        #expect(schedule.endDate == date + 1860)
    }

    @Test("Nested substeps follow the longest chain, not the longest direct substep")
    func nestedSubsteps() {
        // the same tree as `Recipe.multilayerSubstepExample`
        let steps = [
            ScheduleNode(stepId: 1, duration: 60, substeps: [
                ScheduleNode(stepId: 2, duration: 900, substeps: [
                    ScheduleNode(stepId: 3, duration: 1200),
                ]),
                ScheduleNode(stepId: 4, duration: 600, substeps: [
                    ScheduleNode(stepId: 5, duration: 1800, substeps: [
                        ScheduleNode(stepId: 6, duration: 400),
                    ]),
                ]),
            ]),
            ScheduleNode(stepId: 7, duration: 390),
        ]
        #expect(steps[0].durationWithSubsteps == 60 + 2800)

        let schedule = ScheduleCalculator.schedule(for: steps, date: date, inverted: false)

        #expect(startOffsets(schedule, from: date) == [
            6: 0, 5: 400, 4: 2200,
            3: 700, 2: 1900,
            1: 2800, 7: 2860,
        ])
        #expect(schedule.endDate == date + 3250)
    }

    @Test("An inverted schedule ends exactly at the date, even for durations that aren't whole minutes")
    func invertedWithSeconds() {
        let steps = [
            ScheduleNode(stepId: 1, duration: 90, substeps: [ScheduleNode(stepId: 2, duration: 45)]),
            ScheduleNode(stepId: 3, duration: 100),
        ]
        let schedule = ScheduleCalculator.schedule(for: steps, date: date, inverted: true)

        #expect(schedule.startDate == date - 235)
        #expect(schedule.entries[2]?.start == schedule.startDate)
        #expect(schedule.entries[3]?.end == date)
        #expect(schedule.endDate == date)
    }

    @Test("Steps that aren't in the schedule have no start date")
    func unknownStep() {
        let schedule = ScheduleCalculator.schedule(for: [ScheduleNode(stepId: 1, duration: 60)], date: date, inverted: false)
        #expect(schedule.startDate(ofStepWithId: 1) == date)
        #expect(schedule.startDate(ofStepWithId: 2) == nil)
    }
}
