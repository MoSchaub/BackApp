//
//  SwitchCell.swift
//  
//
//  Created by Moritz Schaub on 30.12.20.
//

import UIKit

/// The `CustomSwitchCellDelegate` protocol allows the adopting delegate to respond to the UI interaction. Not available on tvOS.
public protocol CustomSwitchCellDelegate: class {
    /// Tells the delegate that the switch control is toggled.
    func switchCell(_ cell: SwitchCell, didToggleSwitch isOn: Bool)
}

/// A `UITableViewCell` subclass that shows a `UISwitch` as the `accessoryView`.
public class SwitchCell: CustomCell {

    /// A `UISwitch` as the `accessoryView`
    public private(set) lazy var switchControl: UISwitch = {
        let control = UISwitch()
        control.addTarget(self, action: #selector(SwitchCell.didToggleSwitch(_:)), for: .valueChanged)
        return control
    }()
    
    /// The switch cell's delegate object, which should conform to `SwitchCellDelegate`
    open weak var delegate: CustomSwitchCellDelegate?
    
    // MARK: - Initializer
    /**
     Overrides `UITableViewCell`'s designated initializer.
     - parameter style:           A constant indicating a cell style.
     - parameter reuseIdentifier: A string used to identify the cell object if it is to be reused for drawing multiple rows of a table view.
     - returns: An initialized `SwitchCell` object.
     */
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    /**
     Overrides the designated initializer that returns an object initialized from data in a given unarchiver.
     - parameter aDecoder: An unarchiver object.
     - returns: `self`, initialized using the data in decoder.
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Private
    @objc private func didToggleSwitch(_ sender: UISwitch) {
        delegate?.switchCell(self, didToggleSwitch: sender.isOn)
    }
    
}
