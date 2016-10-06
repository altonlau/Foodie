//
//  ModalCardView.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-23.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

@objc protocol ModalCardViewDelegate: class {
    func closeButtonPressed(_ sender: AnyObject)
}

class ModalCardView: RoundedView {
    
    //# MARK: - Constants
    
    private let kReturnToCenterDuration = 0.5
    private let kYThreshold: CGFloat = 0.4

    private let navigationBar = UINavigationBar()
    
    
    //# MARK: - Variables
    
    private var navigationBarConstraints = [NSLayoutConstraint]()
    private var startPoint: CGPoint = .zero
    
    
    //# MARK: - IBInspectables
    
    @IBInspectable var swipeToDismiss: Bool = true
    @IBInspectable var showNavigationBar: Bool = true {
        didSet {
            layoutIfNeeded()
        }
    }
    @IBInspectable var title: String? {
        didSet {
            layoutIfNeeded()
        }
    }
    
    
    //# MARK: - IBOutlets
    
    @IBOutlet weak var delegate: ModalCardViewDelegate?
    
    
    //# MARK: - Overridden Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        reloadViews()
    }
    
    
    //# MARK: - Private Methods
    
    private func reloadViews() {
        if let firstConstraint = navigationBarConstraints.first {
            if showNavigationBar && !constraints.contains(firstConstraint) {
                addConstraints(navigationBarConstraints)
            } else if !showNavigationBar && constraints.contains(firstConstraint) {
                removeConstraints(navigationBarConstraints)
            }
        }
        navigationBar.isHidden = !showNavigationBar
    }
    
    private func setup() {
        setupGestureRecognizer()
        setupViews()
        layoutIfNeeded()
    }
    
    private func setupGestureRecognizer() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(viewDragged(_:)))
        addGestureRecognizer(gestureRecognizer)
    }
    
    private func setupViews() {
        let navigationItem = UINavigationItem()
        
        if let delegate = delegate {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: delegate, action: #selector(delegate.closeButtonPressed(_:)))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: .none, action: .none)
        }
        navigationItem.leftBarButtonItem?.tintColor = UIColor.gray
        navigationBar.barTintColor = UIColor.white
        navigationBar.items = [navigationItem]
        navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : tintColor]
        navigationBar.topItem?.title = title
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        navigationBarConstraints = [
            NSLayoutConstraint(item: navigationBar, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: navigationBar, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: navigationBar, attribute: .trailing, multiplier: 1, constant: 0),
        ]
        
        addSubview(navigationBar)
    }
    
    @objc private func viewDragged(_ sender: UIPanGestureRecognizer) {
        if swipeToDismiss {
            if sender.state == .began {
                startPoint = center
            } else if sender.state == .changed {
                let y = startPoint.y + sender.translation(in: self).y
                
                if y > startPoint.y {
                    center = CGPoint(x: startPoint.x, y: y)
                }
            } else if sender.state == .ended {
                let y = startPoint.y + sender.translation(in: self).y
                
                if 1 - (self.startPoint.y / y) < kYThreshold {
                    UIView.animate(withDuration: kReturnToCenterDuration, animations: {
                        self.center = self.startPoint
                    })
                } else {
                    delegate?.closeButtonPressed(sender)
                }
            }
        }
    }
    
}
