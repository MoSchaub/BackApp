//
//  RecipeStore.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI
import Combine
import BakingRecipe

final class RecipeStore: ObservableObject{

    @Published private(set) var recipes = [Recipe](){
        didSet {
            self.write()
            if !updatingSubsteps {
                self.updateSubsteps()
            }
        }
    }
    
    var recipeItems: [RecipeItem] {
        self.recipes.map({ RecipeItem(id: $0.id, name: $0.formattedName, imageData: $0.imageString, minuteLabel: $0.formattedTotalTime)})
    }
    
    var settingsItems: [TextItem] { [
        DetailItem(name: Strings.roomTemperature, detailLabel: "\(self.roomTemperature)° C"),
        TextItem(text: Strings.importFile),
        TextItem(text: Strings.exportAll),
        DetailItem(name: Strings.about)
    ]}
    
    var roomTemperature: Int {
        get {
            if let int = UserDefaults.standard.object(forKey: Strings.roomTempKey) as? Int {
                return int
            } else {
                UserDefaults.standard.set(20, forKey: Strings.roomTempKey)
                return 20
            }
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Strings.roomTempKey)
        }
    }
    
    
    /// selection of RecipeDetail
    ///1: ImagePickerView
    ///2: CategoryPicker
    ///3: ScheduleForm
    ///4: AddStepView
   
    
    func update(recipe: Recipe) {
        if let recipeIndex = recipes.firstIndex(where: {$0.id == recipe.id }), recipes.count > recipeIndex {
            recipes[recipeIndex] = recipe
            write()
        }
    }
    
    func update(step: Step, in recipe: Recipe) {
        if let recipeIndex = recipes.firstIndex(where: {recipe.id == $0.id })/*, recipes.count > recipeIndex*/ {
            if let stepIndex = recipes[recipeIndex].steps.firstIndex(where: {$0.id == step.id }) {
                recipes[recipeIndex].steps[stepIndex] = step
            }
        }
    }
    
    private func find(_ ingredient: Ingredient, in step: Step, creating: Bool = false) -> (recipeIndex: Int, stepIndex: Int, ingredientIndex: Int)? {
        if let recipeIndex = recipes.firstIndex(where: { $0.steps.contains(where: { s in
            return step.id == s.id})}) {
            if recipes.count > recipeIndex, let stepIndex = recipes[recipeIndex].steps.firstIndex(where: {$0.id == step.id }) {
                if recipes[recipeIndex].steps.count > stepIndex {
                    if creating {
                        return (recipeIndex, stepIndex, -1)
                    }
                    if let ingredientIndex = recipes[recipeIndex].steps[stepIndex].ingredients.firstIndex(where: { $0.id == ingredient.id }) {
                    if ingredientIndex < recipes[recipeIndex].steps[stepIndex].ingredients.count {
                        return (recipeIndex, stepIndex, ingredientIndex)
                    }
                    }
                }
            }
        }
        return nil
    }
    
    func update(ingredient: Ingredient, step: Step) {
        if let indices = find(ingredient, in: step) {
            recipes[indices.recipeIndex].steps[indices.stepIndex].ingredients[indices.ingredientIndex] = ingredient
        }
    }
    
    func add(ingredient: Ingredient, step: Step) {
        if let indices = find(ingredient, in: step, creating: true) {
            recipes[indices.recipeIndex].steps[indices.stepIndex].ingredients.append(ingredient)
        }
    }
    
    func stepForUpdate(oldStep: Step, in recipe: Recipe) -> Step {
        if let recipeIndex = recipes.firstIndex(where: {recipe.id == $0.id }){
            if let stepIndex = recipes[recipeIndex].steps.firstIndex(where: {$0.id == oldStep.id }) {
                return recipes[recipeIndex].steps[stepIndex]
            }
        }
        return oldStep
    }
    
    private var updatingSubsteps = false
    
    private func updateSubsteps() {
        if !updatingSubsteps{
            updatingSubsteps = true
            for recipeIndex in recipes.indices where recipes[recipeIndex].steps.contains(where: {!$0.subSteps.isEmpty}) { //recipes where a step has an substeps
                let recipe = recipes[recipeIndex]
                for stepIndex in recipe.steps.indices where !recipe.steps[stepIndex].subSteps.isEmpty {
                    let step = recipe.steps[stepIndex]
                    for substepIndex in step.subSteps.indices {
                        if let original = recipe.steps.first(where: {$0.name == step.subSteps[substepIndex].name}) {
                            recipes[recipeIndex].steps[stepIndex].subSteps[substepIndex] = original
                        }
                        
                    }
                }
            }
        }
        updatingSubsteps = false
    }
    
    func contains(recipe: Recipe) -> Bool {
        self.recipes.contains(where: { $0.id == recipe.id})
    }
    
    func save(recipe: Recipe){
        if !self.contains(recipe: recipe) {
            self.addRecipe(recipe: recipe)
        } else {
            update(recipe: recipe)
        }
    }
   
    func save(step: Step, to recipe: Recipe){
        if !recipe.steps.contains(where: { step.id == $0.id }) {
            if let recipeIndex = self.recipes.firstIndex(where: { $0.id == recipe.id }){
                recipes[recipeIndex].steps.append(step)
            } else {
                save(recipe: recipe)
                recipes[recipes.firstIndex(of: recipes.last!)!].steps.append(step)
            }
        }
    }

//    func deleteIngredient(of step: Step, in recipe: Recipe) {
//        if let ingredientIndex = step.ingredients.firstIndex(of: self.selectedIngredient!), step.ingredients.count > ingredientIndex {
//            self.sDSelection = nil
//            self.selectedIngredient = nil
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
//                if let recipeIndex = self.recipes.firstIndex(of: recipe), let stepIndex = recipe.steps.firstIndex(of: step) {
//                    self.recipes[recipeIndex].steps[stepIndex].ingredients.remove(at: ingredientIndex)
//                }
//            }
//        }
//    }
    
    func moveRecipe(from source: Int, to destination: Int) {
        let movedObject = recipes[source]
        if self.deleteRecipe(at: source) {
            recipes.insert(movedObject, at: destination)
        } else {
            recipes.insert(movedObject, at: source)
        }
    }

    func deleteRecipe(at index: Int) -> Bool {
        if index < recipes.count {
            recipes.remove(at: index)
            return true
        }
        return false
    }
    
    init() {
        if let recipes = load() {
            self.recipes = recipes
        }
    }

    private func addRecipe(recipe: Recipe){
        recipes.append(recipe)
    }
    
    //- MARK: File managemnet
    
    func update() {
        if let recipes = load() {
            for recipe in recipes {
                save(recipe: recipe)
            }
        }
    }
    
    @Published var inputAlertTitle = ""
    @Published var inputAlertMessage = ""
    @Published var isArray = false
    
    func encodedRecipes()-> Data{
        try! JSONEncoder().encode(self.recipes)
    }
    
    func open(_ url: URL) {
        if let recipes = load(url: url, as: [Recipe].self) {
            self.recipes.append(contentsOf: recipes)
        } else if !isArray, let recipe = load(url: url, as: Recipe.self) {
            save(recipe: recipe)
        }
        isArray = false
    }
    
    private func load<T: Decodable>(url: URL, as type: T.Type = T.self) -> T? {
        let data: Data
        
        // read data from url
        do {
            let _ = url.startAccessingSecurityScopedResource() // start the security-scoped resource before reading the file
            data = try Data(contentsOf: url)
            url.stopAccessingSecurityScopedResource() // release the security-scoped resource after the data is read from the file
        } catch {
            print("Couldn't load \(url) from main bundle:\n\(error)")
            self.inputAlertTitle = Strings.Alert_Error
            self.inputAlertMessage = error.localizedDescription
            return nil
        }
        
        // decode the data
        do {
            let decoder = JSONDecoder()
            let decoded =  try decoder.decode(T.self, from: data)
            if let recipes = decoded as? [Recipe] {
                self.isArray = true
                for recipe in recipes{
                    if self.recipes.contains(where: {$0 == recipe}) {
                        self.inputAlertTitle = Strings.Alert_Error
                        self.inputAlertMessage = Strings.recipe_already_exist_error
                        return nil
                    }
                }
                self.inputAlertTitle = "Erfolg"
                self.inputAlertMessage = "Die Rezepte wurden importiert"
            }
            // return decoded data 
            return decoded
        } catch {
            print("Couldn't parse \(url) as \(T.self):\n\(error)")
            self.inputAlertTitle = "Fehler"
            self.inputAlertMessage = "Die Datei enhält keine Rezepte"
            return nil
        }
    }
    
    private func write(){
        let data = encodedRecipes()
        
        let file = getDocumentsDirectory().appendingPathComponent("recipes.json")

        do {
            try data.write(to: file, options: .atomic)
        } catch {
            print("failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding")
        }
    }
    
    private func load() -> [Recipe]? {
        let data: Data
        
        if UserDefaults.standard.bool(forKey: "fileC"){
            // Do something with the file here.
            let url = getDocumentsDirectory().appendingPathComponent("recipes.json")
            do {
                data = try Data(contentsOf: url)
            } catch {
                print("Couldn't load \(url) from main bundle:\n\(error)")
                return nil
            }
            
            do {
                let decoder = JSONDecoder()
                print("suceesfully loaded file")
                let recipes = try decoder.decode([Recipe].self, from: data)
                return recipes
            } catch {
                print("Couldn't parse \(url) as \([Recipe].self):\n\(error)")
                return nil
            }
            
        } else {
            //create file
            let filename = getDocumentsDirectory().appendingPathComponent("recipes.json")
            do {
                try "".write(to: filename, atomically: true, encoding: .utf8)
                print("created file at \(filename)")
            } catch  {
                print("error creating file")
            }
            UserDefaults.standard.set(true, forKey: "fileC")
            
            return nil
        }
    }
    
    func exportToUrl() -> URL{
        DispatchQueue.global(qos: .userInitiated).async {
            //make sure the file is up to date
            self.write()
        }
        return getDocumentsDirectory().appendingPathComponent("recipes.json")
        
    }
    
    
    
    static var example : RecipeStore{
        let recipeStore = RecipeStore()
        recipeStore.recipes.append(Recipe.example)
        let recipe1 = Recipe(name: "Recipe1", brotValues: [Step(name: "12", time: 600, ingredients: [], themperature: 20)], inverted: false, dateString: "", isFavourite: false)
        recipeStore.recipes.append(recipe1)
        let recipe2 = Recipe(name: "Recipe2", brotValues: [Step(name: "12", time: 600, ingredients: [], themperature: 20)], inverted: false, dateString: "", isFavourite: false)
        recipeStore.recipes.append(recipe2)
        let recipe3 = Recipe(name: "Recipe3", brotValues: [Step(name: "12", time: 600, ingredients: [], themperature: 20)], inverted: false, dateString: "", isFavourite: false)
        recipeStore.recipes.append(recipe3)
        return recipeStore
    }
    
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
