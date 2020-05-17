//
//  KeyboardResponder.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 14.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

//import Foundation
//import SwiftUI
//
//class KeyboardResponder: ObservableObject {
//
//    @Published var currentHeight: CGFloat = 0
//    
//    var _center: NotificationCenter
//
//    init(center: NotificationCenter = .default) {
//        _center = center
//    //telling the notification center to listen to the system keyboardWillShow and keyboardWillHide notification
//        _center.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        _center.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//    
//    @objc func keyBoardWillShow(notification: Notification) {
//    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//                withAnimation {
//                   currentHeight = keyboardSize.height
//                }
//            }
//        }
//    @objc func keyBoardWillHide(notification: Notification) {
//            withAnimation {
//               currentHeight = 0
//            }
//        }
//    
//}
