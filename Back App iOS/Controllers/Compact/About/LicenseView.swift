// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import BakingRecipeStrings

struct LicenseItem: Identifiable {
    let id = UUID()
    let fileURL: URL
    let fileName: String

    private(set) var content: String? = nil

    mutating func loadContent() {
        guard content == nil else { return } // Prevent reloading
        do {
            content = try String(contentsOf: fileURL)
        } catch {
            content = "⚠️ Failed to load content."
        }
    }
}


class LicenseViewModel: ObservableObject {
    @Published var licenses: [LicenseItem] = []

    init() {
        loadLicenseList(from: "LICENSES")
    }

    func loadLicenseList(from directory: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let folderURL = Bundle.main.url(forResource: directory, withExtension: nil) else {
                print("❌ Folder '\(directory)' not found")
                return
            }

            do {
                let files = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
                    .filter { $0.pathExtension == "txt" }
                    .sorted { $0.lastPathComponent < $1.lastPathComponent }

                let items = files.map {
                    LicenseItem(fileURL: $0, fileName: $0.deletingPathExtension().lastPathComponent)
                }

                DispatchQueue.main.async {
                    self.licenses = items
                }

            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct LicenseView: View {
    @ObservedObject var model: LicenseViewModel
    @State private var expandedItems: Set<UUID> = []

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(Array(model.licenses.enumerated()), id: \.element.id) { index, license in
                    LicenseRow(item: $model.licenses[index], isExpanded: expandedItems.contains(license.id)) {
                        if expandedItems.contains(license.id) {
                            expandedItems.remove(license.id)
                        } else {
                            expandedItems.insert(license.id)
                            model.licenses[index].loadContent()
                        }
                    }
                    Divider()
                }
            }
            .padding()
        }
        .navigationBarTitle(Strings.license)
    }
}

struct LicenseRow: View {
    @Binding var item: LicenseItem
    var isExpanded: Bool
    var onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onTap) {
                HStack {
                    Text(item.fileName)
                        .font(.headline)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            if isExpanded {
                Text(item.content ?? "...")
                    .font(.body)
                    .padding(.top, 4)
            }
        }
        .animation(.easeInOut, value: isExpanded)
    }
}
