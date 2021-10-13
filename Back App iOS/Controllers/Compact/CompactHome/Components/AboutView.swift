//
//  AboutView.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 06.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeStrings

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack {
                Image("AppSymbol")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .padding()
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .padding(.horizontal)
                Text(Strings.appTitle)
                    .font(.largeTitle)
                Text(Strings.version)
                    .secondaryNotCell()
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Divider()
                    Link(url: Strings.websiteURL, title: Strings.website)
                    Divider()
                    Link(url: Strings.privacyPolicyURL, title: Strings.privacy_policy)
                    Divider()
                    
                }.padding(.horizontal)
            }
            
        }
        .background(Color(UIWindow.appearance().backgroundColor!).edgesIgnoringSafeArea(.bottom))
        .navigationBarTitle(Text(Strings.about), displayMode: .inline)
    }
}

struct Link: View {
    var url: URL
    var title: String
    
    var body: some View {
        Button(
            action: {
                UIApplication.shared.open(self.url)
            }, label: {
                HStack {
                    Image(systemName: "globe")
                    Text(title)
                }
            }
        )
    }
    
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutView()
        }
    }
}
