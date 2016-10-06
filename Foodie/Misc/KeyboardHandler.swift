//
//  KeyboardHandler.swift
//  Foodie
//
//  Created by Alton Lau on 2016-08-25.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

class KeyboardHandler {
    
    //# MARK: - Constants
    
    private let kAnimationCurveShiftValue = 16
    
    
    //# MARK: - Variables
    
    private var slideAmount: CGFloat = 0.0
    
    var enabled: Bool = true
    var keyboardIsVisible = false
    var referenceView: UIView
    var slideView: UIView
    
    
    //# MARK: - Init
    
    init(referenceView: UIView = UIView(), slideView: UIView = UIView()) {
        self.referenceView = referenceView
        self.slideView = slideView
        
        setupNotifications()
    }
    
    deinit {
        removeNotifications()
    }
    
    
    //# MARK: - Private Methods
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: .none)
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        if enabled && !keyboardIsVisible {
            if let userInfo = notification.userInfo, let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double, let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int, let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                let animationOption = UIViewAnimationOptions(rawValue: UInt(animationCurve << kAnimationCurveShiftValue))
                keyboardIsVisible = !keyboardIsVisible
                slideAmount = max(0.0, referenceView.frame.maxY - keyboardFrame.minY)
                UIView.animate(withDuration: animationDuration, delay: 0, options: animationOption, animations: {
                    self.slideView.frame.origin.y -= self.slideAmount
                    }, completion: .none)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        if let userInfo = notification.userInfo, let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double, let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int {
            let animationOption = UIViewAnimationOptions(rawValue: UInt(animationCurve << kAnimationCurveShiftValue))
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationOption, animations: {
                self.slideView.frame.origin.y += self.slideAmount
                }, completion: { (Bool) in
                    self.keyboardIsVisible = !self.keyboardIsVisible
                    self.slideAmount = 0.0
            })
        }
    }
    
}
