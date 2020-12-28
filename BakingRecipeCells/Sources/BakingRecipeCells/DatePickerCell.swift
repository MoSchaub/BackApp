//
//  DatePickerCell.swift
//  
//
//  Created by Moritz Schaub on 05.10.20.
//

import SwiftUI
import BackAppCore
import BakingRecipeFoundation

/// workaround to change textcolor
public extension UILabel {
    @objc dynamic var textColorWorkaround: UIColor? {
        get {
            return textColor
        }
        set {
            textColor = newValue
        }
    }
}

public class DatePickerCell: CustomCell {
    
    ///currently selected Date
    @Binding private var date: Date
    
    /// the datePicker displayed in the cell
    private lazy var datePicker = UIDatePicker(backgroundColor: UIColor.backgroundColor)
    
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
}

private extension DatePickerCell {
    
    /// sets the date picker up
    func configureDatePicker() {
        datePicker.datePickerMode = .dateAndTime
        
        datePicker.setValue(UIColor.cellTextColor, forKey: "textColor")
        
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
    
    ///the id of the step whose duration is modified
    private var stepId: Int
    
    private var appData: BackAppData
    
    /// the datePicker displayed in the cell
    private lazy var datePicker = UIDatePicker(backgroundColor: UIColor.backgroundColor)
    
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
        
        setUpDatePickerConstraints()
        
        datePicker.datePickerMode = .countDownTimer
        
        datePicker.addTarget(self, action: #selector(updateDate), for: .valueChanged)
        
        self.datePicker.countDownDuration = self.time
        
        DispatchQueue.main.async {
            self.datePicker.countDownDuration = self.time
        }
        
        let pickerLabelProxy = UILabel.appearance(whenContainedInInstancesOf: [UIDatePicker.self])
        pickerLabelProxy.textColorWorkaround = .cellTextColor
        
        datePicker.setValue(UIColor.cellTextColor, forKeyPath: "textColor")
        
    }
    
    //sets constraints for picker
    private func setUpDatePickerConstraints() {
        datePicker.fillSuperview()
    }
    
    @objc private func updateDate(sender: UIDatePicker) {
        self.time = sender.countDownDuration
    }
    
}

