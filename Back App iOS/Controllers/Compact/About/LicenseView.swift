//
//  LicenseView.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 28.12.24.
//  Copyright © 2024 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeStrings

class LicenseViewModel: ObservableObject {
    @Published var data: String = ""
    init() { self.load(file: "LICENSE") }
    func load(file: String) {
        if let filepath = Bundle.main.path(forResource: file, ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                DispatchQueue.main.async {
                    self.data = contents
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("File not found")
        }
    }
}

struct LicenseView: View{
    @ObservedObject var model: LicenseViewModel
    var body: some View{
        ScrollView {
            VStack {
                Text(model.data).frame(maxWidth: .infinity)
            }
        }.padding()
            .navigationBarTitle(Strings.license)
    }
}

#Preview {
    LicenseView(model: LicenseViewModel())
}
