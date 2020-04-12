//
//  ImageChooser.swift
//  
//
//  Created by Moritz Schaub on 13.12.19.
//

import SwiftUI

struct ImageChooser: View {

    @State var showAction: Bool = false
    @State var showImagePicker: Bool = false
    
    @EnvironmentObject private var rezeptStore: RezeptStore
    
    var rezept: Rezept

    var rezeptIndex: Int {
           rezeptStore.rezepte.firstIndex(where: {$0.id == rezept.id }) ?? 0
    }

    var sheet: ActionSheet {
        ActionSheet(
            title: Text("Bild ändern?").font(.headline),
            message: Text("am besten funktionieren quatratische Bilder"),
            buttons: [
                .default(Text("ändern"), action: {
                    self.showAction = false
                    self.showImagePicker = true
                }),
                .cancel(Text("Abbrechen"), action: {
                    self.showAction = false
                }),
                .destructive(Text("Löschen"), action: {
                    self.showAction = false
                    self.rezeptStore.rezepte[self.rezeptIndex].image = nil
                })
            ])

    }


    var body: some View {
        VStack {

            if (rezeptStore.rezepte[rezeptIndex].image == nil) {
                Image(systemName: "camera.on.rectangle")
                    .accentColor(Color.purple)
                    .background(
                        Color.gray
                            .frame(width: 100, height: 100)
                            .cornerRadius(6))
                    .onTapGesture {
                        self.showImagePicker = true
                    }
            } else {
                Image(uiImage: rezeptStore.rezepte[rezeptIndex].image!)
                    .resizable()
                    .frame(width: 300, height: 300)
                    .cornerRadius(6)
                    .onTapGesture {
                        self.showAction = true
                    }
            }

        }

        .sheet(isPresented: $showImagePicker, onDismiss: {
            self.showImagePicker = false
        }, content: {
            ImagePicker(isShown: self.$showImagePicker, uiImage: self.$rezeptStore.rezepte[self.rezeptIndex].image)
        })

        .actionSheet(isPresented: $showAction) {
            sheet
        }
    }
}

struct LibraryImage_Previews: PreviewProvider {
    static var previews: some View {
        ImageChooser(rezept: RezeptData[0]).environmentObject(RezeptStore())
    }
}
