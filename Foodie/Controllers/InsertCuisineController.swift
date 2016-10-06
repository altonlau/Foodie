//
//  InsertCuisineController.swift
//  Foodie
//
//  Created by Alton Lau on 2016-08-23.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

class InsertCuisineController: ModalCardViewController {
    
    //# MARK: - Constants
    
    private let kErrorAnimationDuration: Double = 0.2
    private let kAlreadyExistsError = "Cuisine Already Exists"
    private let kMissingError = "Missing Cuisine Name"
    
    private let cuisineService = AllServices.services.container.resolve(CuisineService.self)!
    private let keyboardHandler = KeyboardHandler()
    
    
    //# MARK: - IBOutlets
    
    @IBOutlet weak var errorView: RoundedView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var cuisineNameTextField: UITextField!
    @IBOutlet weak var cuisineTypeTextField: UITextField!
    
    
    //# MARK: - IBActions
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        guard let cuisineName = cuisineNameTextField.text, !cuisineName.isEmpty else {
            showError(withMessage: kMissingError)
            return
        }
        
        let newCuisine = Cuisine(name: cuisineName, type: cuisineTypeTextField.text)
        
        if cuisineService.insert(newCuisine) {
            closeButtonPressed(sender)
        } else {
            showError(withMessage: kAlreadyExistsError)
        }
    }
    
    @IBAction func viewTapped(_ sender: AnyObject) {
        if cuisineNameTextField.isFirstResponder {
            cuisineNameTextField.resignFirstResponder()
        }
        
        if cuisineTypeTextField.isFirstResponder {
            cuisineTypeTextField.resignFirstResponder()
        }
    }
    
    
    //# MARK: - Overridden Methods
    
    override func closeButtonPressed(_ sender: AnyObject) {
        if cuisineNameTextField.isFirstResponder || cuisineTypeTextField.isFirstResponder {
            viewTapped(sender)
        } else {
            ((presentingViewController as? UINavigationController)?.topViewController as? InsertFoodieController)?.updateView()
            super.closeButtonPressed(sender)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardHandler()
    }
    
    
    //# MARK: - Private Methods
    
    private func showError(withMessage message: String) {
        errorView.isHidden = false
        errorLabel.text = message
        UIView.animate(withDuration: kErrorAnimationDuration, animations: {
            self.errorView.alpha = 1
        })
    }
    
    private func setupKeyboardHandler() {
        keyboardHandler.referenceView = modalCardView
        keyboardHandler.slideView = view
    }
    
}
