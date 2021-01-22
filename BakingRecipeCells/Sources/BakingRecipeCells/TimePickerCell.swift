//
//  TimePickerCell.swift
//  
//
//  Created by Moritz Schaub on 22.01.21.
//

import UIKit
import BakingRecipeFoundation
import BackAppCore
import BakingRecipeStrings
import BakingRecipeUIFoundation

public class TimePickerCell: CustomCell {
    
    ///currently selected duration
    private var time: TimeInterval {
        get {
            return appData.object(with: stepId, of: Step.self)!.duration
        }
        set {
            var newStep = appData.object(with: stepId, of: Step.self)!
            newStep.duration = newValue
            _ = self.appData.update(newStep)
            NotificationCenter.default.post(Notification(name: .init(rawValue: "stepChanged")))
        }
    }
    
    private var hours: UInt {
        get {
            UInt(Int(self.time/60).hours)
        }
        set {
            
            self.time = Double(newValue * 3600 + minutes * 60)
        }
    }
    private var minutes: UInt {
        get {
            UInt(Int(self.time/60).minutes)
        }
        set {
            self.time = Double(hours * 3600 + newValue * 60)
        }
    }
    
    private func setDatePickerWheels() {
        self.datePicker.selectRow(Int(hours), inComponent: 0, animated: false)
        self.datePicker.selectRow(Int(minutes), inComponent: 1, animated: false)
    }
    
    ///the id of the step whose duration is modified
    private var stepId: Int
    
    private var appData: BackAppData
    
    /// the datePicker displayed in the cell
    internal lazy var datePicker = UIPickerView(backgroundColor: UIColor.cellBackgroundColor!)
    
    public init(stepId: Int, appData: BackAppData, reuseIdentifier: String?) {
        self.stepId = stepId
        self.appData = appData
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
    
}

private extension TimePickerCell {
    
    /// sets the date picker up
    func configureDatePicker() {
        datePicker.delegate = self
        datePicker.dataSource = self

        setUpDatePickerConstraints()
        
        setPicker()
    }
    
    //sets constraints for picker
    private func setUpDatePickerConstraints() {
        datePicker.fillSuperview()
    }
    
    private func setPicker() {
        self.datePicker.selectRow(Int(hours), inComponent: 0, animated: false)
        self.datePicker.selectRow(Int(minutes), inComponent: 1, animated: true)
    }
    
}

extension TimePickerCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var returnValue = 0
        doSomething(component: component) {
            returnValue = 73
        } and: {
            returnValue = 60
        }
        return returnValue
    }
    
    private func doSomething(component: Int, for component0: @escaping () -> (), and component1: @escaping (() -> ()) ) {
        if component == 0 {
            
            //hours
            component0()
        } else {
            
            //minutes
            component1()
        }
    }
    
    private func checkFor00() {
        if hours == 0 && minutes == 0 {
            self.minutes = 1
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        doSomething(component: component) {
            self.hours = UInt(row)
        } and: {
            self.minutes = UInt(row)
        }
        
        checkFor00()
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var returnValue: NSAttributedString?
        doSomething(component: component) {
            let hourString = row == 1 ? Strings.one + " " + Strings.hour : "\(row) " + Strings.hours
            
            returnValue =  NSAttributedString(string: hourString, attributes: [NSAttributedString.Key.foregroundColor:UIColor.primaryCellTextColor!])
        } and: {
            let minuteString = row == 1 ? Strings.one + " " + Strings.minute : "\(row) " + Strings.minutes
            
            returnValue = NSAttributedString(string: minuteString, attributes: [NSAttributedString.Key.foregroundColor:UIColor.primaryCellTextColor!])
        }
        return returnValue!
    }
    
}


