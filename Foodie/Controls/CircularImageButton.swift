//
//  CircularImageButton.swift
//  Foodie
//
//  Created by Alton Lau on 2016-05-06.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

@IBDesignable
class CircularImageButton: UIButton {
    
    //# MARK: - Properties
    
    enum ImageBorderStyle {
        case Solid, Dashed
    }
    
    
    //# MARK: - Constants
    
    private let kBorderWidth: CGFloat = 3.0
    private let kLineDashPattern: [NSNumber] = [8, 4]
    private let kSolidLineDashPattern: [NSNumber] = [1, 0]
    
    
    //# MARK: - Variables
    
    private var borderLayer = CAShapeLayer()
    
    
    //# MARK: - IBInspectables
    
    @IBInspectable var borderColor: UIColor = UIColor.foodieGray {
        didSet {
            layoutIfNeeded()
        }
    }
    @IBInspectable var borderStyle: ImageBorderStyle = .Solid {
        didSet {
            layoutIfNeeded()
        }
    }
    
    
    //# MARK: - Overridden Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reloadLayers()
    }
    
    
    //# MARK: - Private Methods
    
    private func reloadLayers() {
        layer.cornerRadius = layer.bounds.width / 2
        layer.masksToBounds = true
        
        borderLayer.frame = layer.bounds
        borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds, cornerRadius: borderLayer.bounds.width / 2).cgPath
        
        switch borderStyle {
        case .Dashed: borderLayer.lineDashPattern = kLineDashPattern
        default: borderLayer.lineDashPattern = kSolidLineDashPattern
        }
    }
    
    private func setup() {
        setupLayers()
        layoutIfNeeded()
    }
    
    private func setupLayers() {
        borderLayer = CAShapeLayer(layer: layer)
        borderLayer.contentsScale = UIScreen.main.scale
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineCap = kCALineCapRound
        borderLayer.lineJoin = kCALineJoinRound
        borderLayer.lineWidth = kBorderWidth
        borderLayer.strokeColor = borderColor.cgColor
        
        layer.addSublayer(borderLayer)
    }
    
}
