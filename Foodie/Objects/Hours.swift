//
//  Hours.swift
//  Foodie
//
//  Created by Alton Lau on 2016-09-17.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import Foundation

class Hours: NSObject {
    
    //# MARK: - Properties
    
    enum Weekday: Int {
        case Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
    }
    
    
    //# MARK: - Variables
    
    var from: Date
    var to: Date
    var weekday: Weekday
    
    
    //# MARK: - Init
    
    init(from: Date, to: Date, weekday: Weekday) {
        self.from = from
        self.to = to
        self.weekday = weekday
    }
    
    
    //# MARK: - Overridden Methods
    
    override var debugDescription: String {
        return description
    }
    
    override var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mma"
        return "\(weekday): \(dateFormatter.string(from: from)) ~ \(dateFormatter.string(from: to))"
    }
    
}
