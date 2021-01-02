//
//  RecipeStore+Items.swift
//  
//
//  Created by Moritz Schaub on 19.12.20.
//

import BackAppCore
import BakingRecipeFoundation
import BakingRecipeItems
import BakingRecipeStrings

public extension BackAppData {

    ///all recipes where isFavourites is true
    var favorites: [Recipe] {
        allRecipes.filter { $0.isFavorite }
    }
    
    
    // MARK: Items
    
    ///items for favourites
    var favoriteItems: [RecipeItem] {
        favorites.map { recipeItem(for: $0)}
    }
    
    private func recipeItem(for recipe: Recipe) -> RecipeItem {
        return RecipeItem(id: recipe.id, name: recipe.formattedName, imageData: recipe.imageData, minuteLabel: self.formattedTotalDuration(for: recipe.id))
    }
    
    ///items for all recipes
    var allRecipesItems: [RecipeItem] {
        allRecipes.map({ recipeItem(for: $0) })
    }
    
    var settingsItems: [TextItem] { [
        DetailItem(name: Strings.roomTemperature, detailLabel: "\(Standarts.roomTemp)° C"),
        TextItem(text: Strings.importFile),
        TextItem(text: Strings.exportAll),
        DetailItem(name: Strings.about)
    ]}

}
