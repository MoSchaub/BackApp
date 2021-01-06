//
//  BackAppData+Ingredient.swift
//  
//
//  Created by Moritz Schaub on 23.12.20.
//

import BakingRecipeFoundation

public extension BackAppData {
    
    var allIngredients: [Ingredient] {
        (try? Ingredient.read().run(database)) ?? []
    }
    
    func ingredients(with stepId: Int) -> [Ingredient] {
        (try? Ingredient.read().filter(.equalsValue(Ingredient.stepId, stepId)).orderBy(Ingredient.number, .asc) .run(database)) ?? []
    }
    
    func moveIngredient(with stepId: Int, from source: Int, to destination: Int) {
        
        var ingredientIdsArray = ingredients(with: stepId).map { $0.id }
        let removedObject = ingredientIdsArray.remove(at: source)
        ingredientIdsArray.insert(removedObject, at: destination)
        
        var number = 0
        for id in ingredientIdsArray {
            var object = self.object(with: id, of: Ingredient.self)!
            object.number = number
            number += 1
            _ = self.update(object)
        }
        
    }
    
}
