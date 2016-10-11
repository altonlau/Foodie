//
//  HoursView.swift
//  Foodie
//
//  Created by Alton Lau on 2016-09-17.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

class HoursView: UIView {
    
    //# MARK: - Constants
    
    private let kTextSeparation: CGFloat = 8.0
    
    private let mondayLabel = UILabel()
    private let tuesdayLabel = UILabel()
    private let wednesdayLabel = UILabel()
    private let thursdayLabel = UILabel()
    private let fridayLabel = UILabel()
    private let saturdayLabel = UILabel()
    private let sundayLabel = UILabel()
    private let weekdayStrings = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    //# MARK: - Variables
    
    var hours: [Hours] {
        didSet {
            reloadHours()
        }
    }
    
    
    //# MARK: - Init
    
    init() {
        self.hours = []
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //# MARK: - Private Methods
    
    private func reloadHours() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mma"
        for hour in hours {
            let text = "\(dateFormatter.string(from: hour.from)) - \(dateFormatter.string(from: hour.to))"
            switch hour.weekday {
            case .sunday:
                sundayLabel.text = text
            case .monday:
                mondayLabel.text = text
            case .tuesday:
                tuesdayLabel.text = text
            case .wednesday:
                wednesdayLabel.text = text
            case .thursday:
                thursdayLabel.text = text
            case .friday:
                fridayLabel.text = text
            case .saturday:
                saturdayLabel.text = text
            }
        }
        let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: Date())
        guard let hour = components.hour, let minute = components.minute, let weekday = components.weekday else {
            return
        }
        let fromComponents = Calendar.current.dateComponents([.weekday, .hour], from: hours[weekday - 1].from)
        let toComponents = Calendar.current.dateComponents([.weekday, .hour, .minute], from: hours[weekday - 1].to)
        guard let fromHour = fromComponents.hour, let toHour = toComponents.hour, let toMinute = toComponents.minute else {
            return
        }
        if (hour >= fromHour && hour < toHour) || (hour == toHour && minute <= toMinute) {
            backgroundColor = UIColor.foodieLightGreen
        } else {
            backgroundColor = UIColor.foodieLightRed
        }
    }
    
    private func setup() {
        setupViews()
    }
    
    private func setupViews() {
        let weekdayStackView = UIStackView()
        for weekdayString in weekdayStrings {
            let weekdayLabel = UILabel()
            weekdayLabel.font = UIFont.boldSystemFont(ofSize: weekdayLabel.font.pointSize)
            weekdayLabel.text = weekdayString
            weekdayLabel.textColor = UIColor.foodieGray
            weekdayStackView.addArrangedSubview(weekdayLabel)
        }
        weekdayStackView.alignment = .trailing
        weekdayStackView.axis = .vertical
        weekdayStackView.spacing = kTextSeparation
        weekdayStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let hoursStackView = UIStackView(arrangedSubviews: [mondayLabel, tuesdayLabel, wednesdayLabel, thursdayLabel, fridayLabel, saturdayLabel, sundayLabel])
        for label in [mondayLabel, tuesdayLabel, wednesdayLabel, thursdayLabel, fridayLabel, saturdayLabel, sundayLabel] {
            label.textColor = UIColor.foodieGray
        }
        hoursStackView.alignment = .leading
        hoursStackView.axis = .vertical
        hoursStackView.spacing = kTextSeparation
        hoursStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalStackView = UIStackView(arrangedSubviews: [weekdayStackView, hoursStackView])
        horizontalStackView.alignment = .center
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = kTextSeparation * 2
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(horizontalStackView)
        
        addConstraints([
            NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: horizontalStackView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: horizontalStackView, attribute: .centerY, multiplier: 1, constant: 0)
            ])
    }
    
}
