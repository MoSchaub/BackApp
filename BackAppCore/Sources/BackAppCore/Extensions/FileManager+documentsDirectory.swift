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
