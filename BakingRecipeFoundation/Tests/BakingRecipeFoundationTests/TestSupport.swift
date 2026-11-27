// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import GRDB
@testable import BakingRecipeFoundation

/// The language `Bundle.main` resolves to. Ingredient type detection, dough yield and
/// `timesTextWithIndivialMass` branch on it, so tests for those branches are gated on it.
let mainBundleLanguage = Bundle.main.preferredLocalizations.first

/// An in-memory database with the same schema the app creates in `BackAppData`'s migrations
/// (`migration`, `v2`, `v3`), so model queries can be tested without the app layer.
func makeDatabase() throws -> DatabaseQueue {
    let dbQueue = try DatabaseQueue()
    try dbQueue.write { db in
        try db.create(table: "Recipe") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("name", .text).notNull().defaults(to: "")
            t.column("info", .text).notNull().defaults(to: "")
            t.column("isFavorite", .boolean).notNull().defaults(to: false)
            t.column("difficulty", .integer).notNull().defaults(to: 0)
            t.column("inverted", .boolean).notNull().defaults(to: false)
            t.column("times", .real)
            t.column("date", .datetime).notNull().defaults(to: Date())
            t.column("imageData", .blob)
            t.column("number", .integer).notNull()
        }
        try db.create(table: "Step") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("name", .text).notNull().defaults(to: "")
            t.column("duration", .double).notNull().defaults(to: 60)
            t.column("temperature", .double)
            t.column("notes", .text).notNull().defaults(to: "")
            t.column("recipeId", .integer).references("Recipe", onDelete: .cascade)
            t.column("superStepId", .integer).references("Step")
            t.column("number", .integer).notNull()
            t.column("isKneadingStep", .boolean).notNull().defaults(to: false)
            t.column("endTemp", .double)
        }
        try db.create(table: "Ingredient") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("name", .text).notNull().defaults(to: "")
            t.column("temperature", .double)
            t.column("mass", .double).notNull().defaults(to: 0)
            t.column("c", .double)
            t.column("stepId", .integer).references("Step", onDelete: .cascade)
            t.column("number", .integer).notNull()
        }
    }
    return dbQueue
}

// MARK: - Record builders

@discardableResult
func insertRecipe(_ db: Database, name: String = "Recipe", number: Int = 0, configure: (inout Recipe) -> Void = { _ in }) throws -> Recipe {
    var recipe = Recipe(name: name, number: number)
    configure(&recipe)
    try recipe.insert(db)
    return recipe
}

@discardableResult
func insertStep(
    _ db: Database,
    in recipe: Recipe,
    name: String,
    duration: TimeInterval = 60,
    temperature: Double? = nil,
    superStep: Step? = nil,
    number: Int = 0,
    configure: (inout Step) -> Void = { _ in }
) throws -> Step {
    var step = Step(name: name, duration: duration, temperature: temperature, recipeId: recipe.id!, number: number)
    step.superStepId = superStep?.id
    configure(&step)
    try step.insert(db)
    return step
}

@discardableResult
func insertIngredient(
    _ db: Database,
    in step: Step,
    name: String,
    mass: Double,
    type: Ingredient.Style = .other,
    temperature: Double? = nil,
    number: Int = 0
) throws -> Ingredient {
    var ingredient = Ingredient(stepId: step.id!, name: name, amount: mass, type: type, number: number)
    ingredient.temperature = temperature
    try ingredient.insert(db)
    return ingredient
}

/// Inserts `Recipe.multilayerSubstepExample` with real ids instead of the hard-coded ones:
///
///     Schritt (60 s)
///     ├── s1sub1 (900 s)
///     │   └── s1sub1sub (1200 s)
///     └── s1sub2 (600 s)
///         └── s1sub2sub (1800 s)
///             └── s1sub2subsub (400 s)
///     s2 (390 s)
func insertMultilayerRecipe(
    _ db: Database,
    configure: (inout Recipe) -> Void = { _ in }
) throws -> (recipe: Recipe, steps: [String: Step]) {
    let recipe = try insertRecipe(db, name: "multilayer", configure: configure)
    var steps = [String: Step]()
    steps["Schritt"] = try insertStep(db, in: recipe, name: "Schritt", duration: 60, number: 1)
    steps["s1sub1"] = try insertStep(db, in: recipe, name: "s1sub1", duration: 900, superStep: steps["Schritt"], number: 2)
    steps["s1sub1sub"] = try insertStep(db, in: recipe, name: "s1sub1sub", duration: 1200, superStep: steps["s1sub1"], number: 3)
    steps["s1sub2"] = try insertStep(db, in: recipe, name: "s1sub2", duration: 600, superStep: steps["Schritt"], number: 4)
    steps["s1sub2sub"] = try insertStep(db, in: recipe, name: "s1sub2sub", duration: 1800, superStep: steps["s1sub2"], number: 5)
    steps["s1sub2subsub"] = try insertStep(db, in: recipe, name: "s1sub2subsub", duration: 400, superStep: steps["s1sub2sub"], number: 6)
    steps["s2"] = try insertStep(db, in: recipe, name: "s2", duration: 390, number: 7)
    return (recipe, steps)
}
