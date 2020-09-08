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
        datePicker.date = date
        datePicker.addTarget(self, action: #selector(updateDate), for: .valueChanged)
        setUpDatePickerConstraints()
    }
    
    private func setUpDatePickerConstraints() {
        addSubview(datePicker)
        datePicker.fillSuperview()
//        datePicker.translatesAutoresizingMaskIntoConstraints = false
//        datePicker.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        datePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true
//        datePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
    }
    
    @objc private func updateDate(sender: UIDatePicker) {
        self.date = sender.date
    }

}
