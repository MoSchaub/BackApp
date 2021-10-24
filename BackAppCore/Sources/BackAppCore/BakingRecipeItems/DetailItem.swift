//
//  DetailItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

public class DetailItem: TextItem {
    public var detailLabel: String
    
    public init(id: Int? = nil, name: String, detailLabel: String? = nil ) {
        self.detailLabel = detailLabel ?? ""
        super.init(id: id, text: name)
    }
}

public class IngredientItem: DetailItem { }
public class SubstepItem: DetailItem { }
