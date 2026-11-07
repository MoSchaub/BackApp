// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing
@testable import BakingRecipeFoundation
import BakingRecipeStrings

@Suite("Duration formatting")
struct DurationFormattingTests {

    @Test("Minutes are split into hours and minutes", arguments: [
        (0, 0, 0), (59, 0, 59), (60, 1, 0), (61, 1, 1), (125, 2, 5), (1440, 24, 0),
    ])
    func hoursAndMinutes(total: Int, hours: Int, minutes: Int) {
        #expect(total.hours == hours)
        #expect(total.minutes == minutes)
    }

    @Test("formattedDuration", arguments: [
        (0, "0 \(Strings.minutes)"),
        (1, "\(Strings.one) \(Strings.minute)"),
        (2, "2 \(Strings.minutes)"),
        (59, "59 \(Strings.minutes)"),
        (60, "\(Strings.one) \(Strings.hour)"),
        (61, "\(Strings.one) \(Strings.hour) \(Strings.one) \(Strings.minute)"),
        (66, "\(Strings.one) \(Strings.hour) 6 \(Strings.minutes)"),
        (120, "2 \(Strings.hours)"),
        (121, "2 \(Strings.hours) \(Strings.one) \(Strings.minute)"),
        (126, "2 \(Strings.hours) 6 \(Strings.minutes)"),
    ])
    func formattedDuration(minutes: Int, expected: String) {
        #expect(minutes.formattedDuration == expected)
    }

    @Test("formattedDurationHours drops the minutes", arguments: [
        (30, "0 \(Strings.hours)"),
        (60, "\(Strings.one) \(Strings.hour)"),
        (119, "\(Strings.one) \(Strings.hour)"),
        (150, "2 \(Strings.hours)"),
    ])
    func formattedDurationHours(minutes: Int, expected: String) {
        #expect(minutes.formattedDurationHours == expected)
    }

    @Test("Up to an hour, compactForamttedDuration matches formattedDuration", arguments: [0, 1, 2, 45, 60])
    func compactDurationUpToAnHour(minutes: Int) {
        #expect(minutes.compactForamttedDuration == minutes.formattedDuration)
    }

    @Test("Above an hour, compactForamttedDuration shows fractional hours", arguments: [
        (61, "1", "02"), (66, "1", "1"), (90, "1", "5"), (126, "2", "1"),
    ])
    func compactDurationAboveAnHour(minutes: Int, whole: String, fraction: String) {
        // NumberFormatter uses the current locale, so build the expectation with its separator.
        let separator = Locale.current.decimalSeparator ?? "."
        #expect(minutes.compactForamttedDuration == "\(whole)\(separator)\(fraction) \(Strings.hours)")
    }

    @Test("Whole hours above an hour have no fraction")
    func compactDurationWholeHours() {
        #expect(180.compactForamttedDuration == "3 \(Strings.hours)")
    }

    @Test("Step.formattedDuration converts seconds and truncates to whole minutes", arguments: [
        (0.0, 0), (41.0, 0), (60.0, 1), (130.0, 2), (3600.0, 60), (3660.0, 61), (4000.0, 66), (7560.0, 126),
    ])
    func stepFormattedDuration(seconds: TimeInterval, minutes: Int) {
        var step = Step(recipeId: 0, number: 0)
        step.duration = seconds
        #expect(step.formattedDuration == minutes.formattedDuration)
    }
}

@Suite("Mass formatting")
struct MassFormattingTests {

    @Test("formattedMass always shows one fraction digit and grams", arguments: [
        (0.0, "0.0 g"), (5.0, "5.0 g"), (12.34, "12.3 g"), (12.36, "12.4 g"), (1234.5678, "1234.6 g"), (-5.0, "-5.0 g"),
    ])
    func formattedMass(mass: Double, expected: String) {
        #expect(mass.formattedMass == expected)
    }

    @Test("Ingredient amounts are formatted and scaled")
    func ingredientAmounts() {
        let ingredient = Ingredient(stepId: 0, name: "Mehl", amount: 250, type: .flour, number: 0)
        #expect(ingredient.formattedAmount == "250.0 g")
        #expect(ingredient.scaledFormattedAmount(with: 1.5) == "375.0 g")
        #expect(ingredient.scaledFormattedAmount(with: 0) == "0.0 g")
        #expect(Ingredient.scaledFormattedAmount(10, with: 0.25) == "2.5 g")
    }
}

/// Temperature formatting reads the global `MeasurementFormatting.localeOverride`,
/// so these tests must not run in parallel with each other.
@Suite("Temperature formatting", .serialized)
struct TemperatureFormattingTests {

    /// Runs `body` with `MeasurementFormatting.localeOverride` set and restores it afterwards.
    private func withLocale(_ identifier: String, _ body: () throws -> Void) rethrows {
        let previous = MeasurementFormatting.localeOverride
        MeasurementFormatting.localeOverride = Locale(identifier: identifier)
        defer { MeasurementFormatting.localeOverride = previous }
        try body()
    }

    @Test("Celsius values are shown in the locale's unit", arguments: [
        ("en_US", 20.0, "68°F", "68"),
        ("en_US", 20434.16746454, "36813.5°F", "36813.5"),
        ("de_DE", 20.0, "20 °C", "20"),
        ("de_DE", 20434.16746454, "20434,2 °C", "20434,2"),
    ])
    func temperature(locale: String, celsius: Double, formatted: String, value: String) {
        withLocale(locale) {
            let measurement = Measurement(value: celsius, unit: UnitTemperature.celsius)
            #expect(measurement.formatted == formatted)
            #expect(measurement.localizedValue == value)
        }
    }

    @Test("formattedTemp falls back to the room temperature")
    func formattedTemp() {
        var step = Step(recipeId: 0, number: 0)
        withLocale("de_DE") {
            step.temperature = nil
            #expect(step.formattedTemp(roomTemp: 21) == "21 °C")

            step.temperature = 20
            #expect(step.formattedTemp(roomTemp: 21) == "20 °C")
        }
        withLocale("en_US") {
            step.temperature = nil
            #expect(step.formattedTemp(roomTemp: 21) == "69.8°F")

            step.temperature = 20
            #expect(step.formattedTemp(roomTemp: 21) == "68°F")
        }
    }

    @Test("formattedEndTemp uses the end temperature only when it is enabled")
    func formattedEndTemp() {
        var step = Step(temperature: 25, recipeId: 0, number: 0)
        withLocale("de_DE") {
            step.endTempEnabled = false
            #expect(step.formattedEndTemp(roomTemp: 21) == step.formattedTemp(roomTemp: 21))
            #expect(step.formattedEndTemp == nil)

            step.endTemp = 30
            #expect(step.formattedEndTemp(roomTemp: 21) == "30 °C")
            #expect(step.formattedEndTemp == "30 °C")
        }
        withLocale("en_US") {
            #expect(step.formattedEndTemp(roomTemp: 21) == "86°F")
            #expect(step.formattedEndTemp == "86°F")
        }
    }
}
