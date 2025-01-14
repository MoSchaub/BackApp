// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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
