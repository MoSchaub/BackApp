//
//  Recipe+Items.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import BakingRecipeFoundation
import BakingRecipeStrings
import GRDB

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
    
    /// an ``InfoStripItem`` with the recipes formatted Values
    /// - Parameter appData: database interfacefor accessing the recipes formatted Values
    func infoStripItem(appData: BackAppData) -> Item {
        InfoStripItem(weighIn: appData.totalFormattedAmount(for: self.id!), formattedDuration: appData.totalCompactFormattedDuration(for: self.id!), doughYield: appData.formattedTotalDoughYield(for: self.id!))
    }

    internal func infoStripItem(db: Database) throws -> InfoStripItem {
        InfoStripItem(weighIn: try self.formattedTotalAmount(db: db), formattedDuration: try self.compactFormattedTotalDuration(db: db), doughYield: try self.formattedTotalDoughYield(db: db))
    }

    internal func stepItems(db: Database) throws -> [StepItem] {
        try self.reoderedSteps(db: db).map { StepItem(step: $0) }
    }
    
    func stepItems(appData: BackAppData) -> [StepItem] {
        let steps = appData.reorderedSteps(for: self.id!)
        return steps.map({ StepItem(step: $0)})
    }

    /// items for all steps in right order
    func allReoderedStepItems(appData: BackAppData) -> [StepItem] {
        appData.reorderedSteps(for: self.id!).map{ StepItem(step: $0) }
    }
}
