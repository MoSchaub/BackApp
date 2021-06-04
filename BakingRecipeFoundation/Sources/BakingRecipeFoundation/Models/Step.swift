//
//  Step.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import Foundation
import BakingRecipeStrings
import GRDB

public struct Step: BakingRecipeRecord {
    
    /// unique id of the step
    ///optional so that you can instantiate a record before it gets inserted and gains an id (by `didInsert(with:for:)`)
    public var id: Int64?
    
    /// name of the step
    ///- NOTE: Should only be used to set not to get. Use formatted name instead
    public var name: String = ""
    
    /// how long the step takes
    public var duration: TimeInterval = 60
    
    /// what the temp of the step is
    ///- NOTE: This is only not nil if the temp is something different from the room temperature
    public var temperature: Double? = nil
    
    /// some notes you can attach
    public var notes: String = ""
    
    /// the id of the recipe the step is in
    public var recipeId: Int64
    
    /// the id of the superstep
    ///- NOTE: optional because a step can be without a superstep
    public var superStepId: Int64? = nil
    
    /// number of the step for sorting
    public var number: Int
    
    public init(name: String = "", duration: TimeInterval = 60, temperature: Double? = nil, notes: String = "", recipeId: Int64, number: Int) {
        self.name = name
        self.duration = duration
        self.temperature = temperature
        self.notes = notes
        self.recipeId = recipeId
        self.superStepId = nil
        self.number = number
    }
    
}

//MARK: - Formatted Properties
public extension Step {
    
    /// duration of the step formatted with the right unit
    var formattedDuration: String {
        Int(duration/60).formattedDuration
    }
    
    /// the temperature of the step formatted with Celsius
    func formattedTemp(roomTemp: Double) -> String{
        return String(format: "%.01f", self.temperature ?? roomTemp) + " °C"
    }
    
    /// name of the step
    ///- NOTE:should be used for displaying the name. For changing the name use name instead.
    var formattedName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? Strings.unnamedStep : name
    }
}

//MARK: - SQL

//MARK: SQL generation
public extension Step {
    /// define the table columns
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let duration = Column(CodingKeys.duration)
        static let temperature = Column(CodingKeys.temperature)
        static let notes = Column(CodingKeys.notes)
        static let recipeId = Column(CodingKeys.recipeId)
        static let superStepId = Column(CodingKeys.superStepId)
        static let number = Column(CodingKeys.number)
    }
    
    /// Arange the selected columns and lock their order
    static let databaseSelection: [SQLSelectable] = [
        Columns.id,
        Columns.name,
        Columns.duration,
        Columns.temperature,
        Columns.notes,
        Columns.recipeId,
        Columns.superStepId,
        Columns.number
    ]
}

//MARK: SQL Fetching
public extension Step {
    ///creates a record from a database row
    init(row: Row) {
        // For high performance, use numeric indexes that match the
        /// order of `Step.databaseSelection`
        id = row[0]
        name = row[1]
        duration = row[2]
        temperature = row[3]
        notes = row[4]
        recipeId = row[5]
        superStepId = row[6]
        number = row[7]
    }
}

//MARK: SQL Persistence methods
public extension Step {
    /// Update auto-increment id upon succesfull insertion
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

//TODO: cascade delete

///MARK: SQL Requests
extension DerivableRequest where RowDecoder == Step {
    // A request of steps with a recipeId ordered by number in ascending order.
    ///
    /// For example:
    ///
    ///     let steps: [Step] = try dbWriter.read { db in
    ///         try Step.all().orderedByNumber(with: 1).fetchAll(db)
    ///     }
    public func orderedByNumber(with recipeId: Int64) -> Self {
        filter(by: recipeId)
            .order(Step.Columns.number) // sort by number in ascending order (asc is the default)
        
    }
    
    public func orderedByDuration(with recipeId: Int64) -> Self {
        filter(by: recipeId)
            .order(Step.Columns.duration.desc)
    }
    
    public func filterNotSubsteps(with recipeId: Int64) -> Self {
        filter(by: recipeId)
            .filter(Step.Columns.superStepId == nil)
    }
    
    func filter(by recipeId: Int64) -> Self {
        filter(Step.Columns.recipeId == recipeId) /// filter recipeid
    }
}

//MARK: - Associations
extension Step {
    static let ingredients = hasMany(Ingredient.self)
    
    static let substeps = hasMany(Step.self, key: "substeps")
    static let superStep = belongsTo(Step.self, key: "superStep")
    
    static let recipe = belongsTo(Recipe.self)
}

///MARK: - Association methods
public extension Step {
    
    /// ingredients of the step
    internal func ingredients(db: Database) -> [Ingredient] {
        (try? Ingredient.filter(Ingredient.Columns.stepId == self.id).fetchAll(db)) ?? []
    }
    
    /// the substeps from the database that have this step as ther superstep
    internal func substeps(db: Database) -> [Step] {
        (try? Step.filter(Step.Columns.superStepId == self.id)
            .fetchAll(db)) ?? []
    }
    
    /// substep of this step sorted descending by their duration
    func sortedSubsteps(db: Database) -> [Step] {
        (try? Step.filter(Step.Columns.superStepId == self.id)
            .orderedByDuration(with: self.recipeId)
            .fetchAll(db)
        ) ?? []
    }
    
    /// substeps ordered by their duration in descending order + this step
    /// this order makes the most sense when doing the substeps and this step
    /// because the substeps are parrallel and so the longest one has to start first.
    func stepsForReodering(db: Database, number: Int) -> (steps: [Step], number: Int) {
        var steps = [Step]()
        var number = number
        for sub in sortedSubsteps(db: db) {
            var sub = sub

            sub.number = number
            try! sub.update(db) //update the new number to the database
            number += 1

            let subStepsForReodering = sub.stepsForReodering(db: db, number: number + 1)

            steps.append(contentsOf: subStepsForReodering.steps)

            number = subStepsForReodering.number
        }
        var step = self

        step.number = number
        try! step.update(db)
        number += 1

        steps.append(step)

        return (steps, number)
    }
    
    /// the mass of all Ingredients and Substeps to this step in a given database
    func totalMass(db: Database) -> Double{
        var mass: Double = 0
        
        for ingredient in ingredients(db: db) {
            mass += ingredient.mass
        }
        for substep in substeps(db: db) {
            mass += substep.totalMass(db: db)
        }
        
        return mass
    }
    
    /// the mass of all ingredients and substeps formatted with the right unit scaled with factor
    func totalFormattedMass(db: Database, factor: Double = 1.0) -> String {
        (self.totalMass(db: db) * factor).formattedMass
    }
    
    /// temperature for bulk liquids so the step has the right Temperature
    func temperature(for ingredient: Ingredient, roomTemp: Double, kneadingHeating: Double, db: Database) -> Double {
        
        var sumMassCProductAll = 0.0
        _ = ingredients(db: db).map { sumMassCProductAll += $0.massCProduct }
        _ = substeps(db: db).map { sumMassCProductAll += $0.massCProduct(db: db) }
        
        var sumMassCTempProductRest = 0.0
        _ = ingredients(db: db).filter { $0 != ingredient }.map { sumMassCTempProductRest += $0.massCTempProduct(roomTemp: roomTemp) }
        _ = substeps(db: db).map { sumMassCTempProductRest += $0.massCTempProduct(db: db, superTemp: self.temperature ?? roomTemp)}
        
        let ingredientMassCProduct = ingredient.massCProduct
        let roomTemp = Double(roomTemp)
        
        let temperature = (self.temperature ?? roomTemp) - kneadingHeating
        
        guard ingredientMassCProduct != 0.0 else {
            return roomTemp
        }
        
        return ((sumMassCProductAll * temperature) - sumMassCTempProductRest)/ingredientMassCProduct
    }
    
    /// specific temperature capacity of all the ingredients and all ingredients of all substeps combined
    private func c(db: Database) -> Double {
        let percentageFlour = flourMass(db: db)/totalMass(db: db)
        let percentageWater = waterMass(db: db)/totalMass(db: db)
        let percentageOther = otherMass(db: db)/totalMass(db: db)
        let percentageTa150 = ta150Mass(db: db)/totalMass(db: db)
        let percentageTa200 = ta200Mass(db: db)/totalMass(db: db)
        return percentageFlour * Ingredient.Style.flour.rawValue + percentageWater * Ingredient.Style.bulkLiquid.rawValue + percentageOther * Ingredient.Style.other.rawValue + percentageTa150 * Ingredient.Style.ta150.rawValue + percentageTa200 * Ingredient.Style.ta200.rawValue
        //Anteil Mehl*Cmehl+Anteil Wasser*CWasser
    }
    
    /// total mass of flour in the step
    func flourMass(db: Database) -> Double {
        var mass = Ingredient.Style.flour.massOfSelfIngredients(in: self, db: db)
        _ = substeps(db: db).map { mass += $0.flourMass(db: db) }
        return mass
    }
    
    /// total mass of water in the step
    func waterMass(db: Database) -> Double {
        var mass = Ingredient.Style.bulkLiquid.massOfSelfIngredients(in: self, db: db)
        _ = substeps(db: db).map { mass += $0.waterMass(db: db) }
        return mass
    }
    
    /// total mass of ingredient with type other
    private func otherMass(db: Database) -> Double {
        var mass = Ingredient.Style.other.massOfSelfIngredients(in: self, db: db)
        _ = substeps(db: db).map { mass += $0.otherMass(db: db) }
        return mass
    }
    
    private func ta150Mass(db: Database) -> Double {
        var mass = Ingredient.Style.ta150.massOfSelfIngredients(in: self, db: db)
        _ = substeps(db: db).map { mass += $0.ta150Mass(db: db)}
        return mass
    }
    
    private func ta200Mass(db: Database) -> Double {
        var mass = Ingredient.Style.ta200.massOfSelfIngredients(in: self, db: db)
        _ = substeps(db: db).map { mass += $0.ta200Mass(db: db)}
        return mass
    }
    
    
    private func massCProduct(db: Database) -> Double {
        self.totalMass(db: db) * self.c(db: db)
    }
    
    private func massCTempProduct(db: Database, superTemp: Double) -> Double {
        let temp: Double = self.temperature ?? superTemp
        return massCProduct(db: db) * temp
    }
    
    ///text for exporting for one step
    func text(startDate: Date, roomTemp: Double, scaleFactor: Double, kneadingHeating: Double, db: Database) -> String{
        var text = ""
        
        for step in substeps(db: db) {
            text += step.text(startDate: startDate, roomTemp: roomTemp, scaleFactor: scaleFactor, kneadingHeating: kneadingHeating, db: db)
        }
        
        let nameString = "\(self.formattedName) \(dateFormatter.string(from: startDate))\n"
        text.append(nameString)
        
        for ingredient in ingredients(db: db){
            let ingredientString = "\t" + ingredient.formattedName + ": " + ingredient.scaledFormattedAmount(with: scaleFactor) +
                " \(ingredient.type == .bulkLiquid ? self.temperature(for: ingredient, roomTemp: roomTemp, kneadingHeating: kneadingHeating, db: db).formattedTemp : "" )" + "\n"
            text.append(ingredientString)
        }
        for subStep in substeps(db: db){
            let substepString = subStep.formattedName + ": " + "\(totalMass(db: db))" + "\(subStep.temperature ?? roomTemp)" + "° C\n"
            text.append(substepString)
        }
        if !self.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            text.append(self.notes + "\n")
        }
        return text
    }
    
    
}
