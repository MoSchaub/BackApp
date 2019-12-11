//
//  RezeptStore.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI
import Combine

final class RezeptStore: ObservableObject {
    @Published var rezepte = RezeptData
    
}
