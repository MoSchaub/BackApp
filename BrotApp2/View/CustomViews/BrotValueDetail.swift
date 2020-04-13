//
//  BrotValueDetail.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 01.10.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

//struct BrotValueDetail: View {
//    
//    @EnvironmentObject private var rezeptStore: RecipeStore
//    
//    var rezept: Recipe
//    
//    var rezeptIndex: Int {
//        rezeptStore.recipes.firstIndex(where: {$0.id == rezept.id }) ?? 0
//    }
//    
//    var brotValue: BrotValue
//    
//    var brotValueIndex: Int {
//        rezeptStore.recipes[rezeptIndex].steps.firstIndex(where: {$0.id == brotValue.id }) ?? 0
//    }
//    
//    
//    
//    var body: some View {
//        VStack {
//            HStack {
//                Text(brotValue.name)
//                    .font(.title)
//                    .padding(.leading)
//                Spacer()
//            }
//            
//            HStack {
//                MOTimePicker(time: $rezeptStore.recipes[rezeptIndex].steps[brotValueIndex].time)
//                    .padding(.leading)
//                Spacer()
//            }
//            
//            HStack(alignment: .center, spacing: 10){
//                Text("Name:")
//                    .padding(.leading)
//                TextField("Name", text: $rezeptStore.recipes[rezeptIndex].steps[brotValueIndex].name).padding(.trailing).textFieldStyle(RoundedBorderTextFieldStyle())
//            }
//        }
//    }
//}
//
//struct BrotValueDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        BrotValueDetail(rezept: RecipeStore().recipes[0], brotValue: RecipeStore().recipes[0].steps[0])
//            .environmentObject(RecipeStore())
//    }
//}
