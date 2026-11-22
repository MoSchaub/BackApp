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

/// A detail item for a fixed row, e. g. "add step" or "temperature".
/// Code should check `role` to tell the rows apart, since `text` is localized.
public class RoleDetailItem<Role: Equatable>: DetailItem {
    public let role: Role

    public init(role: Role, name: String, detailLabel: String? = nil) {
        self.role = role
        super.init(name: name, detailLabel: detailLabel)
    }
}
