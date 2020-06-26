//
//  RecipeStore.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

final class RecipeStore: ObservableObject{

    @Published var recipes = [Recipe](){
        didSet {
            self.write()
            if !updatingSubsteps {
                self.updateSubsteps()
            }
        }
    }
    
    @Published var roomThemperature = 20
    @Published var categories = [
        Category(name: "Brot", imageData: UIImage(named: "bread")!.jpegData(compressionQuality: 0.8)),
        Category(name: "Brötchen", imageData: UIImage(named: "roll")!.jpegData(compressionQuality: 0.8)),
        Category(name: "Kuchen", imageData: UIImage(named: "cake")!.jpegData(compressionQuality: 0.8))
    ]
    
    /// selection of RecipeDetail
    ///1: ImagePickerView
    ///2: CategoryPicker
    ///3: ScheduleForm
    ///4: AddStepView
   @Published var rDSelection: Int? = nil{
        didSet{
            #if os(macOS)
            if self.rDSelection != nil {
                self.selectedStep = nil
            }
            #endif
        }
    }

    var selectedStep: Step? = nil{
        willSet {
            #if os(macOS)
            if newValue != nil {
                self.rDSelection = nil
            }
            self.sDSelection = nil
            self.selectedIngredient = nil
            #endif
            self.objectWillChange.send()
        }
    }
    
    func selectedStepIndex() -> Int? {
        if let recipeIndex = selectedRecipeIndex(){
            return recipes[recipeIndex].steps.firstIndex(where: { $0.id == selectedStep?.id})
        }
        return nil
    }
    
    func deleteSelectedStep() {
        if let index = selectedStepIndex(), index < selectedRecipe!.steps.count {
            selectedStep = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.recipes[self.selectedRecipeIndex()!].steps.remove(at: index)
            }
            //select next
            #if os(macOS)
            if self.selectedRecipe!.steps.count > 1{
                guard let lastStep = self.recipes[self.selectedRecipeIndex()!].steps.last else { return }
                selectedStep = lastStep
            }
            #endif
        }
    }
    
    func update(recipe: Recipe) {
        if let recipeIndex = recipes.firstIndex(where: {$0.id == recipe.id }), recipes.count > recipeIndex {
            recipes[recipeIndex] = recipe
            write()
        }
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
        self.recipes.contains(where: { $0.name == recipe.name})
    }
    
    func save(recipe: Recipe){
        if !self.contains(recipe: recipe) {
            self.addRecipe(recipe: recipe)
        }
    }
    
    func delete(step: Step, from recipe: Recipe){
        if let stepIndex = recipe.steps.firstIndex(of: step), recipe.steps.count > stepIndex{
            self.selectedStep = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                if let recipeIndex = self.recipes.firstIndex(of: recipe){
                    self.recipes[recipeIndex].steps.remove(at: stepIndex)
                }
            }
        }
    }
    
    @Published var sDSelection: Int? = nil{
        didSet{
            #if os(macOS)
            if self.sDSelection != nil {
                if self.sDSelection == 1 {
                    sDShowingSubstepOrIngredientSheet = true
                }
                self.selectedIngredient = nil
            }
            #endif
        }
    }
    
    @Published var sDShowingSubstepOrIngredientSheet = false
    
    @Published var selectedIngredient: Ingredient? = nil{
        didSet{
            #if os(macOS)
            if self.selectedIngredient != nil {
                self.sDSelection = nil
            }
            #endif
        }
    }
    
    func selectedIngredientIndex() -> Int? {
        if let recipeIndex = selectedRecipeIndex(), let stepIndex = selectedStepIndex(){
            return recipes[recipeIndex].steps[stepIndex].ingredients.firstIndex(where: { $0.id == selectedIngredient?.id})
        }
        return nil
    }
    
    func deleteSelectedIngredient() {
        if let index = selectedIngredientIndex(), index < selectedStep!.ingredients.count {
            selectedIngredient = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.recipes[self.selectedRecipeIndex()!].steps[self.selectedIngredientIndex()!].ingredients.remove(at: index)
            }
            #if os(macOS)
            //select next
            if self.selectedStep!.ingredients.count > 1{
                selectedIngredient = recipes[selectedRecipeIndex()!].steps[selectedStepIndex()!].ingredients.last
            }
            #endif
        }
    }

    func save(step: Step, to recipe: Recipe){
        if !recipe.steps.contains(step){
            if let recipeIndex = self.recipes.firstIndex(of: recipe){
                self.recipes[recipeIndex].steps.append(step)
            }
        }
        #if os(macOS)
        self.selectedIngredient = nil
        self.selectedStep = nil
        self.sDSelection = nil
        self.rDSelection = nil
        #endif
    }

    func deleteIngredient(of step: Step, in recipe: Recipe) {
        if let ingredientIndex = step.ingredients.firstIndex(of: self.selectedIngredient!), step.ingredients.count > ingredientIndex {
            self.sDSelection = nil
            self.selectedIngredient = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                if let recipeIndex = self.recipes.firstIndex(of: recipe), let stepIndex = recipe.steps.firstIndex(of: step) {
                    self.recipes[recipeIndex].steps[stepIndex].ingredients.remove(at: ingredientIndex)
                }
            }
        }
    }

    
    var selectedRecipe: Recipe? = nil{
        willSet{
            #if os(macOS)
            if newValue != nil {
                self.hSelection = nil
            }
            self.rDSelection = nil
            self.selectedStep = nil
            #endif
            objectWillChange.send()
        }
    }
    
    func selectedRecipeIndex() -> Int? {
        recipes.firstIndex(where: { $0.id == selectedRecipe?.id})
    }
    
    func deleteSelectedRecipe() {
        if let index = selectedRecipeIndex(){
            deleteRecipe(at: index)
        }
    }
    
    func deleteRecipe(at index: Int) {
        if index < recipes.count {
            selectedRecipe = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.recipes.remove(at: index)
            }
            //select next
            #if os(macOS)
            if recipes.count > 1{
                guard let lastRecipe = recipes.last else { return }
                selectedRecipe = lastRecipe
            }
            #endif
        }
    }
    
    @Published var showingAddRecipeView = false
    
    @Published var newRecipePublisher = NotificationCenter.default.publisher(for: .init("addRecipe"))
    
    @Published var hSelection: Int? = nil {
        didSet{
            if self.hSelection != nil {
                self.selectedRecipe = nil
            }
        }
    }

    
    init() {
        if let recipes = load() {
            self.recipes = recipes
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.recipes = try container.decode([Recipe].self, forKey: .recipes)
        self.categories = try container.decode([Category].self, forKey: .categories)
    }
       
    func addRecipe(recipe: Recipe){
        recipes.append(recipe)
    }
    
    //- MARK: File managemnet
    
    @Published var showingInputAlert = false
    @Published var inputAlertTitle = ""
    @Published var inputAlertMessage = ""
    @Published var isArray = false
    
    func encodedRecipes()-> Data{
        try! JSONEncoder().encode(self.recipes)
    }
    
    func load<T: Decodable>(url: URL, as type: T.Type = T.self) -> T? {
        let data: Data
        
        // Make sure you release the security-scoped resource when you are done.
        do { url.stopAccessingSecurityScopedResource() }
        
        // Do something with the file here.
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("Couldn't load \(url) from main bundle:\n\(error)")
            self.inputAlertTitle = "Fehler"
            self.inputAlertMessage = error.localizedDescription
            self.showingInputAlert = true
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let decoded =  try decoder.decode(T.self, from: data)
            if let recipes = decoded as? [Recipe] {
                self.isArray = true
                for recipe in recipes{
                    if self.recipes.contains(where: {$0 == recipe}){
                        self.inputAlertTitle = "Fehler"
                        self.inputAlertMessage = "Die Datei enhält bereits existierende Rezepte"
                        self.showingInputAlert = true
                        return nil
                    }
                }
                self.inputAlertTitle = "Erfolg"
                self.inputAlertMessage = "Die Rezepte wurden importiert"
                self.showingInputAlert = true
            }
            return decoded
        } catch {
            print("Couldn't parse \(url) as \(T.self):\n\(error)")
            self.inputAlertTitle = "Fehler"
            self.inputAlertMessage = "Die Datei enhält keine Rezepte"
            self.showingInputAlert = true
            return nil
        }
    }
    
    private func write(){
        let data = encodedRecipes()
        
        let file = getDocumentsDirectory().appendingPathComponent("recipes.json")

        do {
            try data.write(to: file, options: .atomic)
            print("sucessfully wrote to \(file)")
        } catch {
            print("failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding")
        }
    }
    
    func load() -> [Recipe]? {
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
                for recipe in recipes{
                    if self.recipes.contains(where: {$0 == recipe}){
                    return nil
                    }
                }
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
        //make sure the file is up to date
        self.write()
        return getDocumentsDirectory().appendingPathComponent("recipes.json")
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static var example : RecipeStore{
        let recipeStore = RecipeStore()
        recipeStore.recipes.append(Recipe.example)
        let recipe1 = Recipe(name: "Recipe1", brotValues: [Step(name: "12", time: 600, ingredients: [], themperature: 20)], inverted: false, dateString: "", isFavourite: false, category: Category(name: "Brot"))
        recipeStore.recipes.append(recipe1)
        let recipe2 = Recipe(name: "Recipe2", brotValues: [Step(name: "12", time: 600, ingredients: [], themperature: 20)], inverted: false, dateString: "", isFavourite: false, category: Category(name: "Brot"))
        recipeStore.recipes.append(recipe2)
        let recipe3 = Recipe(name: "Recipe3", brotValues: [Step(name: "12", time: 600, ingredients: [], themperature: 20)], inverted: false, dateString: "", isFavourite: false, category: Category(name: "Brot"))
        recipeStore.recipes.append(recipe3)
        return recipeStore
    }
    
}

extension RecipeStore: Codable{
    
    enum CodingKeys: CodingKey{
        case recipes
        case categories
        case roomThemperature
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(recipes, forKey: .recipes)
        try container.encode(categories, forKey: .categories)
        try container.encode(roomThemperature, forKey: .roomThemperature)
    }
}
