//
//  StrechyHeader.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 05.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

func navBarHeight(name: String) -> CGFloat{
    print(name)
    switch name {
    case "iPhone X", "iPhone 11 Pro", "iPhone XS", "iPhone 11 Pro Max", "iPhone XS Max", "iPhone XR" :
        return 88
    case "iPhone 8 Plus", "iPhone 7 Plus", "iPhone 6 Plus", "iPhone 6s Plus", "Simulator iPhone 8 Plus", "iPhone 8", "iPhone 7", "iPhone 6s", "iPhone 6", "Simulator iPhone 8", "iPhone SE","iPhone 5s", "iPhone 5c", "iPhone 5", "Simulator iPhone SE":
        return 65
    default:
        return 65
    }
}

class ViewFrame: ObservableObject {
    var startingRect: CGRect?
    
    @Published var frame: CGRect {
        willSet {
            if startingRect == nil {
                startingRect = newValue
            }
        }
    }
    
    init() {
        self.frame = .zero
    }
}

struct GeometryGetter: View {
    @Binding var rect: CGRect
    
    var body: some View {
        GeometryReader { geometry in
            AnyView(Color.clear)
                .preference(key: RectanglePreferenceKey.self, value: geometry.frame(in: .global))
        }.onPreferenceChange(RectanglePreferenceKey.self) { (value) in
            self.rect = value
        }
    }
}

struct RectanglePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct StrechyHeader<Content: View, L: View, T: View>: View {
    
    let leading: L
    let trailing: T
    let content: Content
    let image: Image
    let title: String
    
    private let imageHeight: CGFloat = 300
    private let collapsedImageHeight: CGFloat = navBarHeight(name: UIDevice.modelName)
    
    @ObservedObject private var articleContent: ViewFrame = ViewFrame()
    @State private var titleRect: CGRect = .zero
    @State private var headerImageRect: CGRect = .zero
    
    func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let sizeOffScreen = imageHeight - collapsedImageHeight
        
        // if our offset is roughly less than -225 (the amount scrolled / amount off screen)
        if offset < -sizeOffScreen {
            // Since we want 75 px fixed on the screen we get our offset of -225 or anything less than. Take the abs value of
            let imageOffset = abs(min(-sizeOffScreen, offset))
            
            // Now we can the amount of offset above our size off screen. So if we've scrolled -250px our size offscreen is -225px we offset our image by an additional 25 px to put it back at the amount needed to remain offscreen/amount on screen.
            return  imageOffset - sizeOffScreen
        }
        
        // Image was pulled down
        if offset > 0 {
            return -offset
            
        }
        
        return 0
    }
    
    func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height
        
        if offset > 0 {
            return imageHeight + offset
        }
        
        return imageHeight
    }
    
    // at 0 offset our blur will be 0
    // at 300 offset our blur will be 6
    func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).maxY
        
        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height // (values will range from 0 - 1)
        
        return blur * 6 // Values will range from 0 - 6
    }
    
    // 1
    private func getHeaderTitleOffset() -> CGFloat {
        let currentYPos = titleRect.midY
        
        // (x - min) / (max - min) -> Normalize our values between 0 and 1
        
        // If our Title has surpassed the bottom of our image at the top
        // Current Y POS will start at 75 in the beggining. We essentially only want to offset our 'Title' about 30px.
        if currentYPos < headerImageRect.maxY {
            let minYValue: CGFloat = 50.0 // What we consider our min for our scroll offset
            let maxYValue: CGFloat = collapsedImageHeight // What we start at for our scroll offset (75)
            let currentYValue = currentYPos

            let percentage = max(-1, (currentYValue - maxYValue) / (maxYValue - minYValue)) // Normalize our values from 75 - 50 to be between 0 to -1, If scrolled past that, just default to -1
            let finalOffset: CGFloat = -30 // We want our final offset to be -30 from the bottom of the image header view
            // We will start at 20 pixels from the bottom (under our sticky header)
            // At the beginning, our percentage will be 0, with this resulting in 20 - (x * -30)
            // as x increases, our offset will go from 20 to 0 to -30, thus translating our title from 20px to -30px.
            
            return 20 - (percentage * finalOffset)
        }
        
        return .infinity
    }
    
    private func titleText() -> some View{
        Text("")
            .font(.system(size: 1))
            .fontWeight(.bold)
            .background(GeometryGetter(rect: self.$titleRect))
    }
    
    var body: some View {
        ZStack {
            ScrollView{
                VStack {
                    VStack(alignment: .leading, spacing: 0) {
                        titleText()
                        content
                            .offset(y: -30 + collapsedImageHeight)
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 16.0)
                    
                }.offset(y: imageHeight + 16)
                    .background(GeometryGetter(rect: $articleContent.frame))
                
                GeometryReader { geometry in
                    ZStack(alignment: .bottom) {
                        self.image
                            .resizable()
                            .scaledToFill()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.init(.secondarySystemBackground),Color.init(.systemBackground)]), startPoint: .top, endPoint: .bottom))
                            .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))
                            .blur(radius: self.getBlurRadiusForImage(geometry))
                            .clipped()
                            .background(GeometryGetter(rect: self.$headerImageRect))
                        
                        Text(self.title)
                            .font(.system(size: 17))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .offset(y: self.getHeaderTitleOffset())
                            .edgesIgnoringSafeArea(.top)
                    }
                    .clipped()
                    .offset(y: self.getOffsetForHeaderImage(geometry))
                    .offset(y: self.collapsedImageHeight)
                }
                .frame(height: imageHeight)
                .offset(y: -(articleContent.startingRect?.maxY ?? UIScreen.main.bounds.height))
                
            }.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack{
                    leading
                        .padding( .top)
                    
                    Spacer()
                    
                    self.trailing
                        .padding([.top, .trailing])
                }
                Spacer()
            }
            
        }
        .navigationBarTitle(" ")
        .navigationBarHidden(true)
    .navigationBarBackButtonHidden(true)
    }
    
    init(image: UIImage, title: String, @ViewBuilder trailing: () -> T, @ViewBuilder leading: () -> L ,@ViewBuilder content: () -> Content) {
        self.content = content()
        self.image = Image(uiImage: image)
        self.title = title
        self.trailing = trailing()
        self.leading = leading()
    }
    
}

struct StrechyHeader_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Baguette")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                Text(loremIpsum)
                    
            }.streachyHeader(title: "Baguette")
        }
    }
}

extension View {
    func streachyHeader<T: View, L: View>(image: UIImage = UIImage(named: "bread")!, title: String, @ViewBuilder trailing: () -> T, @ViewBuilder leading: () -> L) -> some View {
        StrechyHeader(image: image, title: title, trailing: trailing, leading: leading, content: {
            self
        })
    }
    
    func streachyHeader(image: UIImage = UIImage(named: "bread")!, title: String) -> some View {
        StrechyHeader(image: image, title: title, trailing: {
            EmptyView()
        }, leading: {
            EmptyView()
        }) {
            self
        }
    }
}

let loremIpsum = """
Lorem ipsum dolor sit amet consectetur adipiscing elit donec, gravida commodo hac non mattis augue duis vitae inceptos, laoreet taciti at vehicula cum arcu dictum. Cras netus vivamus sociis pulvinar est erat, quisque imperdiet velit a justo maecenas, pretium gravida ut himenaeos nam. Tellus quis libero sociis class nec hendrerit, id proin facilisis praesent bibendum vehicula tristique, fringilla augue vitae primis turpis.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
"""
