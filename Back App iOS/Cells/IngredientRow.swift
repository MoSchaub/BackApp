// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import BakingRecipeFoundation
import BackAppCore

extension Ingredient {

    func stackView(scaleFactor: Double?, tempText: String, even: Bool) -> UIView {
        Ingredient.stackView(scaleFactor: scaleFactor, tempText: tempText, even: even, type: self.type, formattedName: self.formattedName, amount: self.mass)
    }

    static func stackView(scaleFactor: Double?, tempText: String, even: Bool, type: Ingredient.Style, formattedName: String, amount: Double) -> UIView {
        return stepSubRow(formattedName: formattedName, tempText: type == .bulkLiquid ? tempText : nil, amountText: Ingredient.scaledFormattedAmount(amount, with: scaleFactor ?? 1), even: even)
    }

    func tempText(in step: Step) -> String {
        if let temp = try? step.bulkLiquidTemperature(roomTemp: Standarts.roomTemp, kneadingHeating: Standarts.kneadingHeating, databaseReader: BackAppData.shared.databaseReader) {
            return Measurement(value: temp, unit: .celsius).formatted
        } else {
            print("Error getting the temp for the ingredient with name: \(self.formattedName)")
            return "error"
        }
    }
}
