//
//  MOTimePicker.swift
//  BrotApp
//
//  Created by Moritz Schaub on 23.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

#if os(iOS)
struct MOTimePicker: UIViewRepresentable {
    
    @Binding var time:TimeInterval
    
    func makeCoordinator() -> MOTimePicker.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<MOTimePicker>) -> UIDatePicker {
        let datepicker = UIDatePicker()
        datepicker.datePickerMode = .countDownTimer
        datepicker.countDownDuration = time
        datepicker.locale = .current
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
#elseif os(macOS)

struct MOTimePicker: View {
    @EnvironmentObject private var timePickerModel: TimePickerModel
    
    var body: some View{
        MOTimePickerComponent(timePickerModel: self._timePickerModel).equatable()
            
    }
}

struct MOTimePickerComponent: View, Equatable{
    static func == (lhs: MOTimePickerComponent, rhs: MOTimePickerComponent) -> Bool {
        lhs.timePickerModel.hours == rhs.timePickerModel.hours && lhs.timePickerModel.minutes == rhs.timePickerModel.minutes
    }
    
    @EnvironmentObject var timePickerModel: TimePickerModel
    
    var body: some View{
        HStack{
            Picker("",selection: self.$timePickerModel.hours) {
                ForEach(0 ..< 24, id: \.self){ n in
                    Text("\(n) \(n == 1 ? "Stunde" : "Stunden")").tag(n)
                }
            }.frame(width: 115)
            
            Picker("",selection: self.$timePickerModel.minutes) {
                ForEach(0 ..< 60, id: \.self){ n in
                    Text("\(n) \(n == 1 ? "Minute" : "Minuten" )").tag(n)
                }
            }.frame(width: 115)
            
        }
    }
}

#endif

