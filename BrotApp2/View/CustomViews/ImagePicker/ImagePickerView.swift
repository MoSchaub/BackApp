//
//  ImagePickerView.swift
//  KAS4Elderly
//
//  Created by Moritz Schaub on 24.02.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
#if os(iOS)
struct ImagePickerView: View {
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @Binding var inputImage: UIImage?
    
    var image: some View {
        get{
            Group{
                if inputImage == nil{
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
                    Image(uiImage: inputImage!.imageFlippedForRightToLeftLayoutDirection()).resizable().scaledToFit()
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
        guard let inputImage = self.inputImage else { return }
        self.inputImage! =  inputImage.resizeTo(width: 300)
    }

    
}

struct ImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView(inputImage: .constant(nil))
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
    
    @Binding var inputImage: NSImage?
    let filteredImage: NSImage?
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Input image")
                    .font(.headline)
                Button(action: selectFile) {
                    Text("Select image")
                }
            }
            InputImageView(image: self.$inputImage, filteredImage: filteredImage)
            if inputImage != nil {
                Button(action: saveToFile) {
                    Text("Save image")
                }
            }
        }
    }
    
    private func selectFile() {
        NSOpenPanel.openImage { (result) in
            if case let .success(image) = result {
                self.inputImage = image.resizeTo(width: 300)
            }
        }
    }
    
    private func saveToFile() {
        guard let image = filteredImage ?? inputImage else {
            return
        }
        NSSavePanel.saveImage(image, completion: { _ in  })
    }
}

struct InputImageView: View {
    
    @Binding var image: NSImage?
    let filteredImage: NSImage?
        
    var body: some View {
        ZStack {
            if image != nil {
                Image(nsImage: filteredImage != nil ? filteredImage! : image!)
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
                        self.image = image
                    }
                }
            }
            return true
        }
        return false
    }
}

typealias UIImage = NSImage

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
    
    func jpegData(compressionQuality: Int) -> Data?{
        if let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) {
        let bits = NSBitmapImageRep(cgImage: cgImage)
            let data = bits.representation(using: .jpeg, properties: [.compressionFactor:compressionQuality])
            return data
        } else {
            return nil
        }
    }
}


extension NSSavePanel {
    
    static func saveImage(_ image: NSImage, completion: @escaping (_ result: Result<Bool, Error>) -> ()) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "image.jpg"
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        savePanel.begin { (result) in
            guard result == .OK,
                let url = savePanel.url else {
                completion(.failure(
                    NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get file location"])
                ))
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                guard
                    let data = image.tiffRepresentation,
                    let imageRep = NSBitmapImageRep(data: data) else { return }
                
                do {
                    let imageData = imageRep.representation(using: .jpeg, properties: [.compressionFactor: 1.0])
                    try imageData?.write(to: url)
                } catch {
                    completion(.failure(error))
                }
            }
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
        //self.draw(in: CGRect(origin: .zero, size: newSize))
        smallImage.unlockFocus()
        return smallImage
    }

}


#endif
