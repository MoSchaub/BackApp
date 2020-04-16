//
//  ScheduleView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 14.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct ScheduleView: View {
    
    let recipe: Recipe
    let roomTemp: Int
    
    @State private var showingShareSheet = false
    
    var exportButton: some View{
        Toggle(isOn: self.$showingShareSheet){
            Image(systemName: "square.and.arrow.up")
        }.toggleStyle(NeomorphicToggleStyle())
            .sheet(isPresented: self.$showingShareSheet) {
                ShareSheet(activityItems: [self.recipe.text(roomTemp: self.roomTemp)])
        }
    }
    
    func customStepRow(step: Step) -> some View {
        VStack{
            HStack {
                VStack {
                    Text(step.name).font(.headline)
                    Text(step.formattedTime).secondary()
                }
                Spacer()
                Text(recipe.formattedStartDate(for: step))
            }.padding(.horizontal)
            
            
            ForEach(step.ingredients){ ingredient in
                HStack{
                    IngredientRow(ingredient: ingredient, step: step, roomTemp: self.roomTemp, inLink: false, background: false)
                }.padding([.top, .leading, .trailing])
            }
            
            ForEach(step.subSteps){substep in
                HStack{
                    Text(substep.name)
                    Spacer()
                    Text("\(substep.totalAmount)")
                }.padding(.horizontal)
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(step.notes)
                        .lineLimit(nil)
                    Spacer()
                }
            }.padding([.horizontal,.top])
        }.neomorphic()
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(recipe.steps){ step in
                    self.customStepRow(step: step)
                }
                HStack {
                    Text("Fertig:")
                    Spacer()
                    Text(self.recipe.formattedEndDate)
                }.padding(.horizontal)
                    .neomorphic()
            }
        }
        .navigationBarTitle("Zeitplan - " + recipe.name )
        .navigationBarItems(trailing: self.exportButton)
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduleView(recipe: Recipe.example, roomTemp: 20)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
      
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil
      
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
      
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}
