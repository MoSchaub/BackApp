//
//  BetterTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 28.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit

class BetterTableViewCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setup()
    }

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        imageView?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        imageView?.trailingAnchor.constraint(lessThanOrEqualTo: textLabel?.leadingAnchor ?? leadingAnchor, constant: -10).isActive = true
        imageView?.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8).isActive = true
        imageView?.contentMode = .scaleAspectFit
    }
    
    func setImage(fromData data: Data?, placeholder: UIImage) {
        imageView?.isHidden = true
        self.imageView?.image = placeholder
        self.tintColor = .label
        DispatchQueue.global(qos: .utility).async {
            
            if let data = data, let downloadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView?.image = downloadedImage
                    self.imageView?.isHidden = false
                }
            } else {
                DispatchQueue.main.async {
                    self.imageView?.image = placeholder
                    self.imageView?.isHidden = false
                }
            }
        }
    }
}
