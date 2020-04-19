//
//  Data.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 30.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import Foundation

//let RezeptData: [Recipe] = load("Rezepte.json")

func load<T: Decodable>(url: URL, as type: T.Type = T.self) -> T? {
    let data: Data
    
    // Also start accessing the content's security-scoped URL.
    guard url.startAccessingSecurityScopedResource() else {
        print("error accessing the file")
        return nil
    }
    
    // Make sure you release the security-scoped resource when you are done.
    do { url.stopAccessingSecurityScopedResource() }
    
    // Do something with the file here.
    do {
        data = try Data(contentsOf: url)
    } catch {
        print("Couldn't load \(url) from main bundle:\n\(error)")
        return nil
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        print("Couldn't parse \(url) as \(T.self):\n\(error)")
        return nil
    }
}


