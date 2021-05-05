//
//  SettingsViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 31.12.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeSections
import BakingRecipeCells
import BakingRecipeStrings
import BackAppCore
import BakingRecipeUIFoundation
import Combine

class SettingsViewController: UITableViewController {
    
    // MARK: Properties
    
    /// table view dataSource
    private lazy var dataSource = makeDiffableDataSource()
    
    private var roomTempPickerShown = false
    
    /// storage for cancellable tokens
    private var tokens = Set<AnyCancellable>()
    
    
    //MARK: Initializer
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        for token in tokens {
            token.cancel()
        }
    }
    
}

// MARK: Setup functions

extension SettingsViewController {
    override func loadView() {
        super.loadView()
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
        
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.detailCell) //about

        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.languageCell)
    }
    
    // MARK: NavigationBar
    
    func setupNavigationBar() {
        DispatchQueue.main.async {
            //title
            self.title = Strings.settings
            
            //large Title
            self.navigationController!.navigationBar.prefersLargeTitles = true
            self.navigationController!.navigationItem.largeTitleDisplayMode = .always
            
            self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .done, target: self, action: #selector(self.dismis))
        }
    }
    
    @objc private func dismis() {
        self.dismiss(animated: true, completion: nil)
    }
    
}


//MARK: Cell Selection
extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let item = dataSource.itemIdentifier(for: indexPath), item is TextItem else {
            return
        }
        
        let section = indexPath.section
        if section == SettingsSection.language.rawValue {
            
            //language
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        } else if section == SettingsSection.temp.rawValue, indexPath.row == 0 {
            
            //roomTempCell
            self.roomTempPickerShown.toggle()
        } else if section == SettingsSection.export.rawValue {
            
            // export all recipes
            exportAllRecipes(sender: tableView.cellForRow(at: indexPath)!)
        } else if section == SettingsSection.about.rawValue {
            
            // navigate to aboutView
            let hostingController = UIHostingController(rootView: AboutView())
            self.navigationController?.pushViewController(hostingController, animated: true)
        } else {
            return
        }
        
        self.deselectRow()
        self.updateList(animated: false)
    }
    
    private func deselectRow() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @objc private func exportAllRecipes(sender: UIView) {
        let appData = BackAppData()
        let ac = UIActivityViewController(activityItems: [appData.exportAllRecipesToFile()], applicationActivities: nil)
        
        ac.popoverPresentationController?.sourceView = sender
        present(ac,animated: true, completion: deselectRow)
    }

}


extension SettingsViewController {
    
    // MARK: DataSource
    
    private func makeDiffableDataSource() -> SettingsDataSource {
        SettingsDataSource(tableView: tableView) { [self] (tableView, indexPath, item) -> UITableViewCell? in
            let section = indexPath.section
            if section == SettingsSection.export.rawValue, let item = item as? TextItem,
               let cell = tableView.dequeueReusableCell(withIdentifier: Strings.apperanceCell, for: indexPath) as? CustomCell {
                
                // export Cell
                cell.chevronUpCell(text: item.text)
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
                        
                        //kneading heating Cell
                        Standarts.standartsChangedPublisher
                            .sink { key in
                                switch key {
                                case .kneadingHeating(let newValue):
                                    cell.defaultValue = newValue
                                case .kneadingHeatingEnabled(true):
                                    cell.defaultValue = Standarts.kneadingHeating
                                default:
                                    _ = 1
                                }
                            }.store(in: &self.tokens)
                        
                        if Standarts.kneadingHeatingEnabled {
                            cell.defaultValue = Standarts.kneadingHeating
                        }
                        
                        cell.valueChangedPublisher.sink { (kneadingCell, newValue) in
                            Standarts.kneadingHeating = newValue
                        }.store(in: &self.tokens)
                        
                        return cell
                    } else if self.roomTempPickerShown, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.tempPickerCell, for: indexPath) as? TempPickerCell {
                        
                        //tempPickerCell
                        cell.delegate = self
                        
                        return cell
                    }
                }
            } else if section == SettingsSection.about.rawValue, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.detailCell, for: indexPath) as? DetailCell, let item = item as? DetailItem {
                
                // about back app
                cell.textLabel?.text = item.text
                return cell
            }
            return CustomCell()
        }
    }
    
}


// MARK: TempPickerCell
extension SettingsViewController: TempPickerCellDelegate {
    
    func tempPickerCell(_ cell: TempPickerCell, didChangeValue value: Double) {
        Standarts.roomTemp = value
        self.updateList(animated: false)
    }
    
    func startValue(for cell: TempPickerCell) -> Double {
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
        let exportItems = [TextItem(text: Strings.exportAll)]
        
        //language Section
        let languageItems = [DetailItem(name: Strings.language, detailLabel: Bundle.main.preferredLocalizations.first!)]
        
        let aboutItems = [DetailItem(name: Strings.about)]
        
        // create the snapshot
        var snapshot = NSDiffableDataSourceSnapshot<SettingsSection, Item>() // create the snapshot
        snapshot.appendSections(SettingsSection.allCases) //append sections
        
        snapshot.appendItems(exportItems, toSection: .export)
        
        snapshot.appendItems(languageItems, toSection: .language)
        
        snapshot.appendItems(aboutItems, toSection: .about)
        
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
