//
//  ScheduleView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 14.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeFoundation

struct ScheduleView: View {
    
    let recipe: Recipe
    let roomTemp: Int
    let times: Decimal?
    
    @State private var showingShareSheet = false
    
    var exportButton: some View{
        Toggle(isOn: self.$showingShareSheet){
            Image(systemName: "square.and.arrow.up")
                .padding()
        }.toggleStyle(PlainToggleStyle())
            .sheet(isPresented: self.$showingShareSheet) {
                ShareSheet(activityItems: [self.recipe.text(roomTemp: self.roomTemp, scaleFactor: self.factor)])
        }
    }
    
    var factor: Double {
        let times = self.times ?? 1
        let recipeTimes = self.recipe.times ?? 1
        let devided = times/recipeTimes
        return Double.init(truncating: devided as NSNumber)
    }
    
    func customIngredientRow(ingredient: Ingredient, step: Step) -> some View{
        HStack {
            Text(ingredient.name)
            Spacer()
            if ingredient.type == .bulkLiquid{
                Text("\(step.themperature(for: ingredient, roomThemperature: roomTemp))" + "° C")
                Spacer()
            } else{
                EmptyView()
            }
            Text(ingredient.scaledFormattedAmount(with: self.factor))
        }
    }
    
    func customStepRow(step: Step) -> some View {
        VStack{
            HStack {
                Text(step.formattedName).lineLimit(1)
                Spacer()
                Text(step.formattedTime).secondary()
            }
            
            ForEach(step.ingredients){ ingredient in
                self.customIngredientRow(ingredient: ingredient, step: step)
                    .padding(.vertical, 5)
            }
            
            ForEach(step.subSteps){substep in
                HStack{
                    Text(substep.formattedName)
                    Spacer()
                    Text(substep.formattedTemp)
                    Spacer()
                    Text(substep.totalFormattedAmount)
                }
            }
            Text(step.notes)
                .lineLimit(2)
        }
        .padding()
        .clipShape(RoundedRectangle(cornerRadius: 10))
       .background(RoundedRectangle(cornerRadius: 10).fill(Color.cellBackgroundColor()))
        
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(recipe.reorderedSteps){ step in
                    self.customStepRow(step: step)
                }
                HStack {
                    Text("Fertig:")
                    Spacer()
                    Text(self.recipe.formattedEndDate)
                }.padding(.horizontal)
            }
        }
        .navigationBarTitle("Zeitplan - " + recipe.name )
        .navigationBarItems(trailing: self.exportButton)
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduleView(recipe: Recipe.complexExample, roomTemp: 20, times: 20)
                .environment(\.locale, .init(identifier: "DE"))
        }
    }
}

#if os(iOS)
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
      
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#elseif os(macOS)
struct ShareSheet: NSViewRepresentable {
    let activityItems: [Any]

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
            let picker = NSSharingServicePicker(items: activityItems)
            picker.delegate = context.coordinator

            // !! MUST BE CALLED IN ASYNC, otherwise blocks update
            DispatchQueue.main.async {
                picker.show(relativeTo: .zero, of: nsView, preferredEdge: .minY)
            }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(owner: self)
    }

    class Coordinator: NSObject, NSSharingServicePickerDelegate {
        let owner: ShareSheet

        init(owner: ShareSheet) {
            self.owner = owner
        }

        func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {

            // do here whatever more needed here with selected service

            sharingServicePicker.delegate = nil   //cleanup
        }
    }
}


#endif
