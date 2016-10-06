//
//  RestaurantTableViewCell.swift
//  Foodie
//
//  Created by Alton Lau on 2016-09-04.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
    
    //# MARK: - Constants
    
    private let kImagePadding: CGFloat = 5.0
    private let kViewMargin: CGFloat = 5.0
    
    
    //# MARK: - Overridden Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = imageView {
            if imageView.image == .none {
                imageView.frame = .zero
                detailTextLabel?.frame.origin.x = 2*kViewMargin
                textLabel?.frame.origin.x = 2*kViewMargin
            } else {
                imageView.frame = CGRect(x: kImagePadding, y: kImagePadding, width: imageView.frame.size.height - (2 * kImagePadding), height: imageView.frame.size.height - (2 * kImagePadding))
                detailTextLabel?.frame.origin.x = imageView.frame.origin.x + imageView.frame.size.width + kImagePadding + kViewMargin
                textLabel?.frame.origin.x = imageView.frame.origin.x + imageView.frame.size.width + kImagePadding + kViewMargin
            }
        }
        reloadLayers()
    }
    
    
    //# MARK: - Private Methods
    
    private func reloadLayers() {
        if let imageView = imageView {
            imageView.layer.cornerRadius = imageView.frame.size.height / 2
        }
        imageView?.layer.masksToBounds = true
    }
    
}
