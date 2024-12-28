// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import GRDB

public enum Difficulty: Int, CaseIterable, Codable {
    case easy = 0
    case medium = 1
    case hard = 2
}
