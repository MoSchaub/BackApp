// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

public class DetailItem: TextItem {
    public var detailLabel: String
    
    public init(id: Int? = nil, name: String, detailLabel: String? = nil ) {
        self.detailLabel = detailLabel ?? ""
        super.init(id: id, text: name)
    }
}

public class IngredientItem: DetailItem { }
public class SubstepItem: DetailItem { }
