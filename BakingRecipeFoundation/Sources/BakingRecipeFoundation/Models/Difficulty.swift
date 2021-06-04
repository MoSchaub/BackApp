//
//  Difficulty.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 01.07.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation
import GRDB

public enum Difficulty: Int, CaseIterable, Codable, DatabaseValueConvertible  {
    case easy = 0
    case medium = 1
    case hard = 2
}
