//
//  AboutView.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 06.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack {
                Image("AppSymbol")
                    .cornerRadius(10)
                    .padding(.top)
                Text("appTitle")
                    .font(.largeTitle)
                Text("Version 1.0")
                    .secondary()
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Divider()
                    Text(donateText)
                    Divider()
                    Link(url: donateURL, title: "Unterstützen")
                    Divider()
                    Link(url: websiteURL, title: "Website")
                    Divider()
                    Link(url: privacyPolicyURL, title: "Datenschutzerklärung")
                    Divider()
                    
                }.padding(.horizontal)
            }
            
        }
        .navigationBarTitle("About", displayMode: .inline)
    }
    
    let donateText = """
Die Nutzung dieser App mit allen Funktionen ist komplett gratis und ohne jegliche Werbung.
Jedoch ist die Entwicklung dieser App mit einer Menge an Kosten und Arbeit verbunden und wenn sie mit einem kleinem Beitrag die Entwicklung dieser App unterstützen wollen, würden wir uns als Entwickler sehr freuen.
"""
    
    let websiteURL = URL(string: "https://heimbaecker.de/backapp")!
    let privacyPolicyURL = URL(string: "https://heimbaecker.de/backapp-datenschutzerklaerung")!
    let donateURL = URL(string: "https://heimbaecker.de/backapp-donate")!
}

struct Link: View {
    var url: URL
    var title: String
    
    var body: some View {
        Button(
            action: {
                UIApplication.shared.open(url)
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
