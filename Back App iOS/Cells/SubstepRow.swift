//
//  SubstepRow.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 24.08.21.
//  Copyright © 2021 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BackAppCore
import BakingRecipeFoundation

public struct SubstepRow: View {

    let substep: Step
    let appData: BackAppData
    let roomTemp = Standarts.roomTemp

    public var body: some View {
        HStack {
            Text(substep.formattedName)
            Spacer()
            Text(substep.formattedTemp(roomTemp: roomTemp))
            Spacer()
            Text(appData.totalFormattedMass(for: substep.id!))
        }
    }
}
