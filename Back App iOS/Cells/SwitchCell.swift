// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  SwitchCell.swift
//  
//
//  Created by Moritz Schaub on 30.12.20.
//

import UIKit

/// The `SwitchCellDelegate` protocol allows the adopting delegate to respond to the UI interaction
public protocol SwitchCellDelegate: AnyObject {
    /// Tells the delegate that the switch control is toggled.
    func switchCell(_ cell: SwitchCell, didToggleSwitch isOn: Bool)
    
    func switchValue(in cell: SwitchCell) -> Bool
}

/// A `UITableViewCell` subclass that shows a `UISwitch` as the `accessoryView`.
public class SwitchCell: CustomCell {

    /// A `UISwitch` as the `accessoryView`
    public private(set) lazy var switchControl: UISwitch = {
        let control = UISwitch()
        control.isOn = delegate?.switchValue(in: self) ?? false
        control.addTarget(self, action: #selector(SwitchCell.didToggleSwitch(_:)), for: .valueChanged)
        return control
    }()
    
    private var switchValue: Bool = false
    
    /// The switch cell's delegate object, which should conform to `SwitchCellDelegate`
    open weak var delegate: SwitchCellDelegate? {
        didSet {
            self.update()
        }
    }
    
    // MARK: - Initializer
    /**
     Overrides `UITableViewCell`'s designated initializer.
     - parameter style:           A constant indicating a cell style.
     - parameter reuseIdentifier: A string used to identify the cell object if it is to be reused for drawing multiple rows of a table view.
     - returns: An initialized `SwitchCell` object.
     */
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    /**
     Overrides the designated initializer that returns an object initialized from data in a given unarchiver.
     - parameter aDecoder: An unarchiver object.
     - returns: `self`, initialized using the data in decoder.
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        update()
        accessoryView = switchControl
        selectionStyle = .none
    }
    
    private func update() {
        self.switchValue = delegate?.switchValue(in: self) ?? false
        switchControl.isOn = switchValue
    }
    
    // MARK: - Private
    @objc private func didToggleSwitch(_ sender: UISwitch) {
        delegate?.switchCell(self, didToggleSwitch: sender.isOn)
        update()
    }
    
}
