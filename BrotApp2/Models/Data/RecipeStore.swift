//
//  RecipeStore.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI
import Combine

final class RecipeStore: ObservableObject{
    
    @Published var roomThemperature = 20
    
    @Published var recipes = [Recipe](){
        didSet{
            self.update()
        }
    }
    
    func fitered(text: String)-> [Recipe]{
        recipes.filter{$0.name.lowercased().contains(text.lowercased()) || text == ""}
    }
    
    @Published var categories = [
        Category(name: "Brot", image: UIImage(named: "bread")!),
        Category(name: "brötchen", image: UIImage(named: "roll")!),
        Category(name: "kuchen", image: UIImage(named: "cake")!)
    ]
    
    private let key = "recipeStore"
    
    init() {
        if let recipeStore = UserDefaults.standard.data(forKey: key){
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(RecipeStore.self, from: recipeStore){
                self.recipes = decoded.recipes
                self.categories = decoded.categories
                self.roomThemperature = decoded.roomThemperature
                return
            }
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.recipes = try container.decode([Recipe].self, forKey: .recipes)
        self.categories = try container.decode([Category].self, forKey: .categories)
    }
    
    func update(){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self){
            UserDefaults.standard.set(encoded,forKey:key)
        }
    }

    func deleteRecipe(recipe: Recipe){
        if let index = recipes.firstIndex(where: { $0.id == recipe.id}){
            recipes.remove(at: index)
            self.update()
        }
    }
       
    func addRecipe(recipe: Recipe){
        recipes.append(recipe)
        update()
    }
    
    func edit(recipe: Recipe){
        if let index = recipes.firstIndex(where: {$0.id == recipe.id}){
            recipes[index] = recipe
            update()
        }
    }
    
    func find(step: BrotValue, in recipe: Recipe) -> (rezeptIndex: Int?, stepIndex: Int?){
        guard let rezeptIndex = self.recipes.firstIndex(of: recipe) else {
            return (nil, nil)
        }
        let recipe = self.recipes[rezeptIndex]
        guard let stepIndex = recipe.steps.firstIndex(of: step) else {
            return (rezeptIndex, nil)
        }
        return (rezeptIndex, stepIndex)
    }
    
    static var example : RecipeStore{
        let recipeStore = RecipeStore()
        recipeStore.recipes.append(Recipe.example)
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
