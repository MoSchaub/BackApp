// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import MobileCoreServices
import BackAppCore
import BakingRecipeStrings
import BakingRecipeFoundation
import BakingRecipeUIFoundation
import Combine
import UniformTypeIdentifiers

class RecipeListViewController: UITableViewController {
    
    typealias DataSource = RecipeListDataSource
    typealias Snapshot = NSDiffableDataSourceSnapshot<HomeSection,TextItem>
    
    // MARK: Properties
    
    ///data source for the recipe
    private(set) lazy var dataSource = makeDataSource()
    
    /// appData storage interface
    private(set) var appData: BackAppData
    
    /// for managing the theme
    private var themeManager: ThemeManager
    
    private(set) lazy var searchController = makeSearchController()
    
    internal var delegate: RecipeListViewDelegate
    
    /// for picking documents
    internal lazy var documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json])

    /// set for storing publishers
    private var tokens = Set<AnyCancellable>()

    // MARK: - Initializers

    init(appData: BackAppData, delegate: RecipeListViewDelegate) {
        self.appData = appData
        self.delegate = delegate
        self.themeManager = .default
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError(Strings.init_coder_not_implemented)
    }

    deinit {
        //cancel listening to all publishers
        for token in tokens{
            token.cancel()
        }
    }

    // MARK: - Startup functions

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()

        // posted from the thread that deleted the recipe, so deliver it on the main queue
        NotificationCenter.default.publisher(for: .homeShouldPopSplitVC)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let splitViewController = self?.splitViewController,
                      splitViewController.viewControllers.count > 1 else { return }
                _ = splitViewController.viewControllers.popLast()
            }
            .store(in: &tokens)

        // GRDB's `.immediate` scheduling delivers on the main queue
        BackAppData.shared.recipeListPublisher
            .sink(receiveCompletion: { _ in}) { [weak self] recipeListItems in
                self?.editButtonItem.isEnabled = !recipeListItems.isEmpty
                self?.configureNavigationBar()
            }
            .store(in: &tokens)
        
        self.tableView.separatorColor = .secondaryCellBackgroundColor

#if !DEBUG
        //ask for room temp
        delegate.presentRoomTempSheet(from: self)
#endif
    }

    override func loadView() {
        super.loadView()
        _ = dataSource
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

#if DEBUG
        postRecipeListVCAvailable()
#endif
    }

#if DEBUG
    private var triggerCounter = 0

    func postRecipeListVCAvailable() {
        guard !triggering else { return }
        triggerCounter += 1
        if triggerCounter == 1 {
            NotificationCenter.default.post(name: .recipeListVCAvailable, object: nil)
            triggering = true
        }
    }
#endif
}

#if DEBUG
@MainActor var triggering = false

public extension NSNotification.Name {
    static let recipeListVCAvailable = NSNotification.Name.init(rawValue: "recipeListVCAvailable")
    static let recipeListNavbarDidLoad = NSNotification.Name.init(rawValue: "recipeListNavbarDidLoad")
}
#endif

extension RecipeListViewController {

    // MARK: - Cell Registration

    private func registerCells() {
        tableView.register(RecipeCell.self, forCellReuseIdentifier: Strings.recipeCell)
    }
}

private extension RecipeListViewController {

    // MARK: - DataSource

    private func makeDataSource() -> DataSource {
        RecipeListDataSource(tableView: tableView)
    }
}

// MARK: - SwipeActions

extension RecipeListViewController {
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        // Get current state from data source
        guard var recipe = dataSource.itemIdentifier(for: indexPath)?.recipe else { return nil }

        let title = recipe.isFavorite ? Strings.removeFavorite : Strings.addFavorite

        let toggleFavAction = UIContextualAction(style: .normal, title: title,
                                                 handler: { (action, view, completionHandler) in
            // Update data source when user taps action
            BackAppData.shared.toggleFavorite(for: &recipe)
            completionHandler(true)
        })

        toggleFavAction.image = UIImage(systemName: recipe.isFavorite ? "star.slash" : "star")
        toggleFavAction.backgroundColor = recipe.isFavorite ? .red : .systemYellow
        return UISwipeActionsConfiguration(actions: [toggleFavAction])
    }

}

// MARK: - Context Menu



// MARK: - Document Picker

extension RecipeListViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard urls.count == 1, let url = urls.first else { return }
        // UI work stays on the main actor; the import itself runs off it
        Task { @MainActor in
            let result = await appData.open(url)
            delegate.presentImportAlert(for: result, from: self)
        }
    }

}

// MARK: - Search
extension RecipeListViewController {

    func makeSearchController() -> UISearchController {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self.dataSource
        searchController.searchBar.tintColor = .label

        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }

}
