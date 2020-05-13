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
    
    #if os(macOS)
    @Published var categories = [
        Category(name: "Brot", image: NSImage(named: "bread")!),
        Category(name: "Brötchen", image: NSImage(named: "roll")!),
        Category(name: "Kuchen", image: NSImage(named: "cake")!)
    ]
    #elseif os(iOS)
    @Published var categories = [
        Category(name: "Brot", image: UIImage(named: "bread")!),
        Category(name: "Brötchen", image: UIImage(named: "roll")!),
        Category(name: "Kuchen", image: UIImage(named: "cake")!)
    ]
    #endif
    
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
    
    @Published var isArray = false
    
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
    
    //- MARK: File managemnet
    
    @Published var showingInputAlert = false
    @Published var inputAlertTitle = ""
    @Published var inputAlertMessage = ""
    
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
    
    func write(){
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

@available(iOS 13.0, *)
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
