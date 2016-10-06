//
//  RoundedView.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-23.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {
    
    //# MARK: - IBInspectables
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layoutIfNeeded()
        }
    }
    
    //# MARK: - Overridden Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        reloadLayers()
    }
    
    
    //# MARK: - Private Methods
    
    private func reloadLayers() {
        layer.cornerRadius = cornerRadius
    }
    
    private func setup() {
        setupLayers()
        layoutIfNeeded()
    }
    
    private func setupLayers() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
}
