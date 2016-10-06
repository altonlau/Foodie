//
//  ModalCardViewController.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-23.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

class ModalCardViewController: UIViewController {
    
    //# MARK: - Constants
    
    private let tapView = UIView()
    
    
    //# MARK: - IBOutlets
    
    @IBOutlet weak var modalCardView: ModalCardView!
    
    
    //# MARK: - Overridden Methods
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        closeButtonPressed(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestureRecognizers()
    }
    
    
    //# MARK: - Private Methods
    
    private func setupViews() {
        if let topView = view.subviews.first {
            tapView.frame = view.bounds
            view.insertSubview(tapView, belowSubview: topView)
        }
    }
    
    private func setupGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeButtonPressed(_:)))
        
        tapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
}

extension ModalCardViewController: ModalCardViewDelegate {
    
    //# MARK: - ModalCardViewDelegate Methods
    
    func closeButtonPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: FoodieUnwindSegueIdentifier, sender: self)
    }
    
}
