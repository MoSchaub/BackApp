//
//  File.swift
//  
//
//  Created by Moritz Schaub on 24.12.20.
//
//
//import BakingRecipeFoundation
//import Foundation
//import Sqlable
//
//extension Recipe: Codable {
//    public func createFile() -> URL {
//        //create the url for the recipe
//        let url = FileManager.default.documentsDirectory.appendingPathComponent("\(self.formattedName).bakingAppRecipe")
//        DispatchQueue.global(qos: .userInitiated).async {
//            //encode the recipe
//            if let encoded = try? JSONEncoder().encode(self.neutralizedForExport()) {
//                do {
//                    try encoded.write(to: url)
//                } catch {
//                    print(error)
//                }
//            }
//        }
//        return url
//    }
//    
//    
//    public static func create(from decoder: Decoder, database: SqliteDatabase) -> Recipe throws {
//        self.id = 1
//        self.isFavorite = false
//        self.inverted = false
//        self.date = Date()
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.name = try container.decode(String.self, forKey: .name)
//        self.info = try container.decode(String.self, forKey: .info)
//        self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
//        self.times = try container.decodeIfPresent(Decimal.self, forKey: .times) ?? Decimal(integerLiteral: 1)
//        self.imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
//        
//        //TODO: Decode the steps and ingredients and insert all into the Database
//        //steps decoded
//        let steps = try container.decode([Step].self, forKey: .steps)
//        
//        steps.map { $0.insert().run(database)}
//        
//    }
//    
//        enum CodingKeys: CodingKey {
//            case name
//            case info
//            case steps
//            case imageData
//            case difficulty
//            case times
//        }
//}
