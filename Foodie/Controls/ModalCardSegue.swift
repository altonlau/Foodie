//
//  ModalCardSegue.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-23.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

class ModalCardSegue: UIStoryboardSegue {
    
    //# MARK: - Constants
    
    private let kInitialSpringVelocity: CGFloat = 1.0
    private let kSpringDamping: CGFloat = 0.8
    private let kTintAlpha: CGFloat = 0.2
    
    
    //# MARK: - Overridden Methods
    
    override func perform() {
        if let window = UIApplication.shared.keyWindow {
            let fromView: UIView = source.view
            let toView: UIView = destination.view
            let tintView = UIView(frame: fromView.bounds)
            
            toView.transform = CGAffineTransform(translationX: 0, y: fromView.bounds.height)
            window.insertSubview(toView, aboveSubview: fromView)
            
            tintView.alpha = 0
            tintView.backgroundColor = UIColor.black
            tintView.tag = ModalCardSegueTintViewTag
            fromView.addSubview(tintView)
            
            UIView.animate(withDuration: ModalCardSegueAnimationDuration, delay: 0, usingSpringWithDamping: kSpringDamping, initialSpringVelocity: kInitialSpringVelocity, options: .curveEaseInOut, animations: {
                toView.transform = CGAffineTransform.identity
                }, completion: { (_) in
                    self.destination.modalPresentationStyle = .overCurrentContext
                    self.source.present(self.destination, animated: false, completion: .none)
            })
            
            UIView.animate(withDuration: ModalCardSegueAnimationDuration / 2, animations: {
                tintView.alpha = self.kTintAlpha
            })
        }
    }
    
}

class ModalCardUnwindSegue: UIStoryboardSegue {
    
    //# MARK: - Overridden Methods
    
    override func perform() {
        let fromView: UIView = source.view
        let toView: UIView = destination.view
        let tintView = toView.viewWithTag(ModalCardSegueTintViewTag)
        
        UIView.animate(withDuration: ModalCardSegueAnimationDuration / 2, animations: { 
            tintView?.alpha = 0
            fromView.transform = CGAffineTransform(translationX: 0, y: fromView.bounds.height)
            }) { (_) in
                tintView?.removeFromSuperview()
                self.destination.dismiss(animated: false, completion: .none)
        }
    }
    
}
