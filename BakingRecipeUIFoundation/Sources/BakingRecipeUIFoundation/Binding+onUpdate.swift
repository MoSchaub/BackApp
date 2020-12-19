//
//  Binding+onUpdate.swift
//  
//
//  Created by Moritz Schaub on 15.11.20.
//

import SwiftUI

@available(iOS 13.0, *)
public extension Binding where Value: Equatable{
    
    /// When the `Binding`'s `wrappedValue` changes, the given closure is executed.
    /// - Parameter closure: Chunk of code to execute whenever the value changes.
    /// - Returns: New `Binding`.
    func onUpdate(_ closure: @escaping () -> Void) -> Binding<Value> {
        Binding(get: {
            wrappedValue
        }, set: { newValue in
            if newValue != wrappedValue {
                wrappedValue = newValue
                closure()
            }
        })
    }
}
