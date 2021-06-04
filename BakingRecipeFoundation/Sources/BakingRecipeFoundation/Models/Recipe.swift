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
    var timesText: String{
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
    
}

///date formatter with custom dateFormat
public var dateFormatter: DateFormatter{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yy',' HH:mm"
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
        let sub = Step(name: "Sauerteig", temperature: 30, recipeId: Int64(number), number: 0)
        let mehl = Ingredient(stepId: 0, name: "Mehl", amount: 200, type: .flour, number: 0)
        let wasser = Ingredient(stepId: 0, name: "Wasser", amount: 100, type: .bulkLiquid, number: 1)
        let step = Step(name: "Hauptteig", duration: 1800, temperature: 26, recipeId: Int64(number), number: 1)
        let mehl2 = Ingredient(stepId: 1, name: "Mehl", amount: 200, type: .flour, number: 0)
        let wasser2 = Ingredient(stepId: 1, name: "Wasser", amount: 100, type: .bulkLiquid, number: 1)
        
        return (recipe, [(sub, [mehl, wasser]), (step, [mehl2, wasser2])])
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
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let info = Column(CodingKeys.info)
        static let isFavorite = Column(CodingKeys.isFavorite)
        static let difficulty = Column(CodingKeys.difficulty)
        static let inverted = Column(CodingKeys.inverted)
        static let times = Column(CodingKeys.times)
        static let date = Column(CodingKeys.date)
        static let imageData = Column(CodingKeys.imageData)
        static let number = Column(CodingKeys.number)
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
        difficulty = row[4]
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
    
    /// steps of the recipe
    private func steps(db: Database) -> [Step] {
        (try? Step.all().orderedByNumber(with: self.id!).fetchAll(db)) ?? []
    }
    
    /// total duration of all the steps
    func totalDuration(steps: [Step]) -> Int {
        var allTimes: Int = 0
        for step in steps {
            allTimes += Int(step.duration/60)
        }
        return allTimes
    }
    
    ///starting date
    func startDate(db: Database) -> Date {
        if !inverted {
            return date
        } else {
            return date.addingTimeInterval(TimeInterval(-(totalDuration(steps: steps(db: db)) * 60)))
        }
    }
    
    ///end date
    func endDate(db: Database) -> Date {
        if inverted {
            return date
        } else {
            return date.addingTimeInterval(TimeInterval(totalDuration(steps: steps(db: db)) * 60))
        }
    }
    
    /// the startDateText for a given Step in this recipe
    func formattedStartDate(for item: Step, db: Database) -> String {
        let datesDict = startDatesDictionary(db: db)
        if let date = datesDict[item] {
            return dateFormatter.string(from: date)
        }
        return "error"
    }
    
    ///dictonary with the step and the corresponding startdate
    private func startDatesDictionary(db: Database) -> [Step : Date]{
        var dict = [Step : Date]()
        var h = startDate(db: db)
        for step in self.notSubsteps(db: db) {
            let stepDates = startDates(for: step, h: h, db: db)
            dict.append(contentsOf: stepDates.dict)
            h = stepDates.h
            
            h.addTimeInterval(step.duration)
        }
        return dict
    }
    
    ///Tuple with a start date and a startDates dictionary
    private func startDates(for step: Step, h: Date, db: Database) -> (h: Date, dict: [Step : Date]) {
        var dict = [Step : Date]()
        var h = h
        var sortedSubs = step.sortedSubsteps(db: db)
        if let first = sortedSubs.first { //get the longest sub
            sortedSubs.removeFirst() //remove so it does not get used twice
            let firstDates = startDates(for: first, h: h, db: db)
            dict.append(contentsOf: firstDates.dict)
            h = firstDates.h
            
            let subEndDate = h.addingTimeInterval(first.duration) //data when all substebs of the step should end
            for sub in sortedSubs {
                let subDates = startDates(for: sub, h: subEndDate.addingTimeInterval(-(sub.duration)), db: db)
                dict.append(contentsOf: subDates.dict)
            }
            
            h = subEndDate
        }
        dict[step] = h
        
        return (h,dict)
    }
    
    /// steps that are no substeps of any other step
    func notSubsteps(db: Database) -> [Step] {
        (try? Step.all().filterNotSubsteps(with: self.id!).fetchAll(db)) ?? []
    }
    
    //reorderSteps to make sense
    func reorderedSteps(db: Database) -> [Step] {
        var steps = [Step]()
        var number = 0
        for step in self.notSubsteps(db: db) {
            let stepReodereredSteps = step.stepsForReodering(db: db, number: number)
            steps.append(contentsOf: stepReodereredSteps.steps)
            
            number = stepReodereredSteps.number
        }
        steps = Array<Step>(Set(steps)) // make them unique
        steps.sort(by: { $0.number < $1.number })
        return steps
    }
    
    ///text for exporting
    func text(roomTemp: Double, scaleFactor: Double, kneadingHeating: Double, db: Database) -> String {
        var h = startDate(db: db)
        var text = ""
        
        for step in notSubsteps(db: db) {
            text += step.text(startDate: h, roomTemp: roomTemp, scaleFactor: scaleFactor, kneadingHeating: kneadingHeating, db: db)
            h = h.addingTimeInterval(step.duration)
        }
        text += "Fertig: \(dateFormatter.string(from: endDate(db: db)))"
        return text
    }

}
