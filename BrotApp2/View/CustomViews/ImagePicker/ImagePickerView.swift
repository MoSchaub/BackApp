//
//  ImagePickerView.swift
//  KAS4Elderly
//
//  Created by Moritz Schaub on 24.02.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct ImagePickerView: View {
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @Binding var inputImage: UIImage?
    
    var image: some View {
        get{
            Group{
                if inputImage == nil{
                    LinearGradient(gradient: Gradient(colors: [Color.init(.secondarySystemBackground),Color.primary]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .mask(Image( "bread").resizable().scaledToFit())
                        .frame(height: 250)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.init(.secondarySystemBackground),Color.init(.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(color: Color.init(.secondarySystemBackground), radius: 10, x: 5, y: 5)
                        .shadow(color: Color.init(.systemBackground), radius: 10, x: -5, y: -5)
                        
                } else{
                    Image(uiImage: inputImage!).resizable().scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color.init(.secondarySystemBackground), radius: 10, x: 5, y: 5)
                    .shadow(color: Color.init(.systemBackground), radius: 10, x: -5, y: -5)
                }
            }.padding()
        }
    }
    
    var body: some View {
        VStack {
            Text("Bild auswählen")
                .font(.largeTitle)
            Spacer()
            image
            Button("bearbeiten") {
                self.showingActionSheet = true
            }
            
            Spacer()
                
            .actionSheet(isPresented: $showingActionSheet){
                ActionSheet(title: Text("Bild auswählen"), buttons: [
                    .default(Text("Foto auswählen"), action: {
                        self.showingImagePicker = true
                    }),
                    .destructive(Text("Bild entfernen"), action: {
                        self.inputImage = nil
                        self.loadImage()
                    }),
                    .cancel()
                ])
            }
        }
        .sheet(isPresented: $showingImagePicker,onDismiss: self.loadImage) {
            ImagePicker(image: self.$inputImage)
        }
        .onAppear{
            self.loadImage()
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        self.inputImage = inputImage
    }
    
}

struct ImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView(inputImage: .constant(nil))
            .environment(\.colorScheme, .light)
    }
}
