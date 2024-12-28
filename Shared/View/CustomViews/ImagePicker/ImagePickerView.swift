// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
#if os(iOS)
struct ImagePickerView: View {
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @Binding var imageData: Data?
    
    var image: some View {
        get{
            Group{
                if imageData == nil{
                    LinearGradient(
                        gradient: Gradient(colors: [Color("Color1"),Color.primary]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                        .mask(Image( "bread").resizable().scaledToFit())
                        .frame(height: 250)
                        .background(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [Color("Color1"),Color("Color2")]
                                ),
                                startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(color: Color("Color1"), radius: 10, x: 5, y: 5)
                        .shadow(color: Color("Color2"), radius: 10, x: -5, y: -5)
                        
                } else{
                    Image(uiImage: UIImage(data: imageData!)!.imageFlippedForRightToLeftLayoutDirection()).resizable().scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(color: Color("Color1"), radius: 10, x: 5, y: 5)
                        .shadow(color: Color("Color2"), radius: 10, x: -5, y: -5)
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
                        self.imageData = nil
                        self.loadImage()
                    }),
                    .cancel()
                ])
            }
        }
        .sheet(isPresented: $showingImagePicker,onDismiss: self.loadImage) {
            ImagePicker(imageData: self.$imageData)
        }
        .onAppear{
            self.loadImage()
        }
    }
    
    func loadImage() {
        guard let imageData = self.imageData else { return }
        self.imageData =  imageData
    }

    
}

struct ImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView(imageData: .constant(nil))
            .environment(\.colorScheme, .light)
    }
}


extension UIImage{
    func resizeTo(width: CGFloat) -> UIImage{
        let scale = width/self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: width, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
#elseif os(macOS)

struct ImagePickerView: View {
    
    @Binding var imageData: Data?
    let image: NSImage? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Input image")
                    .font(.headline)
                Button(action: selectFile) {
                    Text("Select image")
                }
            }
            InputImageView(imageData: $imageData, image: image)
        }
    }
    
    private func selectFile() {
        NSOpenPanel.openImage { (result) in
            if case let .success(image) = result {
                self.imageData = image.jpegData(compressionQuality: 0.8)
            }
        }
    }
}

struct InputImageView: View {
    
    @Binding var imageData: Data?
    let image: NSImage?
        
    var body: some View {
        ZStack {
            if imageData != nil {
                Image(nsImage: (image != nil ? image! : NSImage(data:imageData!))!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("Drag and drop image file")
                    .frame(width: 320)
            }
        }
        .frame(height: 320)
        .background(Color.black.opacity(0.5))
        .cornerRadius(8)
            
        .onDrop(of: ["public.file-url"], isTargeted: nil, perform: handleOnDrop(providers:))
    }
        
    private func handleOnDrop(providers: [NSItemProvider]) -> Bool {
        if let item = providers.first {
            item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                DispatchQueue.main.async {
                    if let urlData = urlData as? Data {
                        let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                        guard let image = NSImage(contentsOf: url) else {
                            return
                        }
                        self.imageData = image.jpegData(compressionQuality: 0.8)
                    }
                }
            }
            return true
        }
        return false
    }
}

typealias UIImage = NSImage

extension Image {
    init(uiImage: UIImage) {
        self = Image(nsImage: uiImage)
    }
}

extension NSImage{
    func pngData() -> Data? {
        if let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            let bits = NSBitmapImageRep(cgImage: cgImage)
            let data = bits.representation(using: .png, properties: [:])
            return data
        } else {
            return nil
        }
    }
    
    func jpegData(compressionQuality: Double) -> Data?{
        if let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) {
        let bits = NSBitmapImageRep(cgImage: cgImage)
            let data = bits.representation(using: .jpeg, properties: [.compressionFactor:compressionQuality])
            return data
        } else {
            return nil
        }
    }
}

extension NSOpenPanel {
    
    static func openImage(completion: @escaping (_ result: Result<NSImage, Error>) -> ()) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ["jpg", "jpeg", "png", "heic"]
        panel.canChooseFiles = true
        panel.begin { (result) in
            if result == .OK,
                let url = panel.urls.first,
                let image = NSImage(contentsOf: url) {
                completion(.success(image))
            } else {
                completion(.failure(
                    NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get file location"])
                ))
            }
        }
    }
}

extension NSImage{
    
    func resizeTo(width: CGFloat) -> NSImage{
        
        let scale = width/self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: width, height: newHeight)
        let smallImage = NSImage(size: newSize)
        smallImage.lockFocus()
        self.size = newSize
        NSGraphicsContext.current?.imageInterpolation = .high
        smallImage.unlockFocus()
        return smallImage
    }

}


#endif
