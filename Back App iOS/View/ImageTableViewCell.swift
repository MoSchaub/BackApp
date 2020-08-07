//
//  ImageTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 29.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    lazy var activityIndicator = UIActivityIndicatorView(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.blue
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        imageView?.translatesAutoresizingMaskIntoConstraints = false
        imageView?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        imageView?.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -40).isActive = true
        imageView?.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8).isActive = true
        imageView?.contentMode = .scaleAspectFit
        
    }
    
    func setPlaceholderImage(_ placeholder: UIImage) {
        imageView?.image = placeholder
        tintColor = .label
        self.imageView?.isHidden = false
    }
    
    
    func setImage(fromData data: Data?, placeholder: UIImage) {
        setPlaceholderImage(placeholder)
        imageView?.isHidden = true
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .utility).async {
            if let data = data, let downloadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView?.image = downloadedImage
                    self.activityIndicator.stopAnimating()
                    self.imageView?.isHidden = false
                }
            } else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.setPlaceholderImage(placeholder)
                }
            }
        }
    }
    
}
