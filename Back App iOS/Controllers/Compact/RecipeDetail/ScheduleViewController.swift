// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import UIKit
import BakingRecipeFoundation
import BakingRecipeStrings
import BackAppCore

class ScheduleViewController: UITableViewController {
    // - MARK: - Properties
    let recipe: Recipe
    let roomTemp: Double
    let times: Decimal?
    let appData: BackAppData
    
    private lazy var dataSource = makeDataSource()
    
    // - MARK: - Initializer
    init(recipe: Recipe, roomTemp: Double, times: Decimal?, appData: BackAppData) {
        self.recipe = recipe
        self.roomTemp = roomTemp
        self.times = times
        self.appData = appData
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ScheduleViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        updateList()
        setUpNavigationBar()
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
    }
}

private extension ScheduleViewController {
    // - MARK: - Register Cells
    private func registerCells() {
        tableView.register(StepCell.self, forCellReuseIdentifier: Strings.scheduleCell)
    }
    
    // - MARK: - NavigationBar
    private func setUpNavigationBar() {
        title = recipe.formattedName + " - \(Strings.schedule) "
        navigationItem.prompt = self.times!.description + " " + Strings.pieces
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .action, target: self, action: #selector(shareText))
        navigationController?.setToolbarHidden(true, animated: true)
    }
}

private extension ScheduleViewController {
    // - MARK: - Data Source
    private func makeDataSource() -> UITableViewDiffableDataSource<Int, StepItem> {
        UITableViewDiffableDataSource<Int, StepItem>(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            if let step = self.appData.record(with: Int64(item.id), of: Step.self) {
                return StepCell(vstack: step.vstack(scaleFactor: self.factor), reuseIdentifier: Strings.scheduleCell, editMode: false)
            }
            return UITableViewCell()
        }
    }
    
    private func createUpdatedSnapshot(completion: @escaping (NSDiffableDataSourceSnapshot<Int, StepItem>) -> Void ) {
        var sections = [Int]()
        let _ = self.appData.reorderedSteps(for: self.recipe.id!).enumerated().map { sections.append($0.offset)} //get a section for each step
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, StepItem>() // create the snapshot
        
        snapshot.appendSections(sections) //append sections
        for section in sections {
            snapshot.appendItems([self.recipe.allReoderedStepItems(appData: self.appData)[section]], toSection: section)
        }
        completion(snapshot)
    }
    
    // - MARK: - Snapshot
    private func updateList(animated: Bool = true) {
        self.createUpdatedSnapshot { snapshot in
            self.dataSource.apply(snapshot, animatingDifferences: animated)
        }
    }
}

// - MARK: - Share text
private extension ScheduleViewController {
    @objc private func shareText(sender: UIBarButtonItem) {
        
        let textToShare = appData.text(for: recipe.id!, roomTemp: roomTemp, scaleFactor: factor, kneadingHeating: Standarts.kneadingHeating) //get the text to share
        
        let vc = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil) //share the text
        vc.popoverPresentationController?.barButtonItem = sender
        present(vc, animated: true)
    }
    
    //calculate the factor
    private var factor: Double {
        let times = self.times ?? 1
        let recipeTimes = self.recipe.times ?? 1
        let devided = times/recipeTimes
        return Double.init(truncating: devided as NSNumber)
    }
}
