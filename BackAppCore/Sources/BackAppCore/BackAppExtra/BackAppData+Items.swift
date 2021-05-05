//
//  RecipeStore+Items.swift
//  
//
//  Created by Moritz Schaub on 19.12.20.
//
import BakingRecipeFoundation

public extension BackAppData {
    
    private func recipeItem(for recipe: Recipe) -> RecipeItem {
        return RecipeItem(id: recipe.id, name: recipe.formattedName, imageData: recipe.imageData, minuteLabel: self.formattedTotalDuration(for: recipe.id))
    }
    
    func getRecipesItems(favouritesOnly: Bool = false) -> [RecipeItem] {
        if favouritesOnly {
            return favorites.map { recipeItem(for: $0)}
        } else {
            return allRecipes.map { recipeItem(for: $0)}
        }
    }
    
}
