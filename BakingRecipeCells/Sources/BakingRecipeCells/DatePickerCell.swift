//
//  DatePickerCell.swift
//  
//
//  Created by Moritz Schaub on 05.10.20.
//

import SwiftUI
import BackAppCore
import BakingRecipeFoundation
import BakingRecipeUIFoundation

extension UIDatePicker {
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.setValue(UIColor.label, forKeyPath: "textColor")
    }
}

protocol CellDatePickerable {
    var datePicker: UIDatePicker { get set }
}

extension CellDatePickerable {
    func setTextColor(userInterfaceStyle: UIUserInterfaceStyle) {
        if userInterfaceStyle == .dark {
            datePicker.overrideUserInterfaceStyle = .light
        } else if userInterfaceStyle == .light {
            datePicker.overrideUserInterfaceStyle = .dark
        }
    }
}

public class DatePickerCell: CustomCell, CellDatePickerable {
    
    ///currently selected Date
    @Binding private var date: Date
    
    /// the datePicker displayed in the cell
    internal lazy var datePicker = UIDatePicker(backgroundColor: UIColor.cellBackgroundColor!)
    
    public init(date: Binding<Date>, reuseIdentifier: String?) {
        self._date = date
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        addSubview(datePicker)
        self.configureDatePicker()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        setTextColor(userInterfaceStyle: self.traitCollection.userInterfaceStyle)
    }
}

private extension DatePickerCell {
    
    /// sets the date picker up
    func configureDatePicker() {
        datePicker.datePickerMode = .dateAndTime
        
        if #available(iOS 14.0, *) {
            #if canImport(WidgetKit)
            datePicker.preferredDatePickerStyle = .wheels
            #endif
        } else { }
        
        datePicker.date = date
        datePicker.addTarget(self, action: #selector(updateDate), for: .valueChanged)
        setUpDatePickerConstraints()
    }
    
    //sets constraints for picker
    private func setUpDatePickerConstraints() {
        datePicker.fillSuperview()
    }
    
    @objc private func updateDate(sender: UIDatePicker) {
        self.date = sender.date
    }
    
}

