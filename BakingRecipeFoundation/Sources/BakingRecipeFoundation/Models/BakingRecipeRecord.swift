//
//  BakingRecipeRecord.swift
//  
//
//  Created by Moritz Schaub on 23.12.20.
//

import GRDB

///combination of Record Protocols with the common features of Recipe, Step and Ingredient
@available(iOS 13, *)
public protocol BakingRecipeRecord: Identifiable, Hashable, Encodable, MutablePersistableRecord, FetchableRecord {
    var id: Int64? { get set }
    var name: String { get set }
    var number: Int {get set}
}
