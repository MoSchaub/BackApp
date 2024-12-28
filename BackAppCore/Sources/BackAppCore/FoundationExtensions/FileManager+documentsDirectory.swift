// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  FileManager+documentsDirectory.swift
//  
//
//  Created by Moritz Schaub on 03.10.20.
//

import Foundation

public extension FileManager {
    var documentsDirectory: URL {
        urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
