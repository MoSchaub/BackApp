//
//  File.swift
//  
//
//  Created by Moritz Schaub on 03.10.20.
//

import Foundation
import BakingRecipeFoundation

@available(iOS 10.0, *)
public extension Recipe {
    func createFile() -> URL {
        let url = FileManager.default.documentsDirectory.appendingPathComponent("\(self.formattedName).bakingAppRecipe")
        DispatchQueue.global(qos: .userInitiated).async {
            if let encoded = try? JSONEncoder().encode(self.neutralizedForExport()) {
                do {
                    try encoded.write(to: url)
                } catch {
                    print(error)
                }
            }
        }
        return url
    }
}
