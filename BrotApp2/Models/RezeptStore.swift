//
//  RezeptStore.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import Foundation

func rezeptData() -> [Rezept] {
    let file = Bundle.main.url(forResource: "rezeptData.json", withExtension: nil)
    let data = try! Data(contentsOf: file!)
    return try! JSONDecoder().decode([Rezept].self, from: data )
}


class RezptStore: ObservableObject {
    @Published var rezepte = rezeptData
    
}
