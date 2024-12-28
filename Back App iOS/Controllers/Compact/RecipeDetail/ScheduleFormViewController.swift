// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import BakingRecipeFoundation
import BakingRecipeStrings
import BackAppCore
import BakingRecipeUIFoundation

class ScheduleFormViewController: BackAppVC {

    @Binding private var recipe: Recipe
    var times: Decimal?

    private(set) lazy var dataSource = makeDataSource()

    init(recipe: Binding<Recipe>, appData: BackAppData) {
        self._recipe = recipe
        self.times = recipe.wrappedValue.times
        super.init(appData: appData)

        //set date to now
        self.recipe.date = Date()
    }

    required init?(coder: NSCoder) {
        fatalError(Strings.init_coder_not_implemented)
    }

    override func registerCells() {
        tableView.register(DecimalCell.self, forCellReuseIdentifier: "times")
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: "datePicker")
    }

    override func setupToolbar() {
        self.navigationController?.setToolbarHidden(true, animated: false)
    }

    override func setRightBarButtonItems() {
        self.navigationItem.rightBarButtonItem = .init(title: Strings.Alert_ActionOk, style: .plain, target: self, action: #selector(proceedToScheduleView))
    }

    override func updateNavBarTitle() {
        self.title = Strings.createSchedule
    }

    override func updateDataSource(animated: Bool) {
        let timesItem = TimesItem(decimal: self.recipe.times)
        let dateItem = DateItem(date: self.recipe.date)
        let pickerItem = Item()
        var snapshot = NSDiffableDataSourceSnapshot<ScheduleFormSection, Item>()
        snapshot.appendSections(ScheduleFormSection.allCases)
        snapshot.appendItems([timesItem], toSection: .times)
        snapshot.appendItems([dateItem, pickerItem], toSection: .datepicker)

        self.dataSource.apply(snapshot, animatingDifferences: animated)
    }

    /// property to store wether this vc has already dissapeared at least once
    private lazy var hasDisappeared: Bool = false
}

extension ScheduleFormViewController {

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? Strings.amount : ""
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.setToolbarHidden(true, animated: true)
        if !hasDisappeared {
            // dont make first responder when returning from ScheduleView
            NotificationCenter.default.post(name: .decimalCellTextFieldShouldBecomeFirstResponder, object: nil)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.hasDisappeared = true
    }
}

private extension ScheduleFormViewController {
    @objc private func proceedToScheduleView() {
        navigationController?.pushViewController(ScheduleViewController(recipe: self.recipe, roomTemp: Standarts.roomTemp, times: self.times, appData: appData), animated: true)
    }
}

internal extension ScheduleFormViewController {
    //create the cells
    private func makeDataSource() -> UITableViewDiffableDataSource<ScheduleFormSection, Item> {
        ScheduleFormDataSource(
            inverted: Binding(get: {self.recipe.inverted}, set: { _ in}),
            tableView: tableView
        ) { (tableView, indexPath, item) -> UITableViewCell? in
            if item is TimesItem, let cell = tableView.dequeueReusableCell(withIdentifier: "times", for: indexPath) as? DecimalCell {
                cell.delegate = self
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
        picker.backgroundColor = UIColor.cellBackgroundColor

        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.primaryCellTextColor!]
        picker.setTitleTextAttributes(titleTextAttributes, for: .selected)
        picker.setTitleTextAttributes(titleTextAttributes, for: .normal)

        picker.selectedSegmentTintColor = .secondaryCellTextColor

        picker.selectedSegmentIndex = recipe.inverted ? 1 : 0
        picker.addTarget(self, action: #selector(didSelectOption), for: .valueChanged)
        return picker
    }
    
    @objc func didSelectOption(sender: UISegmentedControl) {
        recipe.inverted = sender.selectedSegmentIndex == 0 ? false : true

        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.datepicker])
        
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension ScheduleFormViewController {
    // header color
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .secondaryTextColor!
        }
    }
}

extension ScheduleFormViewController: DecimalCellDelegate {
    
    func decimalCell(_ cell: DecimalCell, didChangeValue value: Decimal?) {
        self.times = value
    }
    
    func standardValue(in cell: DecimalCell) -> Decimal {
        self.recipe.times!
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
