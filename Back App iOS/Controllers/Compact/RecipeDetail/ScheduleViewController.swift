//
//  ScheduleViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 14.09.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import BakingRecipe

class ScheduleViewControllor: UITableViewController {
    // - MARK: - Properties
    let recipe: Recipe
    let roomTemp: Int
    let times: Decimal?
    
    private lazy var dataSource = makeDataSource()
    
    // - MARK: - Initializer
    init(recipe: Recipe, roomTemp: Int, times: Decimal?) {
        self.recipe = recipe
        self.roomTemp = roomTemp
        self.times = times
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ScheduleViewControllor {
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

private extension ScheduleViewControllor {
    // - MARK: - Register Cells
    private func registerCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Strings.scheduleCell)
    }
    
    // - MARK: - NavigationBar
    private func setUpNavigationBar() {
        title = recipe.formattedName + " - Zeitplan"
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .action, target: self, action: #selector(shareText))
    }
}

private extension ScheduleViewControllor {
    // - MARK: - Data Source
    private func makeDataSource() -> UITableViewDiffableDataSource<Int, StepItem> {
        UITableViewDiffableDataSource<Int, StepItem>(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            if let step = self.recipe.reorderedSteps.first(where: { $0.id == item.id }) {
                let cell = UITableViewCell()
                cell.selectionStyle = .none
                
                let hostingController = UIHostingController(rootView: self.customStepRow(step: step))
                cell.addSubview(hostingController.view)
                hostingController.view?.fillSuperview()
                hostingController.view?.backgroundColor = UIColor(named: Strings.backgroundColorName)
                
                return cell
            }
            return UITableViewCell()
        }
    }
    
    // - MARK: - Snapshot
    private func updateList(animated: Bool = true) {
        var sections = [Int]()
        let _ = recipe.steps.enumerated().map { sections.append($0.offset)} //get a section for each step
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, StepItem>() // create the snapshot
        
        snapshot.appendSections(sections) //append sections
        for section in sections {
            snapshot.appendItems([recipe.stepItems[section]], toSection: section)
        }
        self.dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

// - MARK: - Share text
private extension ScheduleViewControllor {
    @objc private func shareText(sender: UIBarButtonItem) {
        let vc = UIActivityViewController(activityItems: [recipe.text(roomTemp: roomTemp, scaleFactor: factor)], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = sender
        present(vc, animated: true)
    }
    
    private var factor: Double {
        let times = self.times ?? 1
        let recipeTimes = self.recipe.times ?? 1
        let devided = times/recipeTimes
        return Double.init(truncating: devided as NSNumber)
    }
}

// - MARK: - SwiftUI Views
import SwiftUI
private extension ScheduleViewControllor {
    private func customIngredientRow(ingredient: Ingredient, step: Step) -> some View{
        HStack {
            Text(ingredient.name)
            Spacer()
            if ingredient.isBulkLiquid{
                Text("\(step.themperature(for: ingredient, roomThemperature: roomTemp))" + "° C")
                Spacer()
            } else{
                EmptyView()
            }
            Text(ingredient.scaledFormattedAmount(with: self.factor))
        }
    }
    
    private func customStepRow(step: Step) -> some View {
        VStack{
            VStack(alignment: .leading) {
                HStack {
                    Text(step.formattedName).font(.headline)
                    Spacer()
                    Text(recipe.formattedStartDate(for: step))
                }
                Text("\(step.formattedTime), \(step.formattedTemp)").secondary()
            }
            
            ForEach(step.ingredients){ ingredient in
                self.customIngredientRow(ingredient: ingredient, step: step)
                    .padding(.vertical, 5)
            }
            
            ForEach(step.subSteps){substep in
                HStack{
                    Text(substep.formattedName)
                    Spacer()
                    Text(substep.formattedTemp)
                    Spacer()
                    Text(substep.totalFormattedAmount)
                }
            }
            HStack {
                Text(step.notes)
                Spacer()
            }
            Spacer()
        }
        .padding()
        .clipped()
    }
}
