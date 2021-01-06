//
//  Step.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import Foundation
import BakingRecipeStrings
import Sqlable

public struct Step: Equatable, BakingRecipeSqlable {
    
    /// unique id of the step
    public var id: Int
    
    /// name of the step
    ///- NOTE: Should only be used to set not to get. Use formatted name instead
    public var name: String = ""
    
    /// how long the step takes
    public var duration: TimeInterval = 60
    
    /// what the temp of the step is
    ///- NOTE: This is only not nil if the temp is something different from the room temperature
    public var temperature: Int? = nil
    
    /// some notes you can attach
    public var notes: String = ""
    
    /// the id of the recipe the step is in
    public var recipeId: Int
    
    /// the id of the superstep
    ///- NOTE: optional because a step can be without a superstep
    public var superStepId: Int? = nil
    
    /// number of the step for sorting
    public var number: Int
    
    public init(id: Int, name: String = "", duration: TimeInterval = 60, temperature: Int? = nil, notes: String = "", recipeId: Int, number: Int) {
        self.id = id
        self.name = name
        self.duration = duration
        self.temperature = temperature
        self.notes = notes
        self.recipeId = recipeId
        self.superStepId = nil
        self.number = number
    }
    
}

public extension Step {
    
    /// ingredients of the step
    private func ingredients(db: SqliteDatabase) -> [Ingredient] {
        return (try? Ingredient.read().filter(Ingredient.stepId == self.id).run(db)) ?? []
    }
    
    /// the substeps from the database that have this step as their superstep
    private var substepsRead: Statement<Step, [Step]>? {
        Step.read().filter(Step.superStepId == self.id)
    }
    
    /// substeps of this step
    func substeps(db: SqliteDatabase) -> [Step] {
        return (try? substepsRead?.run(db)) ?? []
    }
    
    /// substep of this step sorted descending by their duration
    func sortedSubsteps(db: SqliteDatabase) -> [Step] {
        return (try? substepsRead?.orderBy(Step.duration, .desc).run(db)) ?? []
    }
    
    /// substeps ordered by their duration in descending order + this step
    /// this order makes the most sense when doing the substeps and this step
    /// because the substeps are parrallel and so the longest one has to start first.
    func stepsForReodering(db: SqliteDatabase) -> [Step] {
        var steps = [Step]()
        for sub in sortedSubsteps(db: db) {
            steps.append(contentsOf: sub.stepsForReodering(db: db))
        }
        steps.append(self)
        
        return steps
    }
    
    /// duration of the step formatted with the right unit
    var formattedDuration: String {
        Int(duration/60).formattedDuration
    }
    
    /// the temperature of the step formatted with Celsius
    func formattedTemp(roomTemp: Int) -> String{
        return String(self.temperature ?? roomTemp) + " °C"
    }
    
    /// name of the step
    ///- NOTE:should be used for displaying the name. For changing the name use name instead.
    var formattedName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? Strings.unnamedStep : name
    }
    
    /// the mass of all Ingredients and Substeps to this step in a given database
    func totalMass(db: SqliteDatabase) -> Double{
        var mass = 0.0
        
        for ingredient in ingredients(db: db) {
            mass += ingredient.mass
        }
        for substep in substeps(db: db) {
            mass += substep.totalMass(db: db)
        }
        
        return mass
    }
    
    /// the mass of all ingredients and substeps formatted with the right unit
    func totalFormattedMass(db: SqliteDatabase) -> String {
        MassFormatter.formattedMass(for: self.totalMass(db: db))
    }
    
    /// temperature for bulk liquids so the step has the right Temperature
    func temperature(for ingredient: Ingredient, roomTemp: Int, db: SqliteDatabase) -> Int {
        
        var sumMassCProductAll = 0.0
        _ = ingredients(db: db).map { sumMassCProductAll += $0.massCProduct }
        _ = substeps(db: db).map { sumMassCProductAll += $0.massCProduct(db: db) }
        
        let tKnet = 0
        
        var sumMassCProductRest = 0.0
        _ = ingredients(db: db).filter { $0 != ingredient }.map { sumMassCProductRest += $0.massCTempProduct(roomTemp: roomTemp) }
        _ = substeps(db: db).map { sumMassCProductRest += $0.massCTempProduct(db: db, roomTemp: roomTemp)}
        
        let ingredientMassCProduct = ingredient.massCProduct
        let temperature = Double(self.temperature ?? roomTemp - tKnet)
        
        guard ingredientMassCProduct != 0.0 else {
            return roomTemp
        }
        
        let returnDouble = ((sumMassCProductAll * temperature) - sumMassCProductRest)/ingredientMassCProduct
        
        return Int(
            returnDouble
        )
    }
    
    /// specific temperature capacity of all the ingredients and all ingredients of all substeps combined
    private func c(db: SqliteDatabase) -> Double {
        let percentageFlour = flourMass(db: db)/totalMass(db: db)
        let percentageWater = waterMass(db: db)/totalMass(db: db)
        return percentageFlour * Ingredient.Style.flour.rawValue + percentageWater * Ingredient.Style.bulkLiquid.rawValue
        //Anteil Mehl*Cmehl+Anteil Wasser*CWasser
    }
    
    /// total mass of flour in the step
    private func flourMass(db: SqliteDatabase) -> Double {
        var mass = 0.0
        _ = ingredients(db: db).filter { $0.type == .flour }.map { mass += $0.mass}
        _ = substeps(db: db).map { mass += $0.flourMass(db: db) }
        return mass
    }
    
    /// total mass of water in the step
    private func waterMass(db: SqliteDatabase) -> Double {
        var mass = 0.0
        _ = ingredients(db: db).filter { $0.type == .bulkLiquid }.map { mass += $0.mass}
        _ = substeps(db: db).map { mass += $0.waterMass(db: db) }
        return mass
    }
    
    private func massCProduct(db: SqliteDatabase) -> Double {
        self.totalMass(db: db) * self.c(db: db)
    }
    
    private func massCTempProduct(db: SqliteDatabase, roomTemp: Int) -> Double {
        return massCProduct(db: db) * Double(self.temperature ?? roomTemp)
    }
    
    ///text for exporting for one step
    func text(startDate: Date, roomTemp: Int, scaleFactor: Double, db: SqliteDatabase) -> String{
        var text = ""
        
        for step in substeps(db: db) {
            text += step.text(startDate: startDate, roomTemp: roomTemp, scaleFactor: scaleFactor, db: db)
        }
        
        let nameString = "\(self.formattedName) \(dateFormatter.string(from: startDate))\n"
        text.append(nameString)
        
        for ingredient in ingredients(db: db){
            let ingredientString = "\t" + ingredient.formattedName + ": " + ingredient.scaledFormattedAmount(with: scaleFactor) +
                " \(ingredient.type == .bulkLiquid ? String(self.temperature(for: ingredient, roomTemp: roomTemp, db: db) ) + "° C" : "" )" + "\n"
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

// MARK - Sqlable
public extension Step{
    
    //create the columns
    static let id = Column("id", .integer, PrimaryKey(autoincrement: true))
    static let name = Column("name", .text)
    static let duration = Column("duration", .real)
    static let temperature = Column("temperature", .nullable(.integer))
    static let notes = Column("notes", .text)
    static let superStepId = Column("superStepId", .nullable(.integer), ForeignKey<Step>(onDelete: .ignore, onUpdate: .ignore))
    static let recipeId = Column("recipeId", .integer, ForeignKey<Recipe>(column: Recipe.id, onDelete: .cascade, onUpdate: .ignore))
    static let number = Column("number", .integer)
    static var tableLayout: [Column] = [id, name, duration, temperature, notes, superStepId, recipeId, number]
    
    /// value for a given column
    func valueForColumn(_ column: Column) -> SqlValue? {
        switch column {
        case Step.id:
            return self.id
        case Step.name:
            return self.name
        case Step.duration:
            return self.duration
        case Step.temperature:
            return self.temperature
        case Step.notes:
            return self.notes
        case Step.superStepId:
            return self.superStepId
        case Step.recipeId:
            return self.recipeId
        case Step.number:
            return self.number
        default:
            return nil
        }
    }
    
    /// initialize from database
    init(row: ReadRow) throws {
        self.id = try row.get(Step.id)
        self.name = try row.get(Step.name)
        self.duration = try row.get(Step.duration)
        self.temperature = try row.get(Step.temperature)
        self.notes = try row.get(Step.notes)
        self.superStepId = try? row.get(Step.superStepId)
        self.recipeId = try row.get(Step.recipeId)
        self.number = try row.get(Step.number)
    }
    
}
