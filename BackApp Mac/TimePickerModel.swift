//
//  TimePickerModel.swift
//  BackApp Mac
//
//  Created by Moritz Schaub on 15.05.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import Combine

class TimePickerModel: ObservableObject{
    
    let objectWillChange = PassthroughSubject<TimePickerModel,Never>()
    
    @Binding var time: TimeInterval
    
    
    @Published var minutes: Int{
        didSet{
            self.update()
            objectWillChange.send(self)
        }
    }
    @Published var hours: Int{
        didSet{
            self.update()
            objectWillChange.send(self)
        }
    }
    
    init(time t: Binding<TimeInterval>) {
        self._time = t
        let timeInt = Int(t.wrappedValue / 60)
        self.hours = timeInt / 60
        self.minutes = timeInt - (timeInt / 60) * 60
    }
    
    func update() {
        self.time = TimeInterval(self.hours * 3600 + self.minutes * 60)
        print(self.time)
    }
    
}
