//
//  ScheduleViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 14.09.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import BakingRecipeFoundation
import BakingRecipeStrings
import BackAppCore
import BakingRecipeItems
import BakingRecipeCells

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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Strings.scheduleCell)
    }
    
    // - MARK: - NavigationBar
    private func setUpNavigationBar() {
        title = recipe.formattedName + " - Zeitplan"
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .action, target: self, action: #selector(shareText))
    }
}

private extension ScheduleViewController {
    // - MARK: - Data Source
    private func makeDataSource() -> UITableViewDiffableDataSource<Int, StepItem> {
        UITableViewDiffableDataSource<Int, StepItem>(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            if let step = self.appData.object(with: item.id, of: Step.self) {
                let cell = CustomCell()
                
                let hostingController = UIHostingController(rootView: self.customStepRow(step: step))
                cell.addSubview(hostingController.view)
                hostingController.view?.fillSuperview()
                hostingController.view?.backgroundColor = UIColor.cellBackgroundColor
                
                return cell
            }
            return UITableViewCell()
        }
    }
    
    // - MARK: - Snapshot
    private func updateList(animated: Bool = true) {
        var sections = [Int]()
        let _ = appData.reorderedSteps(for: self.recipe.id).enumerated().map { sections.append($0.offset)} //get a section for each step
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, StepItem>() // create the snapshot
        
        snapshot.appendSections(sections) //append sections
        for section in sections {
            snapshot.appendItems([recipe.allReoderedStepItems[section]], toSection: section)
        }
        self.dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

// - MARK: - Share text
private extension ScheduleViewController {
    @objc private func shareText(sender: UIBarButtonItem) {
        
        let textToShare = appData.text(for: recipe.id, roomTemp: roomTemp, scaleFactor: factor, kneadingHeating: Standarts.kneadingHeating) //get the text to share
        
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

// - MARK: - SwiftUI Views
import SwiftUI
private extension ScheduleViewController {
    private func customIngredientRow(ingredient: Ingredient, step: Step) -> some View{
        HStack {
            Text(ingredient.name)
            Spacer()
            if ingredient.type == .bulkLiquid{
                Text(appData.temperature(for: ingredient, roomTemp: roomTemp).formattedTemp)
                Spacer()
            } else{
                EmptyView()
            }
            Text(ingredient.scaledFormattedAmount(with: self.factor))
        }
        .foregroundColor(Color(UIColor.primaryCellTextColor!))
    }
    
    private func customStepRow(step: Step) -> some View {
        VStack{
            VStack(alignment: .leading) {
                HStack {
                    Text(step.formattedName)
                        .font(.headline)
                    Spacer()
                    Text(appData.formattedStartDate(for: step, with: recipe.id))
                }
                Text("\(step.formattedDuration), \(step.formattedTemp(roomTemp: roomTemp))").secondary()
            }
            
            ForEach(appData.ingredients(with: step.id)){ ingredient in
                self.customIngredientRow(ingredient: ingredient, step: step)
                    .padding(.vertical, 5)
            }
            
            ForEach(appData.substeps(for: step.id)) { substep in
                HStack {
                    Text(substep.formattedName)
                    Spacer()
                    Text(substep.formattedTemp(roomTemp: self.roomTemp))
                    Spacer()
                    Text(self.appData.totalFormattedMass(for: substep.id))
                }
            }
            
            HStack {
                Text(step.notes)
                Spacer()
            }
            Spacer()
        }
        .foregroundColor(Color(UIColor.primaryCellTextColor!))
        .padding()
        .clipped()
    }
}
