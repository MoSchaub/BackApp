// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Double+formattedMass.swift
//  
//
//  Created by moritz on 05.06.21.
//

import Foundation

extension Double {
    public var formattedMass: String {
        return String(format: "%.1f", self) + " g"
    }
}
