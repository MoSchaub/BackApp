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
    
    func controlStripItems(creating: Bool) -> [Item] {
        let appData = BackAppData()
        let infoStripItem = InfoStripItem(weighIn: appData.totalFormattedAmount(for: self.id), formattedDuration: appData.formattedTotalDurationHours(for: self.id), doughYield: appData.formattedTotalDoughYield(for: self.id))
        return creating ? [infoStripItem] : [infoStripItem, DetailItem(name: Strings.startRecipe)]
    }
    
    var stepItems: [StepItem] {
        let appData = BackAppData()
        let steps = appData.reorderedSteps(for: self.id)
        return steps.map({ StepItem(id: $0.id, step: $0)})
    }
    
    
    /// items for all steps in right order
    var allReoderedStepItems: [StepItem] {
        let appData = BackAppData()
        return appData.reorderedSteps(for: self.id).map({ StepItem(id: $0.id, step: $0)})
    }
}
