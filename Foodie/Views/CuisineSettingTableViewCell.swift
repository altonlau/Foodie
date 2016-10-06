//
//  CuisineSettingTableViewCell.swift
//  Foodie
//
//  Created by Alton Lau on 2016-05-05.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

class CuisineSettingTableViewCell: UITableViewCell {
    
    //# MARK: - Variables
    
    var name: String {
        get {
            return nameLabel.text ?? ""
        }
        set {
            nameLabel.text = newValue
        }
    }
    var type: String {
        get {
            return typeLabel.text ?? ""
        }
        set {
            typeLabel.text = newValue
            layoutIfNeeded()
        }
    }
    
    
    //# MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabelCenterYConstraint: NSLayoutConstraint!
    
    
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
        contentView.removeConstraint(nameLabelCenterYConstraint)
        if type.isEmpty {
            nameLabelCenterYConstraint = NSLayoutConstraint(item: nameLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
        } else {
            nameLabelCenterYConstraint = NSLayoutConstraint(item: nameLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 4)
        }
        contentView.addConstraint(nameLabelCenterYConstraint)
    }
    
    private func setup() {
        setupViews()
        layoutIfNeeded()
    }
    
    private func setupViews() {
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.foodieLightBlue
    }
    
}
