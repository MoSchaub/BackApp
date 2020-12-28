//
//  RecipeStore.swift
//  
//
//  Created by Moritz Schaub on 03.10.20.
//

import BakingRecipeFoundation
import Combine
import Foundation
import BakingRecipeStrings

@available(iOS 13.0, *)
public class RecipeStore: ObservableObject {
    
    ///all recipes
    @Published private(set) public var allRecipes: [Recipe] {
        didSet {
            if oldValue != self.allRecipes {
                self.write()
            }
        }
    }
    
    @Published public var inputAlertTitle = ""
    @Published public var inputAlertMessage = ""
    
    private var deletedRecipe: Recipe?
    
    let path = FileManager.default.documentsDirectory.appendingPathComponent("recipes.bakingAppRecipe")

    public init() {
        allRecipes = [Recipe]()
        
        //load all recipes
        if let all = loadRecipes() {
            self.allRecipes = all
        }
    }
}

// MARK: - Updating Recipes, Steps and Ingredients

@available(iOS 13.0, *)
public extension RecipeStore {
    
    ///updates the recipe in the allRecipes Array
    func update(recipe: Recipe) {
        if let recipeIndex = allRecipes.firstIndex(matching: recipe), allRecipes.count > recipeIndex, allRecipes[recipeIndex] != recipe {
            allRecipes[recipeIndex] = recipe
        }
    }
    
    ///save recipe
    func save(recipe: Recipe){
        if !self.allRecipes.contains(matching: recipe) {
            self.allRecipes.append(recipe)
        } else {
            update(recipe: recipe)
        }
    }
    
    
    /// update the step in a recipe
    func update(step: Step, in recipe: Recipe) {
        if let recipeIndex = allRecipes.firstIndex(matching: recipe), allRecipes.count > recipeIndex,
           let stepIndex = allRecipes[recipeIndex].steps.firstIndex(matching: step), allRecipes[recipeIndex].steps.count > stepIndex,
           allRecipes[recipeIndex].steps[stepIndex] != step {
            allRecipes[recipeIndex].steps[stepIndex] = step
        }
    }
    
    /// move recipes for tableView
    func moveRecipe(from source: Int, to destination: Int) {
        let movedObject = allRecipes[source]
        if self.deleteRecipe(at: source) {
            allRecipes.insert(movedObject, at: destination)
        } else {
            allRecipes.insert(movedObject, at: source)
        }
    }

    ///deleteRecipe from all recipes
    func deleteRecipe(at index: Int) -> Bool {
        if index < allRecipes.count {
            
            //save deleted recipe to a var
            self.deletedRecipe = allRecipes[index]
            
            // delete recipe
            allRecipes.remove(at: index)
            return true
        }
        return false
    }
    
    /// readds the deleted recipe to the recipes
    @objc func undoDeletingRecipe() -> Bool {
        if let recipe = self.deletedRecipe {
            self.save(recipe: recipe)
            return true
        } else {
            return false
        }
    }
    
    /// save step
    func save(step: Step, to recipe: Recipe){
        if !recipe.steps.contains(matching: step), let recipeIndex = allRecipes.firstIndex(matching: recipe){
            allRecipes[recipeIndex].steps.append(step)
        } else {
            save(recipe: recipe)
            allRecipes[allRecipes.firstIndex(of: allRecipes.last!)!].steps.append(step)
        }
    }
    
    /// update the ingredient in step
    func update(ingredient: Ingredient, in step: Step) {
        if let recipeIndex = allRecipes.firstIndex(where: { $0.steps.contains(where: { s in return step.id == s.id})}), allRecipes.count > recipeIndex,
           let stepIndex = allRecipes[recipeIndex].steps.firstIndex(matching: step), allRecipes[recipeIndex].steps.count > stepIndex,
           let ingredientIndex = allRecipes[recipeIndex].steps[stepIndex].ingredients.firstIndex(matching: ingredient),
           allRecipes[recipeIndex].steps[stepIndex].ingredients.count > ingredientIndex {
            allRecipes[recipeIndex].steps[stepIndex].ingredients[ingredientIndex] = ingredient
        }
    }
    
    /// add Ingredients to a step
    func add(ingredient: Ingredient, to step: Step) {
        if let recipeIndex = allRecipes.firstIndex(where: { $0.steps.contains(where: { s in return step.id == s.id})}), allRecipes.count > recipeIndex,
              let stepIndex = allRecipes[recipeIndex].steps.firstIndex(matching: step), allRecipes[recipeIndex].steps.count > stepIndex,
              let ingredientIndex = allRecipes[recipeIndex].steps[stepIndex].ingredients.firstIndex(matching: ingredient),
              allRecipes[recipeIndex].steps[stepIndex].ingredients.count > ingredientIndex {
            allRecipes[recipeIndex].steps[stepIndex].ingredients.append(ingredient)
        }
    }
    
}


// MARK: - Loading and Saving Files

@available(iOS 13.0, *)
public extension RecipeStore {
    func exportToURL() -> URL{
        self.write() //make sure the file is up to date
        return path
    }
    /// open recipe(s) from file
    func open(_ url: URL) {
        let loaded = url.load(as: [Recipe].self) // load as [Recipe]
        if let recipes = loaded.data {
            self.allRecipes.append(contentsOf: recipes) // loading worked
            
            //set success
            self.inputAlertTitle = Strings.success
            self.inputAlertMessage = Strings.recipesImported
            return
        } else if loaded.error != nil {
            
            //error with array now try single
            let loaded = url.load(as: Recipe.self)
            if let recipe = loaded.data {
                save(recipe: recipe) //loading worked
                
                //set success
                self.inputAlertTitle = Strings.success
                self.inputAlertMessage = Strings.recipeImported
            } else if let error = loaded.error {
                
                //set error
                self.inputAlertTitle = Strings.Alert_Error
                self.inputAlertMessage = error.localizedDescription
            }
        }
    }
    
    func update() {
        if let allRecipes = self.loadRecipes() {
            for recipe in allRecipes {
                save(recipe: recipe)
            }
        }
    }
    
    static var example : RecipeStore{
        let recipeStore = RecipeStore()
        recipeStore.allRecipes.append(Recipe.example)
        let recipe1 = Recipe(name: "Recipe1", brotValues: [Step(name: "12", time: 600, ingredients: [], themperature: 20)], inverted: false, dateString: "", isFavourite: false)
        recipeStore.allRecipes.append(recipe1)
        let recipe2 = Recipe(name: "Recipe2", brotValues: [Step(name: "12", time: 600, ingredients: [], themperature: 20)], inverted: false, dateString: "", isFavourite: false)
        recipeStore.allRecipes.append(recipe2)
        let recipe3 = Recipe(name: "Recipe3", brotValues: [Step(name: "12", time: 600, ingredients: [], themperature: 20)], inverted: false, dateString: "", isFavourite: false)
        recipeStore.allRecipes.append(recipe3)
        return recipeStore
    }
    
}

@available(iOS 13.0, *)
private extension RecipeStore {
    
    ///loads recipes from json file from the app documents directory
    private func loadRecipes() -> [Recipe]? {
        if UserDefaults.standard.bool(forKey: "fileC"){ // Check if file exists
            let url = path
            return url.load(as: [Recipe].self).data
        } else {
            //create new file
            
            let filename = path
            do {
                try "".write(to: filename, atomically: true, encoding: .utf8) //write to file
                print("created file at \(filename)")
            } catch  {
                print("error creating file")
            }
            UserDefaults.standard.set(true, forKey: "fileC") //save that file was created
            
            return nil
            
        }
    }
    
    //write recipes to file
    private func write() {
        let data: Data
        let destination = path
        do {
            data = try JSONEncoder().encode(self.allRecipes)
            try data.write(to: destination, options: .atomic)
        } catch {
            print("error writing recipes to \(destination):\n\(error.localizedDescription)")
        }
    }
    
}
