// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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
                    NavigationLink(destination: LicenseView(model: LicenseViewModel())) {
                        Text(Strings.license)
                    }
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
