//
//  DatePickerCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 05.09.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

class DatePickerCell: UITableViewCell {

    @Binding private var date: Date
    private lazy var datePicker = UIDatePicker(backgroundColor: UIColor(named: Strings.backgroundColorName)!)
    
    init(date: Binding<Date>, reuseIdentifier: String?) {
        self._date = date
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        setUpDatePicker()
    }
    
    private func setUpDatePicker() {
        datePicker.datePickerMode = .dateAndTime
        #if canImport(WidgetKit)
        datePicker.preferredDatePickerStyle = .inline
        #endif
        datePicker.date = date
        datePicker.addTarget(self, action: #selector(updateDate), for: .valueChanged)
        setUpDatePickerConstraints()
    }
    
    private func setUpDatePickerConstraints() {
        addSubview(datePicker)
        datePicker.fillSuperview()
    }
    
    @objc private func updateDate(sender: UIDatePicker) {
        self.date = sender.date
    }

}
