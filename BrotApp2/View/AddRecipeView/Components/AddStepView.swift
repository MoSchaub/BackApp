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
    
    let roomTemp: Int
    
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
        }.alert(isPresented: self.$warningAlertShown) {
            Alert(title: Text("Achtung"), message: Text("Dieser Schritt wird nicht gespeichert"), primaryButton: .default(Text("OK"), action: {
                self.presentationMode.wrappedValue.dismiss()
            }), secondaryButton: .cancel())
        }
    }
    
    var saveButton: some View {
        Button(action: {
            self.save()
        }){
            Text("Speichern")
        }
    }
    
    var body: some View {
        StepDetail(recipe: self.$recipe, step: self.$step, deleteEnabled: false)
            .environmentObject(self.recipeStore)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: self.backButton, trailing: self.saveButton)
    }
    
    func save(){
        self.recipe.steps.append(self.step)
        self.recipeStore.rDSelection = nil
    }
    
}

struct AddStepsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddStepView(recipe: .constant(Recipe.example), roomTemp: 20)
        }
    }
}
