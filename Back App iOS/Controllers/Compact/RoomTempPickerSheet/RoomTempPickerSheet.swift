// Copyright © 2021 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import BackAppCore
import BakingRecipeStrings

struct RoomTempPickerSheet: View {
    
    var dissmiss:() -> Void
    
    @Binding var roomTemp: Double
    
    init(roomTemp: Binding<Double>, dissmiss: @escaping () -> Void) {
        self._roomTemp = roomTemp
        self.dissmiss = dissmiss
    }
    
    var body: some View {
        VStack {
            Text(Strings.roomTempQuestionLabel)
                .font(.title.bold())
                .padding()
            Spacer()
            Picker("", selection: $roomTemp) {
                ForEach(-10..<50) {
                    Text("\($0) °C")
                        .tag(Double($0))
                        .foregroundColor(Color(.primaryCellTextColor!))
                }
            }
            .pickerStyle(.wheel)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color(.cellBackgroundColor!))
            )
            .padding()
            Spacer()
            Button {
                dissmiss()
            }
            label: {
                Text(Strings.EditButton_Done)
                    .foregroundColor(Color(.primaryCellTextColor!))
                    .padding()
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(Color(.cellBackgroundColor!))
                    )
            }
            .padding()
        }
    }
}

//struct RoomTempPickerSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        _ = RecipeListViewController(appData: BackAppData.shared)
//        return RoomTempPickerSheet(roomTemp: Binding {
//            return Standarts.roomTemp
//        } set: {
//            Standarts.roomTemp = $0
//        }, dissmiss: {
//            print("dissmiss")
//        })
//    }
//}
