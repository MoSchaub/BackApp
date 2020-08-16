//
//  InfoTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 13.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

class InfoTableViewCell: UITableViewCell {
    @Binding private var infoText: String
    
    private var textView = UITextView()

    init(infoText: Binding<String>, reuseIdentifier: String?) {
        self._infoText = infoText
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.addSubview(textView)
        textView.fillSuperview()
        
        self.textView.addDoneButton(title: "Fertig", target: self, selector: #selector(tapDone))
        
        textView.text = infoText
        textView.delegate = self
        
        textView.backgroundColor = UIColor(named: "blue")!
        textView.tintColor = .red
        textView.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    @objc private func tapDone(sender: Any) {
        self.textView.endEditing(true)
    }
    
}

extension InfoTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.infoText = textView.text
    }
    
}
