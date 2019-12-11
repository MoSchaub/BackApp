//
//  MOTimePicker.swift
//  BrotApp
//
//  Created by Moritz Schaub on 23.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct MOTimePicker: UIViewRepresentable {
    
    @Binding var time:TimeInterval
    
    func makeCoordinator() -> MOTimePicker.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<MOTimePicker>) -> UIDatePicker {
        let datepicker = UIDatePicker()
        datepicker.datePickerMode = .countDownTimer
        datepicker.countDownDuration = time
        datepicker.addTarget(context.coordinator, action: #selector(Coordinator.updateCountDownDuration(sender:)), for: .valueChanged)
        return datepicker
    }
    
    func updateUIView(_ uiView: UIDatePicker, context: UIViewRepresentableContext<MOTimePicker>) {
        uiView.countDownDuration = self.time
    }
    
    
    class Coordinator: NSObject {
        var datepicker: MOTimePicker

        init(_ datepicker: MOTimePicker) {
            self.datepicker = datepicker
        }

        @objc func updateCountDownDuration(sender: UIDatePicker) {
            datepicker.time = sender.countDownDuration
        }
    }
    
}

