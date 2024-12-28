// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

public class TimesItem: Item, Decodable {
    public var decimal: Decimal?
    
    public init(decimal: Decimal?) {
        self.decimal = decimal
        super.init()
    }

    public required init(from decoder: Decoder) throws {
        self.decimal = try decoder.container(keyedBy: CodingKeys.self).decodeIfPresent(Decimal.self, forKey: .decimal)
    }

    enum CodingKeys: CodingKey {
        case decimal
    }
}
