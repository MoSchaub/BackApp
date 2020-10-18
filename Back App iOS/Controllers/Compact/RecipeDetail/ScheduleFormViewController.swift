//
//  ScheduleFormViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 05.09.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeFoundation
import BakingRecipeStrings
import BakingRecipeCore
import BakingRecipeSections
import BakingRecipeItems
import BakingRecipeCells

class ScheduleFormViewController: UITableViewController {
    
    @Binding private var recipe: Recipe
    var times: Decimal?
    
    private lazy var dataSource = makeDataSource()
    
    init(recipe: Binding<Recipe>) {
        self._recipe = recipe
        self.times = recipe.wrappedValue.times
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError(Strings.init_coder_not_implemented)
    }
}

extension ScheduleFormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        updateTableView()
        setUpNavigationBar()
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Menge" : ""
    }
}

private extension ScheduleFormViewController {
    
    private func setUpNavigationBar() {
        title = recipe.formattedName
        navigationItem.rightBarButtonItem = .init(title: "OK", style: .plain, target: self, action: #selector(proceedToScheduleView))
    }
    
    @objc private func proceedToScheduleView() {
        navigationController?.pushViewController(ScheduleViewControllor(recipe: self.recipe, roomTemp: Standarts.standardRoomTemperature, times: self.times), animated: true)
    }
    
    private func registerCells() {
        tableView.register(DecimalCell.self, forCellReuseIdentifier: "times")
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: "datePicker")
    }
}

private extension ScheduleFormViewController {
    private func makeDataSource() -> UITableViewDiffableDataSource<ScheduleFormSection, Item> {
        ScheduleFormDataSource(
            inverted: Binding(get: {self.recipe.inverted}, set: { _ in}),
            tableView: tableView
        ) { (tableView, indexPath, item) -> UITableViewCell? in
            if let item = item as? TimesItem {
                let cell = DecimalCell(decimal: Binding(get: {
                    return item.decimal
                }, set: { newValue in
                    item.decimal = newValue
                    self.times = newValue!
                }), reuseIdentifier: "times", standartValue: self.recipe.times!)
                cell.backgroundColor = UIColor.backgroundColor
                return cell
            } else if let item = item as? DateItem {
                return DatePickerCell(date: Binding(get: {
                    return item.date
                }, set: { (newDate) in
                    item.date = newDate
                    self.recipe.date = newDate
                }), reuseIdentifier: "datePicker")
            } else  {
                let cell = CustomCell()
                let picker = self.makePicker()
                cell.addSubview(picker)
                picker.fillSuperview()
                return cell
            }
        }
    }
    
    private func makePicker() -> UISegmentedControl{
        let picker = UISegmentedControl(items: [Strings.start, Strings.end])
        picker.backgroundColor = UIColor.backgroundColor
        
        ///textColor
        let pickerLabelProxy = UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self])
        pickerLabelProxy.textColorWorkaround = UIColor.cellTextColor
        
        picker.selectedSegmentTintColor = .secondaryColor
        
        picker.selectedSegmentIndex = recipe.inverted ? 1 : 0
        picker.addTarget(self, action: #selector(didSelectOption), for: .valueChanged)
        return picker
    }
    
    @objc private func didSelectOption(sender: UISegmentedControl) {
        recipe.inverted = sender.selectedSegmentIndex == 0 ? false : true
        
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.datepicker])
        
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func updateTableView() {
        let timesItem = TimesItem(decimal: self.recipe.times)
        let dateItem = DateItem(date: self.recipe.date)
        let pickerItem = Item()
        var snapshot = NSDiffableDataSourceSnapshot<ScheduleFormSection, Item>()
        snapshot.appendSections(ScheduleFormSection.allCases)
        snapshot.appendItems([timesItem], toSection: .times)
        snapshot.appendItems([dateItem, pickerItem], toSection: .datepicker)
        
        self.dataSource.apply(snapshot)
    }
}

class ScheduleFormDataSource: UITableViewDiffableDataSource<ScheduleFormSection, Item> {
    
    @Binding private var inverted: Bool
    
    init(inverted: Binding<Bool>, tableView: UITableView, cellProvider: @escaping UITableViewDiffableDataSource<ScheduleFormSection, Item>.CellProvider) {
        self._inverted = inverted
        super.init(tableView: tableView, cellProvider: cellProvider)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Strings.quantity
        } else if section == 1 {
            return self.inverted ? Strings.endDate : Strings.startDate
        }
        return nil
    }
}
