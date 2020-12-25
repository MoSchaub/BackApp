//
//  DetailItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

public class DetailItem: TextItem {
    public var detailLabel: String
    
    public init(name: String, detailLabel: String = "" ) {
        self.detailLabel = detailLabel
        super.init(text: name)
    }
}

public class IngredientItem: DetailItem { }
public class SubstepItem: DetailItem { }
