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
        (try? Ingredient.read().filter(.equalsValue(Ingredient.stepId, stepId)).run(database)) ?? []
    }
    
}
