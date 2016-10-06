//
//  ProcessingButton.swift
//  Foodie
//
//  Created by Alton Lau on 2016-09-03.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

@IBDesignable
class ProcessingButton: RoundedButton {
    
    //# MARK: - Constants
    
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    
    //# MARK: - Variables
    
    var isAnimating: Bool {
        get {
            return activityIndicatorView.isAnimating
        }
    }
    
    
    //# MARK: - IBInspectables
    
    @IBInspectable var indicatorColor: UIColor = UIColor.white {
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
        reloadViews()
    }
    
    
    //# MARK: - Public Methods
    
    func startAnimating() {
        activityIndicatorView.startAnimating()
        titleLabel?.isHidden = true
    }
    
    func stopAnimating() {
        activityIndicatorView.stopAnimating()
        titleLabel?.isHidden = false
    }
    
    
    //# MARK: - Private Methods
    
    private func reloadViews() {
        activityIndicatorView.color = indicatorColor
    }
    
    private func setup() {
        setupViews()
        layoutIfNeeded()
    }
    
    private func setupViews() {
        addSubview(activityIndicatorView)
        
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([
            NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            ])
    }
    
}
