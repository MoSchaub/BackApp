//
//  Recipe.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import GRDB
import Foundation
import BakingRecipeStrings

public struct Recipe: BakingRecipeRecord {
    //MARK: Properties
    
    /// unique id of the recipe
    /// optional so that you can instantiate a record before it gets inserted and gains an id (by `didInsert(with:for:)`)
    public var id: Int64?
    
    ///name of the recipe
    /// - Note: Should only be used to set not to get. Use formatted name instead
    public var name: String
    
    /// small text containing some Info about the recipe
    public var info: String
    
    /// wether the recipe is a favorite
    public var isFavorite: Bool = false
    
    ///how difficult the recipe is
    public var difficulty: Difficulty = .easy
    
    ///wether the "date" property is the end date or the start date
    public var inverted: Bool = false
    
    ///for how many items eg breads, rolls, etc the the ingredients are set
    public var times: Decimal? = Decimal(integerLiteral: 1)
    
    ///date thats either the start or the end point of the recipe
    public var date: Date = Date()
    
    ///data of the image for the recipe
    public var imageData: Data?
    
    /// number used for sorting
    public var number: Int
    
    public init(name: String = "", number: Int) {
        self.id = nil
        self.name = name
        self.info = ""
        self.isFavorite = false
        self.difficulty = .easy
        self.inverted = false
        self.times = Decimal(integerLiteral: 1)
        self.date = Date()
        self.imageData = nil
        self.number = number
    }
    
    /// formatted text for times
    public var timesText: String{
        get{
            if self.times != nil {
                return times!.description + " " +
                    (times!.description == "1" ? Strings.piece : Strings.pieces)
            } else {
                return "1 " + Strings.piece
            }
        }
        set{
            if let int = Int(newValue){
                self.times = Decimal(integerLiteral: int)
            } else{
                self.times = nil
            }
        }
    }
    
    /// timesText + indivialMass given a total Mass, e. g. 12 pieces, 11 g each
    public func timesTextWithIndivialMass(with totalMass: Double) -> String {
        
        return self.timesText + (Bundle.main.preferredLocalizations.first! == "de" ? " à " : ", " ) + (totalMass/Double(self.times!.description)!).formattedMass + (Bundle.main.preferredLocalizations.first! == "en" ? " each" : "")
    }
    
    /// scale the times text with a factor
    private func timesTextScaled(with factor: Double) -> String {
        if self.times != nil {
            let times = self.times! * Decimal(factor)
            return times.description + " " +
                (times.description == "1" ? Strings.piece : Strings.pieces)
        } else {
            return "1 " + Strings.piece
        }
    }
}

func is24Hour() -> Bool {
    let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!

    return dateFormat.firstIndex(of: "a") == nil
}


///date formatter with custom dateFormat
public var dateFormatter: DateFormatter{
    let formatter = DateFormatter()
    if is24Hour() {
        formatter.dateFormat = "dd.MM.yy',' HH:mm"
    } else {
        formatter.dateFormat = "dd.MM.yy',' hh:mm a"
    }
    return formatter
}

//MARK: - Formatted Properties
public extension Recipe {
    ///formatted Name with a standart value
    ///should be used when displaying the name
    var formattedName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? Strings.unnamedRecipe : name
    }
    
    static var example: (recipe: Recipe, stepIngredients: [(step: Step, ingredients: [Ingredient])]) {
        let vollkornMehl = Ingredient(stepId: 1, name: "Vollkornmehl", amount: 50, type: .flour, number: 0)
        let anstellgut = Ingredient(stepId: 1, name: "Anstellgut TA 200", amount: 120, type: .ta200, number: 1)
        let olivenöl = Ingredient(stepId: 1, name: "Olivenöl", amount: 40, type: .bulkLiquid, number: 2)
        let saaten = Ingredient(stepId: 1, name: "Saaten", amount: 30, type: .other, number: 3)
        let salz = Ingredient(stepId: 1, name: "Salz", amount: 5, type: .other, number: 4)
        
        let schritt1 = Step(name: "Mischen", duration: 2*60, temperature: 20, recipeId: 1, number: 0)
        
        let backen = Step(name: "Backen", duration: 18*60, notes: "170˚ C", recipeId: 1, number: 1)
        
        return (Recipe(name: "Sauerteigcracker", number: 0), [(schritt1, [vollkornMehl, anstellgut, olivenöl, saaten, salz]), (backen, [])])
    }
    
    static func complexExample(number: Int) -> (recipe: Recipe, stepIngredients: [(step: Step, ingredients: [Ingredient])]) {
        let recipe = Recipe(name: "Komplexes Rezept", number: number)
        var sub = Step(name: "Sauerteig", temperature: 30, recipeId: Int64(number), number: 1)
        sub.superStepId = 1
        let mehl = Ingredient(stepId: 1, name: "Mehl", amount: 200, type: .flour, number: 0)
        let wasser = Ingredient(stepId: 1, name: "Wasser", amount: 100, type: .bulkLiquid, number: 1)
        let step = Step(name: "Hauptteig", duration: 1800, temperature: 26, recipeId: Int64(number), number: 0)
        let mehl2 = Ingredient(stepId: 0, name: "Mehl", amount: 200, type: .flour, number: 0)
        let wasser2 = Ingredient(stepId: 0, name: "Wasser", amount: 100, type: .bulkLiquid, number: 1)
        
        return (recipe, [(step, [mehl2, wasser2]), (sub, [mehl, wasser])])
    }
    
    ///recipe prepared for exporting
    func neutralizedForExport() -> Recipe {
        var neutralized = self
        neutralized.inverted = false
        neutralized.isFavorite = false
        return neutralized
    }
    
}

//MARK: - SQL

//MARK: SQL generation
public extension Recipe {
    
    /// define the table columns
    enum Columns {
        public static let id = Column(CodingKeys.id)
        public static let name = Column(CodingKeys.name)
        public static let info = Column(CodingKeys.info)
        public static let isFavorite = Column(CodingKeys.isFavorite)
        public static let difficulty = Column(CodingKeys.difficulty)
        public static let inverted = Column(CodingKeys.inverted)
        public static let times = Column(CodingKeys.times)
        public static let date = Column(CodingKeys.date)
        public static let imageData = Column(CodingKeys.imageData)
        public static let number = Column(CodingKeys.number)
    }
    
    /// Arange the selected columns and lock their order
    static let databaseSelection: [SQLSelectable] = [
        Columns.id,
        Columns.name,
        Columns.info,
        Columns.isFavorite,
        Columns.difficulty,
        Columns.inverted,
        Columns.times,
        Columns.date,
        Columns.imageData,
        Columns.number
    ]
}

//MARK: SQL Fetching
public extension Recipe {
    
    ///creates a record from a database row
    init(row: Row) {
        /// For high performance, use numeric indices
        /// that match the order of `Recipe.databaseSelection`
        id = row[0]
        name = row[1]
        info = row[2]
        isFavorite = row[3]
        difficulty = Difficulty(rawValue: row[4]) ?? Difficulty.easy
        inverted = row[5]
        times = row[6]
        date = row[7]
        imageData = row[8]
        number = row[9]
    }
}

//MARK: SQL Persistence methods
public extension Recipe {
    /// Update auto-increment id upon succesfull insertion
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

//TODO: cascade delete

//MARK: SQL Requests
extension DerivableRequest where RowDecoder == Recipe {
    // A request of recipes ordered by number in ascending order.
    ///
    /// For example:
    ///
    ///     let recipes: [Recipe] = try dbWriter.read { db in
    ///         try Recipe.all().orderedByNumber.fetchAll(db)
    ///     }
    public var orderedByNumber: Self {
        order(Recipe.Columns.number.asc)
    }
    
    /// A request of recipes filtered with `isFavorite == true`
    ///
    /// For example: ii
    ///
    ///```
    ///     let favorites: [Recipe] = try dbWriter.read { db in
    ///         try Recipe.all().filterFavorites: Self
    ///     }
    ///```
    public var filterFavorites: Self {
        filter(Recipe.Columns.isFavorite == true)
    }
}

//MARK: - Association methods
public extension Recipe {
    static let steps = hasMany(Step.self)
    
    static let ingredients = hasMany(Ingredient.self, through: steps, using: Step.ingredients)
}

//MARK: - Association methods
public extension Recipe {

    var steps: QueryInterfaceRequest<Step> {
        Step.all().orderedByNumber(with: self.id!)
    }
    /// steps of the recipe
    private func steps(reader: DatabaseReader) -> [Step] {
        (try? reader.read { db in
            try? steps.fetchAll(db)
        }) ?? []
    }

    /// total duration of all the steps
    func totalDuration(reader: DatabaseReader) -> Int {
        (try? reader.read { db in
            try totalDuration(db: db)
        }) ?? 0
    }

    /// total duration of all the steps in minutes formatted as a string
    func formattedTotalDuration(reader: DatabaseReader) -> String {
        self.totalDuration(reader: reader).formattedDuration
    }

    /// total duration of all the steps in minutes
    /// - Note: multiple substeps of one step are paralelized
    private func totalDuration(db: Database) throws -> Int {
        var allTimes: Int = 0
        for step in try self.notSubsteps(db: db) {
            allTimes += Int(try step.durationWithSubsteps(db: db)/60)
        }
        return allTimes
    }

    func formattedTotalDurationHours(db: Database) throws -> String {
        try totalDuration(db: db).hours.formattedDuration
    }

    /// totalAmount of all ingredients in the recipe
    func totalAmount(db: Database) throws -> Double {
        var summ: Double = 0
        // iterate through all non substeps cause totalMass also uses the substeps
        _ = try self.notSubsteps(db: db).map { summ += try $0.totalMass(db: db)}
        //_ = self.notSubsteps(for: recipeId).map { summ += self.totalMass(for: $0.id!)}
        return summ
    }

    func formattedTotalAmount(db: Database) throws -> String {
        try totalAmount(db: db).formattedMass
    }


    //dough yield
    func totalDoughYield(db: Database) throws -> Double {

        var flourSum = 0.0
        _ = try self.notSubsteps(db: db).map { flourSum += try $0.flourMass(db: db)}

        var waterSum = 0.0
        _ = try self.notSubsteps(db: db).map { waterSum += try $0.waterMass(db: db)}

        guard flourSum != 0 else {
            return 0
        }

        if Bundle.main.preferredLocalizations.first! == "de" {
            return (waterSum/flourSum) * 100 + 100
        } else {
            return (waterSum/flourSum)
        }
    }

    /// dough Yield (waterSum/flourSum) for a given Recipe as a String shorted to 2 decimal points
    func formattedTotalDoughYield(db: Database) throws -> String {
        String(format: "%.2f", try totalDoughYield(db: db))
    }
    
    ///starting date
    func startDate(reader: DatabaseReader) -> Date {
        if !inverted {
            return self.date
        } else {
            return self.date.addingTimeInterval(TimeInterval(-(totalDuration(reader: reader) * 60)))
        }
    }
    
    ///end date
    func endDate(reader: DatabaseReader) -> Date {
        if inverted {
            return self.date
        } else {
            return self.date.addingTimeInterval(TimeInterval(totalDuration(reader: reader) * 60))
        }
    }
    
    /// the startDateText for a given Step in this recipe
    func formattedStartDate(for item: Step, reader: DatabaseReader) -> String {
        let datesDict = startDatesDictionary(reader: reader)
        if let date = datesDict[item] {
            return dateFormatter.string(from: date)
        }
        return "error"
    }
    
    ///dictonary with the step and the corresponding startdate
    private func startDatesDictionary(reader: DatabaseReader) -> [Step : Date]{
        var dict = [Step : Date]()
        var h = startDate(reader: reader)
        for step in self.notSubsteps(reader: reader) {
            let stepDates = startDates(for: step, h: h, reader: reader)
            dict.append(contentsOf: stepDates.dict)
            h = stepDates.h
            
            h.addTimeInterval(step.duration)
        }
        return dict
    }
    
    ///Tuple with a start date and a startDates dictionary
    private func startDates(for step: Step, h: Date, reader: DatabaseReader) -> (h: Date, dict: [Step : Date]) {
        var dict = [Step : Date]()
        var h = h
        var sortedSubs = step.sortedSubsteps(reader: reader)
        if let first = sortedSubs.first { //get the longest sub
            sortedSubs.removeFirst() //remove so it does not get used twice
            let firstDates = startDates(for: first, h: h, reader: reader)
            dict.append(contentsOf: firstDates.dict)
            h = firstDates.h
            
            let subEndDate = h.addingTimeInterval(first.duration) //data when all substebs of the step should end
            for sub in sortedSubs {
                let subDates = startDates(for: sub, h: subEndDate.addingTimeInterval(-(sub.duration)), reader: reader)
                dict.append(contentsOf: subDates.dict)
            }
            
            h = subEndDate
        }
        dict[step] = h
        
        return (h,dict)
    }
    
    /// steps that are no substeps of any other step
    func notSubsteps(reader: DatabaseReader) -> [Step] {
        (try? reader.read { db in
            try? notSubsteps(db: db)
        }) ?? []
    }

    func notSubsteps(db: Database) throws -> [Step] {
        try Step.all().filterNotSubsteps(with: self.id!).fetchAll(db)
    }
    
    //reorderSteps to make sense
    func reorderedSteps(writer: DatabaseWriter) -> [Step] {
        (try? writer.write { db in
            try reoderedSteps(db: db)
        }) ?? []
    }

    func reoderedSteps(db: Database) throws -> [Step] {
        var steps = [Step]()
        var number = 0
        _ = try self.notSubsteps(db: db).map { steps.append(contentsOf: try $0.stepsForReordering(db: db, number: &number))}
        return steps.sorted(by: { $0.number < $1.number})
    }
    
    ///text for exporting
    func text(roomTemp: Double, scaleFactor: Double, kneadingHeating: Double, reader: DatabaseReader) -> String {
        var h = startDate(reader: reader)
        var text = self.formattedName
        text += " "
        
        // timesText needs to be scaled since the text can be requested for 12 pieces when times is only 10 so you need to adjust times with a scaleFactor
        text += timesTextScaled(with: scaleFactor)
        text += "\n"
        
        for step in notSubsteps(reader: reader) {
            text += step.text(startDate: h, roomTemp: roomTemp, scaleFactor: scaleFactor, kneadingHeating: kneadingHeating, reader: reader)
            h = h.addingTimeInterval(step.duration)
        }
        text += "\(Strings.EditButton_Done): \(dateFormatter.string(from: endDate(reader: reader)))"
        return text
    }

}

extension Recipe {

    ///duplicate the recipe
    public func duplicate(writer: DatabaseWriter) {
        try? writer.write { db in
            var recipe = self
            let steps = (try? recipe.steps.fetchAll(db)) ?? []

            recipe.id = nil
            try! recipe.insert(db)

            _ = steps.map { $0.duplicate(db: db, with: recipe.id!, superStepId: nil) }
        }
    }
}

extension Step {
    func duplicate(db: Database, with recipeId: Int64, superStepId: Int64?) {
        var step = self
        let ingredients = (try? step.ingredients(db: db)) ?? []
        let substeps = step.sortedSubsteps(db: db)

        step.id = nil
        step.recipeId = recipeId
        step.superStepId = superStepId
        try! step.insert(db)

        _ = ingredients.map { $0.duplicate(db: db, with: step.id!)}
        _ = substeps.map { $0.duplicate(db: db, with: recipeId, superStepId: step.id!)}
    }
}

extension Ingredient {
    func duplicate(db: Database, with stepId: Int64) {
        var ingredient = self

        ingredient.id = nil
        ingredient.stepId = stepId
        try! ingredient.insert(db)
    }
}
