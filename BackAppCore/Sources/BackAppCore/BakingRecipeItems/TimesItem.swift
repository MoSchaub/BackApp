//
//  TimesItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 14.09.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

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
