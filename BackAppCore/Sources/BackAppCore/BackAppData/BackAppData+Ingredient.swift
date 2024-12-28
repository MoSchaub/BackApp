// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  BackAppData+Ingredient.swift
//  
//
//  Created by Moritz Schaub on 23.12.20.
//

import BakingRecipeFoundation

public extension BackAppData {
    
    var allIngredients: [Ingredient] {
        allRecords()
    }
    
    func ingredients(with stepId: Int64) -> [Ingredient] {
        (try? self.databaseReader.read { db in
            try? Ingredient.all().orderedByNumber(with: stepId).fetchAll(db)
        }) ?? []
    }
    
    func moveIngredient(with stepId: Int64, from source: Int, to destination: Int) {
        self.moveRecord(in: ingredients(with: stepId), from: source, to: destination)
    }
    
}
