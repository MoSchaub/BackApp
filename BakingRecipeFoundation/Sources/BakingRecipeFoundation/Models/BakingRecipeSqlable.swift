//
//  BakingRecipeSqlable.swift
//  
//
//  Created by Moritz Schaub on 23.12.20.
//

import Sqlable

///combination of Sqlable with the common features of Recipe, Step and Ingredient
public protocol BakingRecipeSqlable: Sqlable, Identifiable, Codable, Hashable {
    var id: Int { get set }
    var name: String { get set }
    static var id: Column { get }
    static var name: Column { get }
}
