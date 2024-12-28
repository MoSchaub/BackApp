// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  URL+load.swift
//  
//
//  Created by Moritz Schaub on 03.10.20.
//

import Foundation

extension URL {
    ///loads a file at a given url and decodes it to specified type
    func load<T: Decodable>(as type: T.Type = T.self) -> (data: T?, error: Error?) {
        let data: Data
        let decodedData: T
        
        // read data from url
        do {
            let _ = self.startAccessingSecurityScopedResource() // start the security-scoped resource before reading the file
            data = try Data(contentsOf: self)
            self.stopAccessingSecurityScopedResource() // release the security-scoped resource after the data is read from the file
        } catch {
            print("Couldn't load \(self) from main bundle:\n\(error)")
            return (nil, error)
        }
        
        //decode the data
        do {
            let decoder = JSONDecoder()
            decodedData = try decoder.decode(T.self, from: data)
        } catch {
            print("Couldn't decode data to Type \(T.self):\n\(error)")
            return (nil, error)
        }
        
        // return decoded Data
        return (decodedData, nil)
    }
    
    ///loads data from the url
    /// - returns: the loaded data and the potential error 
    func loadData() -> (data: Data?, error: Error?) {
        let data: Data
        
        // read data from url
        do {
            let _ = self.startAccessingSecurityScopedResource() // start the security-scoped resource before reading the file
            data = try Data(contentsOf: self)
            self.stopAccessingSecurityScopedResource() // release the security-scoped resource after the data is read from the file
        } catch {
            print("Couldn't load \(self) from main bundle:\n\(error)")
            return (nil, error)
        }
        
        return (data, nil)
    }
}
