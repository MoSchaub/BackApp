//
//  RecipeStore+Items.swift
//  
//
//  Created by Moritz Schaub on 19.12.20.
//

import BakingRecipeItems
import BakingRecipeCore
import BakingRecipeFoundation

@available(iOS 13, *)
public extension RecipeStore {

    ///all recipes where isFavourites is true
    var favorites: [Recipe] {
        allRecipes.filter { $0.isFavourite }
    }
    
    
    // MARK: Items
    
    ///items for favourites
    var favoriteItems: [RecipeItem] {
        favorites.map { RecipeItem(id: $0.id, name: $0.name, imageData: $0.imageString, minuteLabel: $0.formattedTotalTime)}
    }
    
    ///items for all recipes
    var allRecipesItems: [RecipeItem] {
        allRecipes.map({ RecipeItem(id: $0.id, name: $0.formattedName, imageData: $0.imageString, minuteLabel: $0.formattedTotalTime)})
    }
    
    var settingsItems: [TextItem] { [
        DetailItem(name: Strings.roomTemperature, detailLabel: "\(Standarts.standardRoomTemperature)° C"),
        TextItem(text: Strings.importFile),
        TextItem(text: Strings.exportAll),
        DetailItem(name: Strings.about)
    ]}

}
