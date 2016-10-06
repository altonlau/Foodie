//
//  FoodieButton.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-20.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

class FoodieButton: UIButton {
    
    //# MARK: - Constants
    
    private let kAnimationDuration = 0.2
    private let kShadowColor = UIColor.gray
    private let kShadowOpacity: Float = 1.0
    private let kShadowRadius: CGFloat = 3.0
    
    
    //# MARK: - Variables
    
    private var initialPosition: CGPoint = .zero
    private var tapOnImageLayer = false
    
    
    //# MARK: - Overridden Variables
    
    override var isHighlighted: Bool {
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
        let shadowAnimation = CABasicAnimation(keyPath: CAShadowOpacityKey)
        shadowAnimation.fromValue = layer.shadowOpacity
        shadowAnimation.toValue = isHighlighted ? kShadowOpacity : 0
        shadowAnimation.duration = kAnimationDuration
        if let value = shadowAnimation.toValue as? Float {
            layer.add(shadowAnimation, forKey: shadowAnimation.keyPath)
            layer.shadowOpacity = value
        }
    }
    
    private func setup() {
        setupLayers()
        layoutIfNeeded()
    }
    
    private func setupLayers() {
        layer.shadowColor = kShadowColor.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0
        layer.shadowRadius = kShadowRadius
    }
    
}
