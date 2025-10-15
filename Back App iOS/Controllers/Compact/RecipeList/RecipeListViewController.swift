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
    
    /// wether a cell has been pressed
    internal lazy var pressed = false
    
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

        //attach publisher for navbar reload
        NotificationCenter.default.publisher(for: .homeNavBarShouldReload).sink { _ in
            self.configureNavigationBar()
        }.store(in: &tokens)

        //attach publisher for alert
        NotificationCenter.default.publisher(for: .alertShouldBePresented).sink { _ in
            self.delegate.presentImportAlert(from: self)
        }.store(in: &tokens)

        NotificationCenter.default.publisher(for: .homeShouldPopSplitVC).sink { _ in
            DispatchQueue.main.async {
                if self.splitViewController?.viewControllers.count ?? 2 > 1 {
                    _ = self.splitViewController?.viewControllers.popLast()
                }
            }
        }.store(in: &tokens)

        BackAppData.shared.recipeListPublisher
            .sink(receiveCompletion: { _ in}) { recipeListItems in
                self.editButtonItem.isEnabled = !recipeListItems.isEmpty
                self.configureNavigationBar()
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

        DispatchQueue.global(qos: .background).async {
#if DEBUG
            self.postRecipeListVCAvailable()
#endif
        }
    }

#if DEBUG
    private var triggerCounter = 0

    func postRecipeListVCAvailable() {
        DispatchQueue.main.async {
            if !triggering {
                self.triggerCounter += 1
                if self.triggerCounter == 1 {
                    NotificationCenter.default.post(name: .recipeListVCAvailable, object: nil)
                    triggering = true
                }
            }
        }
    }
#endif
}

#if DEBUG
var triggering = false

public extension NSNotification.Name {
    static var recipeListVCAvailable = NSNotification.Name.init(rawValue: "recipeListVCAvailable")
    static var recipeListNavbarDidLoad = NSNotification.Name.init(rawValue: "recipeListNavbarDidLoad")
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
        appData.open(url)
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
