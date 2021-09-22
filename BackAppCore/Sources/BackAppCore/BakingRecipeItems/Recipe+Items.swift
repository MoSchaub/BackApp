//
//  Recipe+Items.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import BakingRecipeFoundation
import BakingRecipeStrings

public extension Recipe {
    func nameItem() -> TextFieldItem {
        TextFieldItem(text: name)
    }
    
    var imageItem: ImageItem {
        ImageItem(imageData: imageData)
    }
    
    func amountItem() -> AmountItem {
        AmountItem(text: timesText)
    }
    
    var infoItem: InfoItem {
        InfoItem(text: self.info)
    }
    
    ///create an RecipeItem from an recipe
    func item(appData: BackAppData) -> RecipeItem {
        return RecipeItem(id: self.id!, name: self.formattedName, imageData: self.imageData, minuteLabel: self.totalDuration(reader: appData.databaseReader).formattedDuration)
    }
    
    /// an ``InfoStripItem`` with the recipes formatted Values
    /// - Parameter appData: database interfacefor accessing the recipes formatted Values
    func infoStripItem(appData: BackAppData) -> Item {
        InfoStripItem(weighIn: appData.totalFormattedAmount(for: self.id!), formattedDuration: appData.formattedTotalDurationHours(for: self.id!), doughYield: appData.formattedTotalDoughYield(for: self.id!))
    }
    
    func stepItems(appData: BackAppData) -> [StepItem] {
        let steps = appData.reorderedSteps(for: self.id!)
        return steps.map({ StepItem(id: $0.id!, step: $0)})
    }

    /// items for all steps in right order
    func allReoderedStepItems(appData: BackAppData) -> [StepItem] {
        appData.reorderedSteps(for: self.id!).map({ StepItem(id: $0.id!, step: $0)})
    }
}
