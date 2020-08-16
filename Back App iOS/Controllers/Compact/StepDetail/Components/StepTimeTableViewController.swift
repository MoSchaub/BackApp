//
//  StepTimeTableViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 29.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipe

class StepTimeTableViewController: UITableViewController {

    // MARK: - Properties
    
    @Binding private var time: TimeInterval
    private var datePicker: UIDatePicker!
    
    init(time: Binding<TimeInterval>) {
        self._time = time
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Start functions

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        title = NSLocalizedString("duration", comment: "")
    }

    // MARK: - rows and sections

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }

    // MARK: - Cells
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timePicker")!

        cell.selectionStyle = .none
        
        datePicker = UIDatePicker(frame: .zero)
        cell.addSubview(datePicker)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
        
        datePicker.datePickerMode = .countDownTimer
        
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        DispatchQueue.main.async(execute: {
            self.datePicker.countDownDuration = self.time
        })
        cell.backgroundColor = UIColor(named: "blue")!
        
        return cell
    }
    
    private func registerCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "timePicker")
    }
    
    @objc private func datePickerChanged(_ sender: UIDatePicker) {
        time = sender.countDownDuration
    }

}
