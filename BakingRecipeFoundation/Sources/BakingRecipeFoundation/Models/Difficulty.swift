//
//  Difficulty.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 01.07.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

public enum Difficulty: Int, CaseIterable, Codable {
    case easy = 0
    case medium = 1
    case hard = 2
}
