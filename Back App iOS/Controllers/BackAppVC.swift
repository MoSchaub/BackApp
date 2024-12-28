// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import UIKit
import BackAppCore
import Combine
import BakingRecipeStrings

/// Custom Table view controller which simplifies done button in navigationbar
internal class BackAppVC: UITableViewController{

    internal var appData: BackAppData

    internal var tokens = Set<AnyCancellable>()

    private var editingTextField: UITextField? = nil {
        didSet {
            if oldValue != self.editingTextField {
                self.updateNavBar()
            }
        }
    }

    private var editingTextView: UITextView? = nil {
        didSet {
            if oldValue != self.editingTextView {
                self.updateNavBar()
            }
        }
    }

    private var undoButton: UIBarButtonItem? = nil {
        didSet {
            if oldValue != self.undoButton {
                self.updateNavBar()
            }
        }
    }

    private var redoButton: UIBarButtonItem? = nil {
        didSet {
            if oldValue != self.redoButton {
                self.updateNavBar()
            }
        }
    }

    init(appData: BackAppData) {
        self.appData = appData

        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError(Strings.init_coder_not_implemented)
    }

    deinit {
        _ = tokens.map { $0.cancel()}
    }

    internal func updateDataSource(animated: Bool) {}
    internal func setLeftBarButtonItems() {}
    internal func setupToolbar() {}
    internal func updateNavBarTitle() {}

    internal func setRightBarButtonItems() {
        self.navigationItem.rightBarButtonItems = []
    }

    internal func registerCells() {
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: Strings.nameCell)
    }
    
    internal func attachPublishers() {
        NotificationCenter.default.publisher(for: .fieldDoneButtonItemShouldBeDisplayed)
            .sink { notification in
                if let textField = notification.object as? UITextField {
                    self.editingTextField = textField
                }
            }.store(in: &tokens)
        NotificationCenter.default.publisher(for: .fieldDoneButtonItemShouldBeRemoved)
            .sink { _ in
                self.editingTextField = nil
            }
            .store(in: &tokens)

        NotificationCenter.default.publisher(for: .viewDoneButtonItemShouldBeDisplayed)
            .sink { notification in
                if let tuple = notification.object as? (textView: UITextView, undo: UIBarButtonItem, redo: UIBarButtonItem) {
                    self.editingTextView = tuple.textView
                    self.undoButton = tuple.undo
                    self.redoButton = tuple.redo
                }
            }
            .store(in: &tokens)
        NotificationCenter.default.publisher(for: .viewDoneButtonItemShouldBeRemoved)
            .sink { _ in
                self.editingTextView = nil
                self.redoButton = nil
                self.undoButton = nil
            }.store(in: &tokens)
    }
}

//MARK: - Life cydle
internal extension BackAppVC {
    override func loadView() {
        super.loadView()
        registerCells()
        configureTableView()
        attachPublishers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDataSource(animated: false)

        self.updateNavBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.editingTextField = nil
    }
}

private extension BackAppVC {

    func doneButtonItem() -> UIBarButtonItem? {
        guard self.editingTextField != nil || self.editingTextView != nil else { return nil }

        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonItemPressed))
    }

    private func items() -> [UIBarButtonItem] {
        var items = [UIBarButtonItem]()

        let dirtyItems = [undoButton, redoButton, doneButtonItem()]

        _ = dirtyItems.reversed().map {
            if let item = $0 {
                items.append(item)
            }
        }


        return items
    }

    @objc func doneButtonItemPressed() {
        DispatchQueue.main.async {

            //end editing and remove done button
            self.editingTextField?.endEditing(true)
            self.editingTextField = nil
            self.editingTextView?.endEditing(true)
            self.editingTextView = nil
        }
    }

    func configureTableView() {
        self.tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
    }
}

internal extension BackAppVC {
    func updateNavBar() {
        DispatchQueue.main.async {
            if !self.items().isEmpty {
                self.navigationItem.rightBarButtonItems = self.items()
            } else {
                self.setRightBarButtonItems()
            }
            self.setLeftBarButtonItems()
            self.updateNavBarTitle()
            self.setupToolbar()
        }
    }
}
