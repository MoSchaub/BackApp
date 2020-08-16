//
//  Recipe+Items.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import BakingRecipe
import Foundation

extension Recipe {
    func nameItem() -> TextFieldItem {
        TextFieldItem(text: name)
    }
    
    var imageItem: ImageItem {
        ImageItem(imageData: imageString)
    }
    
    func amountItem() -> AmountItem {
        AmountItem(text: timesText)
    }
    
    var infoItem: InfoItem {
        InfoItem(text: self.info)
    }
    
    func controlStripItems(creating: Bool) -> [Item] {
        creating ? [InfoStripItem(stepCount: steps.count, minuteCount: totalTime, ingredientCount: numberOfIngredients)] : [InfoStripItem(stepCount: steps.count, minuteCount: totalTime, ingredientCount: numberOfIngredients), DetailItem(name: NSLocalizedString("startRecipe", comment: ""), detailLabel: "")]
    }
    
    var stepItems: [StepItem] {
        steps.map({ StepItem(id: $0.id, step: $0)})
    }
}
