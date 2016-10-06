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
    
    private let kButtonCornerRadius: CGFloat = 4.0
    private let kButtonMargin: CGFloat = 10.0
    private let kClockFrameBorderWidth: CGFloat = 5.0
    private let kClockMargin: CGFloat = 30.0
    private let kSecondHandWidth: CGFloat = 2.0
    private let kMinuteHandWidth: CGFloat = 3.0
    private let kHourHandWidth: CGFloat = 4.0
    private let kSecondHandScale: CGFloat = 0.8
    private let kMinuteHandScale: CGFloat = 0.8
    private let kHourHandScale: CGFloat = 0.5
    private let kSecondClockDivision: CGFloat = 360.0 / 60.0
    private let kMinuteClockDivision: CGFloat = 360.0 / 3600.0
    private let kHourClockDivision: CGFloat = 360.0 / 720.0
    private let kClockDivision: CGFloat = 360.0 / 12.0
    
    private let weekdayStrings = ["S", "M", "T", "W", "T", "F", "S"]
    private let dayTimesStrings = ["AM", "PM"]
    private let weekdayStackView = UIStackView()
    private let dayTimesStackView = UIStackView()
    
    
    //# MARK: - Variables
    
    private var shouldTick = false
    private var selectedWeekday = Hours.Weekday.Sunday
    private var selectedMorning = true
    
    private var clockFrameLayer = CALayer()
    private var timeStringLayers = [CATextLayer]()
    private var secondHandLayer = CAShapeLayer()
    private var minuteHandLayer = CAShapeLayer()
    private var hourHandLayer = CAShapeLayer()
    private var openingHoursLayer = CAShapeLayer()
    
    private var weekdayButtons = [UIButton]()
    
    var hours: [Hours] {
        didSet {
            reloadHours()
        }
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            reloadLayers()
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
    
    
    //# MARK: - Public Methods
    
    func startTick() {
        if !shouldTick {
            shouldTick = !shouldTick
            tick()
        }
    }
    
    func stopTick() {
        if shouldTick {
            shouldTick = !shouldTick
        }
    }
    
    
    //# MARK: - Private Methods
    
    private func setup() {
        setupLayers()
        setupViews()
        reloadLayers()
    }
    
    private func setupLayers() {
        clockFrameLayer = CAShapeLayer(layer: layer)
        clockFrameLayer.borderColor = UIColor.foodieGray.cgColor
        clockFrameLayer.borderWidth = kClockFrameBorderWidth
        layer.addSublayer(clockFrameLayer)
        
        for i in 1...12 {
            var hour = (i + 11) % 12
            if hour == 0 {
                hour += 12
            }
            let timeStringLayer = CATextLayer(layer: layer)
            timeStringLayer.alignmentMode = kCAAlignmentCenter
            timeStringLayer.contentsScale = UIScreen.main.scale
            timeStringLayer.foregroundColor = UIColor.foodieGray.cgColor
            timeStringLayer.string = String(hour)
            timeStringLayers.append(timeStringLayer)
            layer.addSublayer(timeStringLayer)
        }
        
        secondHandLayer = CAShapeLayer(layer: layer)
        secondHandLayer.contentsScale = UIScreen.main.scale
        secondHandLayer.fillColor = UIColor.clear.cgColor
        secondHandLayer.strokeColor = UIColor.foodie.cgColor
        secondHandLayer.lineWidth = kSecondHandWidth
        secondHandLayer.lineCap = kCALineCapRound
        layer.addSublayer(secondHandLayer)
        
        minuteHandLayer = CAShapeLayer(layer: layer)
        minuteHandLayer.contentsScale = UIScreen.main.scale
        minuteHandLayer.fillColor = UIColor.clear.cgColor
        minuteHandLayer.strokeColor = UIColor.foodieGray.cgColor
        minuteHandLayer.lineWidth = kMinuteHandWidth
        minuteHandLayer.lineCap = kCALineCapRound
        layer.addSublayer(minuteHandLayer)
        
        hourHandLayer = CAShapeLayer(layer: layer)
        hourHandLayer.contentsScale = UIScreen.main.scale
        hourHandLayer.fillColor = UIColor.clear.cgColor
        hourHandLayer.strokeColor = UIColor.foodieGray.cgColor
        hourHandLayer.lineWidth = kHourHandWidth
        hourHandLayer.lineCap = kCALineCapRound
        layer.addSublayer(hourHandLayer)
        
        openingHoursLayer = CAShapeLayer(layer: layer)
        openingHoursLayer.contentsScale = UIScreen.main.scale
        openingHoursLayer.fillColor = UIColor.clear.cgColor
        openingHoursLayer.strokeColor = UIColor.foodieLightGreen.cgColor
        openingHoursLayer.lineWidth = kClockFrameBorderWidth
        openingHoursLayer.lineCap = kCALineCapRound
        layer.addSublayer(openingHoursLayer)
    }
    
    private func setupViews() {
        if let weekday = Hours.Weekday(rawValue: Calendar.current.component(.weekday, from: Date()) - 1) {
            selectedWeekday = weekday
        }
        
        weekdayStackView.alignment = .center
        weekdayStackView.axis = .vertical
        weekdayStackView.translatesAutoresizingMaskIntoConstraints = false
        for i in 0..<weekdayStrings.count {
            let button = UIButton()
            button.addTarget(self, action: #selector(weekdayButtonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(weekdayButtonTouchUpInside(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(weekdayButtonTouchCancel(_:)), for: .touchCancel)
            button.setTitle(weekdayStrings[i], for: .normal)
            button.setTitleColor(UIColor.foodieGray, for: .normal)
            button.tag = i
            button.layer.cornerRadius = kButtonCornerRadius
            weekdayStackView.addArrangedSubview(button)
        }
        addSubview(weekdayStackView)
        
        dayTimesStackView.alignment = .center
        dayTimesStackView.axis = .vertical
        dayTimesStackView.translatesAutoresizingMaskIntoConstraints = false
        for i in 0..<dayTimesStrings.count {
            let button = UIButton()
            button.addTarget(self, action: #selector(dayTimeButtonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(dayTimeButtonTouchUpInside(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(dayTimeButtonTouchCancel(_:)), for: .touchCancel)
            button.setTitle(dayTimesStrings[i], for: .normal)
            button.setTitleColor(UIColor.foodieGray, for: .normal)
            button.tag = i
            button.layer.cornerRadius = kButtonCornerRadius
            dayTimesStackView.addArrangedSubview(button)
        }
        addSubview(dayTimesStackView)
        
        addConstraints([
            NSLayoutConstraint(item: weekdayStackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: kButtonMargin),
            NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: weekdayStackView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: dayTimesStackView, attribute: .trailing, multiplier: 1, constant: kButtonMargin),
            NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: dayTimesStackView, attribute: .centerY, multiplier: 1, constant: 0),
            ])
    }
    
    private func reloadLayers() {
        let diameter = min(bounds.width, bounds.height) - (2 * kClockMargin)
        
        // Clock frame
        clockFrameLayer.cornerRadius = diameter / 2
        clockFrameLayer.frame = CGRect(x: (bounds.size.width - diameter) / 2, y: (bounds.size.height - diameter) / 2, width: diameter, height: diameter)
        
        // Hour numbers on the clock
        for i in 0..<timeStringLayers.count {
            let center = CGPoint(x: clockFrameLayer.frame.origin.x + (clockFrameLayer.frame.size.width / 2), y: clockFrameLayer.frame.origin.y + (clockFrameLayer.frame.size.height / 2))
            let size = diameter / 12.0
            var point = getPointInClock(center: center, diameter: diameter * kSecondHandScale, division: kClockDivision, currentValue: CGFloat(i))
            point.x -= size / 2
            point.y -= size / 2
            timeStringLayers[i].frame = CGRect(x: point.x, y: point.y, width: size, height: size)
            timeStringLayers[i].font = UIFont.systemFont(ofSize: size - 2)
            timeStringLayers[i].fontSize = size - 2
        }
        
        // Clock hands
        secondHandLayer.frame = clockFrameLayer.frame
        minuteHandLayer.frame = clockFrameLayer.frame
        hourHandLayer.frame = clockFrameLayer.frame
        
        // Opening hours
        let openingHoursLayerPath = UIBezierPath()
        openingHoursLayerPath.move(to: CGPoint(x: 0, y: diameter - kClockFrameBorderWidth))
        openingHoursLayer.frame = clockFrameLayer.frame
        openingHoursLayer.path = openingHoursLayerPath.cgPath
    }
    
    private func reloadHours() {
        for i in 0..<weekdayStackView.arrangedSubviews.count {
            weekdayStackView.arrangedSubviews[i].backgroundColor = i == selectedWeekday.rawValue ? UIColor.foodieBackground : UIColor.clear
        }
        if let morningButton = dayTimesStackView.arrangedSubviews.first, let afternoonButton = dayTimesStackView.arrangedSubviews.last {
            morningButton.backgroundColor = selectedMorning ? UIColor.foodieBackground : UIColor.clear
            afternoonButton.backgroundColor = selectedMorning ? UIColor.clear : UIColor.foodieBackground
        }
        
        let selectedHours = hours.filter { (hours) -> Bool in
            let hour = Calendar.current.component(.hour, from: hours.from)
            var shouldReturn = false
            if selectedMorning {
                shouldReturn = hour < 12
            } else {
                shouldReturn = hour >= 12
            }
            return hours.weekday == selectedWeekday && shouldReturn
        }
        
        // Drawing the opening hours
        
        let center = CGPoint(x: clockFrameLayer.frame.size.width / 2, y: clockFrameLayer.frame.size.height / 2)
        let diameter = clockFrameLayer.frame.size.width - (3 * kClockFrameBorderWidth)
        let openingHoursLayerPath = UIBezierPath()
        
        for hours in selectedHours {
            let fromComponents = Calendar.current.dateComponents([.hour, .minute], from: hours.from)
            let toComponents = Calendar.current.dateComponents([.hour, .minute], from: hours.to)
            
            if let fromHour = fromComponents.hour, let fromMinute = fromComponents.minute, let toHour = toComponents.hour, let toMinute = toComponents.minute {
                let startPoint = getPointInClock(center: center, diameter: diameter, division: kHourClockDivision, currentValue: CGFloat((fromHour * 60) + fromMinute))
                let startAngle = getAngle(division: kHourClockDivision, currentValue: CGFloat((fromHour * 60) + fromMinute))
                let endAngle = getAngle(division: kHourClockDivision, currentValue: CGFloat((toHour * 60) + toMinute))
                
                openingHoursLayerPath.move(to: startPoint)
                openingHoursLayerPath.addArc(withCenter: center, radius: diameter / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            }
        }
        
        openingHoursLayer.path = openingHoursLayerPath.cgPath
    }
    
    private func tick() {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        if let hour = components.hour, let minute = components.minute, let second = components.second, shouldTick {
            let center = CGPoint(x: clockFrameLayer.frame.size.width / 2, y: clockFrameLayer.frame.size.height / 2)
            let diameter = clockFrameLayer.frame.size.width
            let secondHandLayerPath = UIBezierPath()
            let minuteHandLayerPath = UIBezierPath()
            let hourHandLayerPath = UIBezierPath()
            
            secondHandLayerPath.move(to: center)
            secondHandLayerPath.addLine(to: getPointInClock(center: center, diameter: diameter * kSecondHandScale, division: kSecondClockDivision, currentValue: CGFloat(second)))
            secondHandLayer.path = secondHandLayerPath.cgPath
            
            minuteHandLayerPath.move(to: center)
            minuteHandLayerPath.addLine(to: getPointInClock(center: center, diameter: diameter * kMinuteHandScale, division: kMinuteClockDivision, currentValue: (CGFloat(minute) * 60.0) + CGFloat(second)))
            minuteHandLayer.path = minuteHandLayerPath.cgPath
            
            hourHandLayerPath.move(to: center)
            hourHandLayerPath.addLine(to: getPointInClock(center: center, diameter: diameter * kHourHandScale, division: kHourClockDivision, currentValue: (CGFloat(hour) * 60.0) + CGFloat(minute)))
            hourHandLayer.path = hourHandLayerPath.cgPath
            
            dispatch_later(0.1, block: {
                self.tick()
            })
        }
    }
    
    private func getPointInClock(center: CGPoint, diameter: CGFloat, division: CGFloat, currentValue: CGFloat) -> CGPoint {
        let angle = getAngle(division: division, currentValue: currentValue)
        let x = (diameter * cos(angle) / 2) + center.x
        let y = (diameter * sin(angle) / 2) + center.y
        
        return CGPoint(x: x, y: y)
    }
    
    private func getAngle(division: CGFloat, currentValue: CGFloat) -> CGFloat {
        return ((CGFloat(currentValue) * division) - 90.0) * CGFloat(M_PI) / 180.0
    }
    
    @objc private func dayTimeButtonTouchDown(_ sender: UIButton) {
        sender.backgroundColor = UIColor.foodieLightBlue
    }
    
    @objc private func dayTimeButtonTouchUpInside(_ sender: UIButton) {
        sender.backgroundColor = UIColor.clear
        if let morningTimeString = dayTimesStrings.first {
            selectedMorning = dayTimesStrings[sender.tag] == morningTimeString
            reloadHours()
        }
    }
    
    @objc private func dayTimeButtonTouchCancel(_ sender: UIButton) {
        sender.backgroundColor = UIColor.clear
    }
    
    @objc private func weekdayButtonTouchDown(_ sender: UIButton) {
        sender.backgroundColor = UIColor.foodieLightBlue
    }
    
    @objc private func weekdayButtonTouchUpInside(_ sender: UIButton) {
        sender.backgroundColor = UIColor.clear
        if let weekday = Hours.Weekday(rawValue: sender.tag) {
            selectedWeekday = weekday
            reloadHours()
        }
    }
    
    @objc private func weekdayButtonTouchCancel(_ sender: UIButton) {
        sender.backgroundColor = UIColor.clear
    }
    
}
