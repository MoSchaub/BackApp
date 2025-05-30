// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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

    /// an optional endTemp that is used instead of the regular temp if the step is used as a substep
    public var endTemp: Double? = nil

    /// wether the endTemp is nil
    public var endTempEnabled: Bool {
        get {
            endTemp != nil
        }
        set {
            if newValue {
                endTemp = (temperature != nil ? temperature : 20)
            } else {
                endTemp = nil
            }
        }
    }
    
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
        Measurement(value: self.temperature ?? roomTemp, unit: .celsius).formatted
    }

    /// the end temp of the step in celsius
    /// returns formatted Temp if endTemp is nil
    func formattedEndTemp(roomTemp: Double) -> String {
        endTempEnabled ? Measurement(value: self.endTemp!, unit: .celsius).formatted : formattedTemp(roomTemp: roomTemp)
    }

    ///  the endTemp formatted in the localized unit
    /// Returns nil if endTemp is nil
    var formattedEndTemp: String? {
        (endTemp != nil ? Measurement(value: endTemp!, unit: .celsius).formatted : nil)
    }
    
    /// name of the step
    ///- NOTE:should be used for displaying the name. For changing the name use name instead.
    var formattedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Strings.unnamedStep : name.trimmingCharacters(in: .whitespacesAndNewlines)
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
        public static let endTemp = Column(CodingKeys.endTemp)
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
        Columns.isKneadingStep,
        Columns.endTemp
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
        endTemp = row[9] ?? nil
    }
}

//MARK: SQL Persistence methods
public extension Step {
    /// Update auto-increment id upon succesfull insertion
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

//MARK: SQL Requests
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

//MARK: - Association methods
public extension Step {

    private var ingredients: QueryInterfaceRequest<Ingredient> {
        Ingredient.all().orderedByNumber(with: self.id!)
    }
    
    /// ingredients of the step
    func ingredients(reader: DatabaseReader) -> [Ingredient] {
        (try? reader.read { db in
            try? ingredients(db: db)
        }) ?? []
    }
   
    // number of ingredients in this step using fetchCount
    // should be more efficient than self.ingredients(reader: reader).count
    func ingredientCount(reader: DatabaseReader) -> Int {
        (try? reader.read { db in
            try? Ingredient.all().orderedByNumber(with: self.id!).fetchCount(db)
        }) ?? 0
    }

    internal func ingredients(db: Database) throws -> [Ingredient] {
        try ingredients.fetchAll(db)
    }

    var substeps: QueryInterfaceRequest<Step> {
        Step.all().orderedSubstepsByDuration(of: self.id!, with: recipeId)
    }

    func sortedSubsteps(db: Database) -> [Step] {
        (try? substeps.fetchAll(db)) ?? []
    }
    
    /// substep of this step sorted descending by their duration
    func sortedSubsteps(reader: DatabaseReader) -> [Step] {
        (try? reader.read { db in
            try? substeps.fetchAll(db)
        }) ?? []
    }
    
    /// substeps ordered by their and their substeps longest duration  in descending order + this step
    /// this order makes the most sense when doing the substeps and this step
    /// because the substeps are parrallel and so the longest chain has to start first.
    /// also updates numbers
    func stepsForReordering(db: Database, number: inout Int) throws -> [Step] {

        //get the ordered ids from the database
        let stepIds = try Int64.fetchAll(db, sql: """
                                  WITH RECURSIVE step_hierarchy AS (
                                    SELECT
                                        id, superStepId, 0 AS plannedDuration
                                    FROM STEP
                                    WHERE superStepId IS NULL AND id = \(self.id!)

                                    UNION ALL

                                  SELECT
                                    s.id, s.superStepId, step_hierarchy.plannedDuration + s.duration
                                  FROM STEP s, step_hierarchy
                                  WHERE s.superStepId == step_hierarchy.id
                                  )
                                  SELECT id
                                  FROM step_hierarchy
                                  ORDER BY plannedDuration DESC

                                  """)

        //convert the ids to steps
        var steps = try stepIds.map{ try Step.all().filter(key: ["id":$0]).fetchOne(db)!}

        //update the numbers
        for (index,step) in steps.enumerated() {
            number += 1

            //make step mutable
            var step = step

            //change its number and write the step
            step.number = number

            //update the step in the array
            steps[index] = step
        }
        return steps
    }

    /// the duration of this step and its substeps
    /// - NOTE: This only counts the time of the longest substeps if there are multiple substeps because they will run in parallel
    func durationWithSubsteps(reader: DatabaseReader) -> Double {
        return self.duration + (self.sortedSubsteps(reader: reader).first?.durationWithSubsteps(reader: reader) ?? 0.0 )
    }

    func durationWithSubsteps(db: Database) throws -> Double {
        return self.duration + (try self.sortedSubsteps(db: db).first?.durationWithSubsteps(db: db) ?? 0.0)
    }
    
    /// the mass of all Ingredients and Substeps to this step in a given database
    func totalMass(reader: DatabaseReader) -> Double {
        (try? reader.read { db in
            try self.totalMass(db: db)
        }) ?? 0.0
    }

    func totalMass(db: Database) throws -> Double {
        var mass: Double = 0

        for ingredient in try ingredients(db: db){
            mass += ingredient.mass
        }
        for substep in sortedSubsteps(db: db) {
            mass += try substep.totalMass(db: db)
        }

        return mass
    }
    
    /// the mass of all ingredients and substeps formatted with the right unit scaled with factor
    func totalFormattedMass(reader: DatabaseReader, factor: Double = 1.0) -> String {
        ((try? reader.read { db in
            try (totalMass(db: db) * factor).formattedMass
        }) ?? "")
    }
    
    /// temperature for bulk liquids so the step has the right Temperature
    func bulkLiquidTemperature(roomTemp: Double, kneadingHeating: Double, databaseReader: DatabaseReader) throws -> Double {
        try databaseReader.read { db in
            var sumMassCProductAll = 0.0
            _ = try ingredients(db: db).map { sumMassCProductAll += $0.massCProduct }
            _ = try sortedSubsteps(db: db).map { sumMassCProductAll += try $0.massCProduct(db: db)}

            var sumMassCTempProductRest = 0.0
            _ = try ingredients(db: db).filter { $0.type != .bulkLiquid }.map { sumMassCTempProductRest += $0.massCTempProduct(roomTemp: roomTemp) }
            _ = try sortedSubsteps(db: db).map { sumMassCTempProductRest += try $0.massCTempProduct(db: db, superTemp: self.temperature ?? roomTemp)}

            let bulkIngredients = try ingredients(db: db).filter { $0.type == .bulkLiquid}
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

    private func c(db: Database) throws -> Double {
        let totalMass = try self.totalMass(db: db)
        let percentageFlour = try flourMass(db: db)/totalMass
        let percentageWater = try waterMass(db: db)/totalMass
        let percentageOther = try otherMass(db: db)/totalMass
        let percentageTa150 = try ta150Mass(db: db)/totalMass
        let percentageTa200 = try ta200Mass(db: db)/totalMass
        return percentageFlour * Ingredient.Style.flour.rawValue + percentageWater * Ingredient.Style.bulkLiquid.rawValue + percentageOther * Ingredient.Style.other.rawValue + percentageTa150 * Ingredient.Style.ta150.rawValue + percentageTa200 * Ingredient.Style.ta200.rawValue
        //Anteil Mehl*cMehl+Anteil Wasser*cWasser ...
    }
    
    /// total mass of flour in the step
    func flourMass(reader: DatabaseReader) -> Double {
        var mass = Ingredient.Style.flour.massOfSelfIngredients(in: self, reader: reader)
        mass += Ingredient.Style.ta150.massOfSelfIngredients(in: self, reader: reader) * 2/3 //ta150 is 1/3 water and 2/3 flour
        mass += Ingredient.Style.ta200.massOfSelfIngredients(in: self, reader: reader) * 1/2 //ta200 is half water and half flour
        _ = sortedSubsteps(reader: reader).map { mass += $0.flourMass(reader: reader) }
        return mass
    }

    func flourMass(db: Database) throws -> Double {
        var mass = try Ingredient.Style.flour.massOfSelfIngredients(in: self, db: db)
        mass += try Ingredient.Style.ta150.massOfSelfIngredients(in: self, db: db) * 2/3 //ta150 is 1/3 water and 2/3 flour
        mass += try Ingredient.Style.ta200.massOfSelfIngredients(in: self, db: db) * 1/2 //ta200 is half water and half flour
        _ = try sortedSubsteps(db: db).map { mass += try $0.flourMass(db: db)}
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

    func waterMass(db: Database) throws -> Double {
        var mass = try Ingredient.Style.bulkLiquid.massOfSelfIngredients(in: self, db: db)
        mass += try Ingredient.Style.ta150.massOfSelfIngredients(in: self, db: db) * 1/3 //ta150 is 1/3 water and 2/3 flour
        mass += try Ingredient.Style.ta200.massOfSelfIngredients(in: self, db: db) * 1/2 //ta200 is half water and half flour
        _ = try sortedSubsteps(db: db).map { mass += try $0.waterMass(db: db)}
        return mass
    }
    
    /// total mass of ingredient with type other
    private func otherMass(reader: DatabaseReader) -> Double {
        var mass = Ingredient.Style.other.massOfSelfIngredients(in: self, reader: reader)
        _ = sortedSubsteps(reader: reader).map { mass += $0.otherMass(reader: reader) }
        return mass
    }

    private func otherMass(db: Database) throws -> Double {
        var mass = try Ingredient.Style.other.massOfSelfIngredients(in: self, db: db)
        _ = try sortedSubsteps(db: db).map { mass += try $0.waterMass(db: db)}
        return mass
    }
    
    private func ta150Mass(reader: DatabaseReader) -> Double {
        var mass = Ingredient.Style.ta150.massOfSelfIngredients(in: self, reader: reader)
        _ = sortedSubsteps(reader: reader).map { mass += $0.ta150Mass(reader: reader)}
        return mass
    }

    private func ta150Mass(db: Database) throws -> Double {
        var mass = try Ingredient.Style.ta150.massOfSelfIngredients(in: self, db: db)
        _ = try sortedSubsteps(db: db).map { mass += try $0.ta150Mass(db: db)}
        return mass
    }
    
    private func ta200Mass(reader: DatabaseReader) -> Double {
        var mass = Ingredient.Style.ta200.massOfSelfIngredients(in: self, reader: reader)
        _ = sortedSubsteps(reader: reader).map { mass += $0.ta200Mass(reader: reader)}
        return mass
    }

    private func ta200Mass(db: Database) throws -> Double {
        var mass = try Ingredient.Style.ta200.massOfSelfIngredients(in: self, db: db)
        _ = try sortedSubsteps(db: db).map { mass += try $0.ta200Mass(db: db)}
        return mass
    }
    
    
    private func massCProduct(reader: DatabaseReader) -> Double {
        self.totalMass(reader: reader) * self.c(reader: reader)
    }

    private func massCProduct(db: Database) throws -> Double {
        try self.totalMass(db: db) * self.c(db: db)
    }


    private func massCTempProduct(db: Database, superTemp: Double) throws -> Double {
        let temp: Double = self.endTempEnabled ? self.endTemp! : self.temperature ?? superTemp
        return try massCProduct(db: db) * temp
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
            let ingredientTemp = Measurement(value: (try? self.bulkLiquidTemperature(roomTemp: roomTemp, kneadingHeating: kneadingHeating, databaseReader: reader)) ?? roomTemp, unit: .celsius).formatted
            let ingredientString = "\t" + ingredient.formattedName + ": " + ingredient.scaledFormattedAmount(with: scaleFactor) +
                " \(ingredient.type == .bulkLiquid ? ingredientTemp : "" )" + "\n"
            text.append(ingredientString)
        }
        for subStep in sortedSubsteps(reader: reader){
            let substepString = "\t" + subStep.formattedName + ": " + "\(subStep.totalFormattedMass(reader: reader, factor: scaleFactor)) " + (subStep.temperature != nil ? Measurement(value: subStep.endTemp ?? subStep.temperature! , unit: .celsius).formatted : "") + "\n"
            text.append(substepString)
        }
        if !self.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            text.append(self.notes + "\n")
        }
        return text
    }
    
    
}
