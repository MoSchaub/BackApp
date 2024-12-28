// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

public class InfoStripItem: Item, Decodable {
    public var weighIn: String
    public var formattedDuration: String
    public var doughYield: String
    
    public init(weighIn: String, formattedDuration: String, doughYield: String) {
        self.weighIn = weighIn
        self.formattedDuration = formattedDuration
        self.doughYield = doughYield
        super.init()
    }

    private enum CodingKeys: CodingKey {
        case weighIn
        case formattedDuration
        case doughYield
    }

    public required init(from decoder: Decoder) throws {
        self.weighIn = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .weighIn)
        self.formattedDuration = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .formattedDuration)
        self.doughYield = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .doughYield)
    }

}
