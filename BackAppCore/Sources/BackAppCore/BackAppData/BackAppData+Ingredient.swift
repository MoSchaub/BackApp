//
//  BackAppData+Ingredient.swift
//  
//
//  Created by Moritz Schaub on 23.12.20.
//

import BakingRecipeFoundation

public extension BackAppData {
    
    var allIngredients: [Ingredient] {
        allObjects()
    }
    
    func ingredients(with stepId: Int) -> [Ingredient] {
        allObjects(filter: .equalsValue(Ingredient.stepId, stepId))
    }
    
    func moveIngredient(with stepId: Int, from source: Int, to destination: Int) {
        self.moveObject(in: ingredients(with: stepId), from: source, to: destination)
    }
    
}
