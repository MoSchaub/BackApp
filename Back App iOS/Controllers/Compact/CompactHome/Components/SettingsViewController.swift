//
//  SettingsViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 31.12.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import BakingRecipeItems
import BakingRecipeSections
import BakingRecipeCells
import BakingRecipeStrings
import BackAppCore
import BakingRecipeUIFoundation

class SettingsViewController: UITableViewController {
    
    // MARK: Properties
    
    /// table view dataSource
    private lazy var dataSource = makeDiffableDataSource()
    
    private var roomTempPickerShown = false
    
    
    //MARK: Initializer
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

// MARK: Setup functions

extension SettingsViewController {
    override func loadView() {
        super.loadView()
//        tableView.separatorStyle = .none
        registerCells()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateList(animated: false) //update the tableView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

private extension SettingsViewController {
    
    // MARK: CellRegistration
    
    func registerCells() {
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.tempCell) //tempCell
        tableView.register(TempPickerCell.self, forCellReuseIdentifier: Strings.tempPickerCell) //tempPicker

        tableView.register(SwitchCell.self, forCellReuseIdentifier: Strings.switchCell) //switchCell for kneading Heat
        tableView.register(KneadingHeatingCell.self, forCellReuseIdentifier: Strings.kneadingHeatingCell) //kneading heating textField

        tableView.register(CustomCell.self, forCellReuseIdentifier: Strings.apperanceCell) //apearance Cells

        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.languageCell)
    }
    
    // MARK: NavigationBar
    
    func setupNavigationBar() {
        DispatchQueue.main.async {
            //title
            self.title = Strings.settings
            
            //large Title
            self.navigationController?.navigationBar.prefersLargeTitles = true
            
        }
    }
    
}


//MARK: Cell Selection
extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let item = dataSource.itemIdentifier(for: indexPath), item is TextItem else {
            return
        }
        
        let section = indexPath.section
        if section == SettingsSection.appearance.rawValue, let newThemeStyle = Theme.Style.allCases.first(where: { $0.number == indexPath.row }) {
            
            //apperance
            Standarts.theme = newThemeStyle
        } else if section == SettingsSection.language.rawValue {
            
            //language
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        } else if section == SettingsSection.temp.rawValue, indexPath.row == 0 {
            
            //roomTempCell
            self.roomTempPickerShown.toggle()
        } else {
            return
        }
        
        self.deselectRow(at: indexPath)
        self.updateList(animated: false)
    }
    
    private func deselectRow(at indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
}


extension SettingsViewController {
    
    // MARK: DataSource
    
    private func makeDiffableDataSource() -> SettingsDataSource {
        SettingsDataSource(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            let section = indexPath.section
            
            if section == SettingsSection.appearance.rawValue, let item = item as? TextItem {
                
                //apearance
                let cell = tableView.dequeueReusableCell(withIdentifier: Strings.apperanceCell, for: indexPath)
                cell.textLabel?.text = item.text
                
                if indexPath.row == Standarts.theme.number {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
                return cell
            } else if section == SettingsSection.language.rawValue, let item = item as? DetailItem, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.languageCell) as? DetailCell {
                
                // language section
                cell.textLabel?.text = item.text
                cell.detailTextLabel?.text = item.detailLabel
                return cell
            } else if section == SettingsSection.temp.rawValue {
                
                //temp section
                if item is DetailItem {
                    
                    // room temp or knedingTempCell
                    let item = item as! DetailItem
                    if indexPath.row == 0, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.tempCell, for: indexPath) as? DetailCell {
                        
                        //roomtempCell
                        cell.textLabel?.text = item.text
                        
                        cell.detailTextLabel?.attributedText = NSAttributedString(string: item.detailLabel, attributes: [.foregroundColor: self.roomTempPickerShown ? UIColor.tintColor! : UIColor.primaryCellTextColor!])
                        
                        return cell
                    } else if let cell = tableView.dequeueReusableCell(withIdentifier: Strings.switchCell) as? SwitchCell {
                        
                        // kneadingHeatingEnabled Cell
                        cell.textLabel?.text = item.text
                        cell.delegate = self
                        return cell
                    }
                } else {
                    
                    //tempPicker or kneatingHeatingCell
                    if indexPath.row > 1,
                       let cell = tableView.dequeueReusableCell(withIdentifier: Strings.kneadingHeatingCell, for: indexPath) as? KneadingHeatingCell {
                        
                        //kneadingHeatingCell
                        cell.delegate = self
                        return cell
                    } else if self.roomTempPickerShown, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.tempPickerCell, for: indexPath) as? TempPickerCell {
                        
                        //tempPickerCell
                        cell.delegate = self
                        
                        return cell
                    }
                }
            }
            return CustomCell()
        }
    }
    
}


// MARK: TempPickerCell
extension SettingsViewController: TempPickerCellDelegate {
    
    func tempPickerCell(_ cell: TempPickerCell, didChangeValue value: Int) {
        Standarts.roomTemp = value
        self.updateList(animated: false)
    }
    
    func startValue(for cell: TempPickerCell) -> Int {
        Standarts.roomTemp
    }
    
}


// MARK: SwitchCell
extension SettingsViewController: SwitchCellDelegate {
    
    func switchCell(_ cell: SwitchCell, didToggleSwitch isOn: Bool) {
        Standarts.kneadingHeatingEnabled = isOn
        self.updateList(animated: false)
    }
    
    func switchValue(in cell: SwitchCell) -> Bool {
        Standarts.kneadingHeatingEnabled
    }
    
}

extension SettingsViewController: KneadingHeatingCellDelegate {
    
    func startValue(for cell: KneadingHeatingCell) -> Double {
        return Standarts.kneadingHeating
    }
    
    func kneadingHeatingCell(_ cell: KneadingHeatingCell, didChangeValue value: Double) {
        Standarts.kneadingHeating = value
    }
    
}

// MARK: Section Header
private class SettingsDataSource: UITableViewDiffableDataSource<SettingsSection, Item> {
    
    override init(tableView: UITableView, cellProvider: @escaping UITableViewDiffableDataSource<SettingsSection, Item>.CellProvider) {
        super.init(tableView: tableView, cellProvider: cellProvider)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SettingsSection.allCases.map { $0.headerTitle }[section]
    }
}

extension SettingsViewController {
    // MARK: Snapshot
    
    private func updateList(animated: Bool = true) {
        DispatchQueue.main.async {
            self.dataSource.apply(self.createSnapshot(), animatingDifferences: animated)
        }
    }
    
    private func snapshotBase() -> NSDiffableDataSourceSnapshot<SettingsSection, Item> {
        
        //apearance Section
        let apearanceItems = Theme.Style.allCases.map { TextItem(text: $0.description)}
        
        //language Section
        let languageItems = [DetailItem(name: Strings.language, detailLabel: Bundle.main.preferredLocalizations.first!)]
        
        // create the snapshot
        var snapshot = NSDiffableDataSourceSnapshot<SettingsSection, Item>() // create the snapshot
        snapshot.appendSections(SettingsSection.allCases) //append sections
        
        snapshot.appendItems(apearanceItems, toSection: .appearance)
        
        snapshot.appendItems(languageItems, toSection: .language)


        
        return snapshot
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<SettingsSection, Item> {
        var snapshot = snapshotBase()
        
        // roomTemp
        var items: [Item] = []
        items.append(roomTempItem)
        if roomTempPickerShown {
            items.append(Item())
        }

        items.append(kneadingHeatingItem)
        if Standarts.kneadingHeatingEnabled {
            items.append(Item())
        }

        snapshot.appendItems(items, toSection: .temp)

        return snapshot
    }
    
    /// detailItem for roomTemp
    private var roomTempItem: DetailItem {
        DetailItem(name: Strings.roomTemperature, detailLabel: String(Standarts.roomTemp) + "° C" )
    }
    
    /// detailItem for temp
    private var kneadingHeatingItem: DetailItem {
        DetailItem(name: Strings.kneadingHeating, detailLabel: "")
    }
    
}
