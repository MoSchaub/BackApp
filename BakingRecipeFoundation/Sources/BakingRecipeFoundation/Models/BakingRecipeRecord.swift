// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  BakingRecipeRecord.swift
//  
//
//  Created by Moritz Schaub on 23.12.20.
//

import GRDB

///combination of Record Protocols with the common features of Recipe, Step and Ingredient
/// - Note: `Sendable` as recommended by GRDB 7: records cross concurrency
///   domains every time they are passed into or out of a `read`/`write`
///   closure or a `ValueObservation.tracking` closure (which is `@Sendable`
///   in GRDB 7). All conformers are plain value types, so the compiler
///   verifies this for free.
@available(iOS 13, *)
public protocol BakingRecipeRecord: Identifiable, Hashable, Codable, Sendable, MutablePersistableRecord, FetchableRecord {
    var id: Int64? { get set }
    var name: String { get set }
    var number: Int {get set}
}
