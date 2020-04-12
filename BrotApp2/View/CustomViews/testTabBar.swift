//
//  testTabBar.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 09.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

// Helper bridge to UIViewController to access enclosing UITabBarController
// and thus its UITabBar
struct NavBarAccessor: UIViewControllerRepresentable {
    var callback: (UINavigationBar) -> Void
    private let proxyController = ViewController()

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavBarAccessor>) ->
                              UIViewController {
        proxyController.callback = callback
        return proxyController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavBarAccessor>) {
    }

    typealias UIViewControllerType = UIViewController

    private class ViewController: UIViewController {
        var callback: (UINavigationBar) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let navCon = self.navigationController {
                self.callback(navCon.navigationBar)
            }
        }
    }
}

// Demo SwiftUI view of usage
struct TestTabBar: View {
    
    @State private var title = ""
    
    var body: some View {
        NavigationView {
            Text(title)
                .background(NavBarAccessor { navBar in
                    print(">> TabBar height: \(navBar.bounds.height)")
                    
                    self.title = ">> NavBar height: \(navBar.bounds.height)"
                })
            .navigationBarTitle("Hel")
            .navigationBarHidden(true)
        }
    }
}

struct TestTabBar_Previews: PreviewProvider {
    static var previews: some View {
        TestTabBar()
    }
}
