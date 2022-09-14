//
//  BackAppVC.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 07.09.22.
//  Copyright © 2022 Moritz Schaub. All rights reserved.
//

import UIKit
import BackAppCore
import Combine
import BakingRecipeStrings

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

    init(appData: BackAppData) {
        self.appData = appData

        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        NotificationCenter.default.publisher(for: .doneButtonItemShouldBeDisplayed)
            .sink { notification in
                if let textField = notification.object as? UITextField {
                    self.updateEditingTextField(textField: textField)
                }
            }.store(in: &tokens)
        NotificationCenter.default.publisher(for: .doneButtonItemShouldBeRemoved)
            .sink { _ in
                self.editingTextField = nil
            }
            .store(in: &tokens)
    }
}

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

    func updateEditingTextField(textField: UITextField){
        self.editingTextField = textField
    }

    func doneButtonItem() -> UIBarButtonItem? {
        guard self.editingTextField != nil else { return nil }

        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonItemPressed))
    }

    @objc func doneButtonItemPressed() {
        DispatchQueue.main.async {

            //end editing and remove done button
            self.editingTextField?.endEditing(true)
            self.editingTextField = nil
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
            if let item = self.doneButtonItem() {
                self.navigationItem.rightBarButtonItems = [item]
            } else {
                self.setRightBarButtonItems()
            }
            self.setLeftBarButtonItems()
            self.updateNavBarTitle()
            self.setupToolbar()
        }
    }
}
