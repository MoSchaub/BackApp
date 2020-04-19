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
    
    @Published var recipes = [Recipe]()
    
    func encodedRecipes()-> Data{
        try! JSONEncoder().encode(self.recipes)
    }
    
    @Published var categories = [
        Category(name: "Brot", image: UIImage(named: "bread")!),
        Category(name: "Brötchen", image: UIImage(named: "roll")!),
        Category(name: "Kuchen", image: UIImage(named: "cake")!)
    ]
    
    var latest: [Recipe]{
        var recipes = [Recipe]()
        if self.recipes.count < 10{
            for recipe in self.recipes{
                recipes.append(recipe)
            }
        } else{
            for i in 0..<10{
                recipes.append(self.recipes[i])
            }
        }
        return recipes
    }
    
    var favourites: [Recipe]{
        self.recipes.filter({$0.isFavourite})
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.recipes = try container.decode([Recipe].self, forKey: .recipes)
        self.categories = try container.decode([Category].self, forKey: .categories)
    }
       
    func addRecipe(recipe: Recipe){
        recipes.append(recipe)
        self.write()
    }
    
    func write(){
        let data = encodedRecipes()
        
        let file = getDocumentsDirectory().appendingPathComponent("recipes.json")

        do {
            try data.write(to: file, options: .atomic)
                print("sucessfully wrote to file")
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
                return try decoder.decode([Recipe].self, from: data)
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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
