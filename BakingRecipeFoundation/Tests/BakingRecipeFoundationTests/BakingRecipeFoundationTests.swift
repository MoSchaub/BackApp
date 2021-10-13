import XCTest
@testable import BakingRecipeFoundation
@testable import GRDB

final class BakingRecipeFoundationTests: XCTestCase {

    func test_TempMeasurementFormatter() {
        var measurement = Measurement(value: 20434.16746454, unit: UnitTemperature.celsius)
        XCTAssertEqual(measurement.formatted, "20434.2°C")
        XCTAssertEqual(measurement.localizedValue, "20434.2")

        measurement = Measurement(value: 20.0, unit: UnitTemperature.celsius)
        XCTAssertEqual(measurement.formatted, "20°C")
        XCTAssertEqual(measurement.localizedValue, "20")
    }

    func test_formattedEndTemp() {
        let recipeExample = Recipe.example
        var step = recipeExample.stepIngredients.first!.step
        step.endTempEnabled = false
        XCTAssertEqual(step.formattedEndTemp(roomTemp: 21), step.formattedTemp(roomTemp: 21))
        XCTAssertEqual(step.formattedEndTemp, nil)

        step.endTempEnabled = true
        XCTAssertEqual(step.formattedEndTemp(roomTemp: 21), "20°C")
        XCTAssertEqual(step.formattedEndTemp, "20°C")
    }

    func test_formattedTemp() {
        let recipeExample = Recipe.example
        var step = recipeExample.stepIngredients.first!.step

        step.temperature = nil
        XCTAssertEqual(step.formattedTemp(roomTemp: 21), "21°C")

        step.temperature = 20
        XCTAssertEqual(step.formattedTemp(roomTemp: 21), "20°C")
    }

    static var allTests = [
        ("test_TempMeasurementFormatter", test_TempMeasurementFormatter)
    ]
}
