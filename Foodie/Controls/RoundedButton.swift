//
//  RoundedButton.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-25.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {
    
    //# MARK: - Constants
    
    private let kAnimationDuration = 0.3
    
    
    //# MARK: - IBInspectables
    
    @IBInspectable var borderColor: UIColor = UIColor.foodieBackground {
        didSet {
            layoutIfNeeded()
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layoutIfNeeded()
        }
    }
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
    
    private func setup() {
        setupLayers()
        layoutIfNeeded()
    }
    
    private func setupLayers() {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
    }
    
    private func reloadLayers() {
        let borderColorAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColorAnimation.fromValue = layer.borderColor
        borderColorAnimation.toValue = borderColor.cgColor
        
        let borderWidthAniamtion = CABasicAnimation(keyPath: "borderWidth")
        borderWidthAniamtion.fromValue = layer.borderWidth
        borderWidthAniamtion.toValue = borderWidth
        
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        cornerRadiusAnimation.fromValue = layer.cornerRadius
        cornerRadiusAnimation.toValue = cornerRadius
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = kAnimationDuration
        groupAnimation.animations = [borderColorAnimation, borderWidthAniamtion, cornerRadiusAnimation]
        
        layer.add(groupAnimation, forKey: "groupAnimation")
        
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
    }
    
}
