//
//  AddStepView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 12.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

#if os(macOS)

typealias UIScreen = NSRect

extension NSRect{
    static var main: NSRect{
       NSScreen.main!.visibleFrame
    }
    
    var bounds : CGRect{
        self
    }
    
    
}

struct EditButton: View{
    var body: some View{
        EmptyView()
    }
}

extension View{
    func navigationBarBackButtonHidden(_ hidesBackButton: Bool) -> some View {
        self
    }
    
    func navigationBarItems<L, T>(leading: L, trailing: T) -> some View where L : View, T : View{
       
        self
        //TODO: add Buttons
    }
    
    func navigationBarItems<T>(trailing: T) -> some View where T : View{
       
        self
        //TODO: add Buttons
    }
    
    func navigationBarItems<L>(leading: L) -> some View where L : View{
       
        self
        //TODO: add Buttons
    }
    

    func navigationBarTitle(_ titleKey: String) -> some View {
        self
    }
    func navigationBarTitle(_ title: Text, displayMode: NavigationBarItem.TitleDisplayMode) -> some View {
        self
    }
    
    func navigationBarHidden(_ hidden: Bool) -> some View{
        self
    }
    
}

struct NavigationBarItem {
    enum TitleDisplayMode {
        case inline
    }
}

extension Image{
    init(systemName: String) {
        self = Image(nsImage: NSImage(named: systemName) ?? NSImage())
    }
}

#endif

struct AddStepView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var recipeStore: RecipeStore
    @Binding var recipe: Recipe
    @State private var step = Step(name: "", time: 60, ingredients: [], themperature: 20)
    @State private var warningAlertShown = false

    var backButton: some View{
        Button(action: {
            self.warningAlertShown = true
        }) {
            HStack{
                Image(systemName: "chevron.left")
                Text("zurück")
            }
        }.alert(isPresented: $warningAlertShown) {
            Alert(title: Text("Achtung"), message: Text("Dieser Schritt wird nicht gespeichert"), primaryButton: .default(Text("OK"), action: {
                self.presentationMode.wrappedValue.dismiss()
            }), secondaryButton: .cancel())
        }
    }
    
    var saveButton: some View {
        Button(action: save){
            Text("Speichern")
        }.disabled(recipe.steps.contains(where: {$0.name == self.step.name}))
    }
    
    var body: some View {
        StepDetail(recipe: $recipe, step: $step, creating: true)
            .environmentObject(recipeStore)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton, trailing: saveButton)
    }
    
    func save(){
        recipeStore.save(step: step, to: recipe)
        self.recipeStore.rDSelection = nil
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

struct AddStepsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddStepView(recipe: .constant(Recipe.example))
        }
    }
}
