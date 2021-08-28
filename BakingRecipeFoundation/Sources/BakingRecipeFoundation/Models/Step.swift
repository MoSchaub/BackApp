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

    /// wether the step is a kneading Step. This means that kneading Heating should be used for calculations
    public var isKneadingStep: Bool
    
    /// the id of the recipe the step is in
    public var recipeId: Int64
    
    /// the id of the superstep
    ///- NOTE: optional because a step can be without a superstep
    public var superStepId: Int64? = nil
    
    /// number of the step for sorting
    public var number: Int
    
    public init(name: String = "", duration: TimeInterval = 60, temperature: Double? = nil, notes: String = "", isKneadingStep: Bool = false, recipeId: Int64, number: Int) {
        self.name = name
        self.duration = duration
        self.temperature = temperature
        self.notes = notes
        self.isKneadingStep = false
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
        public static let id = Column(CodingKeys.id)
        public static let name = Column(CodingKeys.name)
        public static let duration = Column(CodingKeys.duration)
        public static let temperature = Column(CodingKeys.temperature)
        public static let notes = Column(CodingKeys.notes)
        public static let isKneadingStep = Column(CodingKeys.isKneadingStep)
        public static let recipeId = Column(CodingKeys.recipeId)
        public static let superStepId = Column(CodingKeys.superStepId)
        public static let number = Column(CodingKeys.number)
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
        Columns.number,
        Columns.isKneadingStep
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
        isKneadingStep = row[8] ?? false
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
    
    public func orderedSubstepsByDuration(of stepId: Int64, with recipeId: Int64) -> Self {
        filter(by: recipeId)
            .filter(Step.Columns.superStepId == stepId)
            .order(Step.Columns.duration.desc)
    }
    
    public func filterNotSubsteps(with recipeId: Int64) -> Self {
        orderedByNumber(with: recipeId)
            .filter(Step.Columns.superStepId == nil)
    }
    
    private func filter(by recipeId: Int64) -> Self {
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
    internal func ingredients(reader: DatabaseReader) -> [Ingredient] {
        (try? reader.read { db in
            try? Ingredient.filter(Ingredient.Columns.stepId == self.id).fetchAll(db)
        }) ?? []
    }
    
    /// substep of this step sorted descending by their duration
    func sortedSubsteps(reader: DatabaseReader) -> [Step] {
        (try? reader.read { db in
            try? Step.all().orderedSubstepsByDuration(of: self.id!, with: recipeId)
            .fetchAll(db)
        }) ?? []
    }
    
    /// substeps ordered by their duration in descending order + this step
    /// this order makes the most sense when doing the substeps and this step
    /// because the substeps are parrallel and so the longest one has to start first.
    func stepsForReodering(writer: DatabaseWriter, number: Int) -> (steps: [Step], number: Int) {
        var steps = [Step]()
        var number = number
        for sub in sortedSubsteps(reader: writer) {
            var sub = sub

            sub.number = number
            //update the new number to the database
            try! writer.write { db in
                try! sub.update(db)
            }
            number += 1

            let subStepsForReodering = sub.stepsForReodering(writer: writer, number: number + 1)

            steps.append(contentsOf: subStepsForReodering.steps)

            number = subStepsForReodering.number
        }
        var step = self

        step.number = number
        try! writer.write { db in
            try! step.update(db)
        }
        number += 1

        steps.append(step)

        return (steps, number)
    }
    
    /// the mass of all Ingredients and Substeps to this step in a given database
    func totalMass(reader: DatabaseReader) -> Double{
        var mass: Double = 0
        
        for ingredient in ingredients(reader: reader) {
            mass += ingredient.mass
        }
        for substep in sortedSubsteps(reader: reader) {
            mass += substep.totalMass(reader: reader)
        }
        
        return mass
    }
    
    /// the mass of all ingredients and substeps formatted with the right unit scaled with factor
    func totalFormattedMass(reader: DatabaseReader, factor: Double = 1.0) -> String {
        (self.totalMass(reader: reader) * factor).formattedMass
    }
    
    /// temperature for bulk liquids so the step has the right Temperature
    func temperature(roomTemp: Double, kneadingHeating: Double, reader: DatabaseReader) -> Double {
        
        var sumMassCProductAll = 0.0
        _ = ingredients(reader: reader).map { sumMassCProductAll += $0.massCProduct }
        _ = self.sortedSubsteps(reader: reader).map { sumMassCProductAll += $0.massCProduct(reader: reader)}
        
        var sumMassCTempProductRest = 0.0
        _ = ingredients(reader: reader).filter { $0.type != .bulkLiquid }.map { sumMassCTempProductRest += $0.massCTempProduct(roomTemp: roomTemp) }
        _ = sortedSubsteps(reader: reader).map { sumMassCTempProductRest += $0.massCTempProduct(reader: reader, superTemp: self.temperature ?? roomTemp)}
        
        let bulkIngredients = ingredients(reader: reader).filter { $0.type == .bulkLiquid}
        var bulkingredientsMassCProduct = 0.0
        for bulkIngredient in bulkIngredients {
            bulkingredientsMassCProduct += bulkIngredient.massCProduct
        }
        
        let roomTemp = Double(roomTemp)
        
        let temperature = (self.temperature ?? roomTemp) - (isKneadingStep ? kneadingHeating : 0)
        
        guard bulkingredientsMassCProduct != 0.0 else {
            return roomTemp
        }
        
        return ((sumMassCProductAll * temperature) - sumMassCTempProductRest)/bulkingredientsMassCProduct
    }
    
    /// specific temperature capacity of all the ingredients and all ingredients of all substeps combined
    private func c(reader: DatabaseReader) -> Double {
        let percentageFlour = flourMass(reader: reader)/totalMass(reader: reader)
        let percentageWater = waterMass(reader: reader)/totalMass(reader: reader)
        let percentageOther = otherMass(reader: reader)/totalMass(reader: reader)
        let percentageTa150 = ta150Mass(reader: reader)/totalMass(reader: reader)
        let percentageTa200 = ta200Mass(reader: reader)/totalMass(reader: reader)
        return percentageFlour * Ingredient.Style.flour.rawValue + percentageWater * Ingredient.Style.bulkLiquid.rawValue + percentageOther * Ingredient.Style.other.rawValue + percentageTa150 * Ingredient.Style.ta150.rawValue + percentageTa200 * Ingredient.Style.ta200.rawValue
        //Anteil Mehl*Cmehl+Anteil Wasser*CWasser
    }
    
    /// total mass of flour in the step
    func flourMass(reader: DatabaseReader) -> Double {
        var mass = Ingredient.Style.flour.massOfSelfIngredients(in: self, reader: reader)
        mass += Ingredient.Style.ta150.massOfSelfIngredients(in: self, reader: reader) * 2/3 //ta150 is 1/3 water and 2/3 flour
        mass += Ingredient.Style.ta200.massOfSelfIngredients(in: self, reader: reader) * 1/2 //ta200 is half water and half flour
        _ = sortedSubsteps(reader: reader).map { mass += $0.flourMass(reader: reader) }
        return mass
    }
    
    /// total mass of water in the step
    func waterMass(reader: DatabaseReader) -> Double {
        var mass = Ingredient.Style.bulkLiquid.massOfSelfIngredients(in: self, reader: reader)
        mass += Ingredient.Style.ta150.massOfSelfIngredients(in: self, reader: reader) * 1/3 //ta150 is 1/3 water and 2/3 flour
        mass += Ingredient.Style.ta200.massOfSelfIngredients(in: self, reader: reader) * 1/2 //ta200 is half water and half flour
        _ = sortedSubsteps(reader: reader).map { mass += $0.waterMass(reader: reader) }
        return mass
    }
    
    /// total mass of ingredient with type other
    private func otherMass(reader: DatabaseReader) -> Double {
        var mass = Ingredient.Style.other.massOfSelfIngredients(in: self, reader: reader)
        _ = sortedSubsteps(reader: reader).map { mass += $0.otherMass(reader: reader) }
        return mass
    }
    
    private func ta150Mass(reader: DatabaseReader) -> Double {
        var mass = Ingredient.Style.ta150.massOfSelfIngredients(in: self, reader: reader)
        _ = sortedSubsteps(reader: reader).map { mass += $0.ta150Mass(reader: reader)}
        return mass
    }
    
    private func ta200Mass(reader: DatabaseReader) -> Double {
        var mass = Ingredient.Style.ta200.massOfSelfIngredients(in: self, reader: reader)
        _ = sortedSubsteps(reader: reader).map { mass += $0.ta200Mass(reader: reader)}
        return mass
    }
    
    
    private func massCProduct(reader: DatabaseReader) -> Double {
        self.totalMass(reader: reader) * self.c(reader: reader)
    }
    
    private func massCTempProduct(reader: DatabaseReader, superTemp: Double) -> Double {
        let temp: Double = self.temperature ?? superTemp
        return massCProduct(reader: reader) * temp
    }
    
    ///text for exporting for one step
    func text(startDate: Date, roomTemp: Double, scaleFactor: Double, kneadingHeating: Double, reader: DatabaseReader) -> String{
        var text = ""
        
        for step in sortedSubsteps(reader: reader) {
            text += step.text(startDate: startDate, roomTemp: roomTemp, scaleFactor: scaleFactor, kneadingHeating: kneadingHeating, reader: reader)
        }
        
        let nameString = "\(self.formattedName) \(dateFormatter.string(from: startDate))\n"
        text.append(nameString)
        
        for ingredient in ingredients(reader: reader){
            let ingredientString = "\t" + ingredient.formattedName + ": " + ingredient.scaledFormattedAmount(with: scaleFactor) +
                " \(ingredient.type == .bulkLiquid ? self.temperature(roomTemp: roomTemp, kneadingHeating: kneadingHeating, reader: reader).formattedTemp : "" )" + "\n"
            text.append(ingredientString)
        }
        for subStep in sortedSubsteps(reader: reader){
            let substepString = "\t" + subStep.formattedName + ": " + "\(totalMass(reader: reader).formattedMass) " + "\(subStep.temperature ?? roomTemp)" + "° C\n"
            text.append(substepString)
        }
        if !self.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            text.append(self.notes + "\n")
        }
        return text
    }
    
    
}
