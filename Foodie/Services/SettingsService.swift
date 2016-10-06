//
//  SettingsService.swift
//  Foodie
//
//  Created by Alton Lau on 2016-05-05.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import Foundation

enum DistanceSetting: Int {
    case near, middle, far, any
}

protocol SettingsService {
    
    var cuisineFilter: [Cuisine] { get set }
    var distanceFilter: DistanceSetting { get set }
    
}

class SettingsServiceImplementation: SettingsService {
    
    var cuisineFilter: [Cuisine] {
        get {
            if let data = get_pref(forKey: "cuisineFilter") as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? [Cuisine] ?? []
            }
            return []
        }
        set {
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            set_pref(object: data, withKey: "cuisineFilter")
        }
    }
    var distanceFilter: DistanceSetting {
        get {
            if let pref = get_pref(forKey: "distanceFilter") as? Int {
                return DistanceSetting(rawValue: pref) ?? .any
            }
            return .any
        }
        set {
            set_pref(object: newValue.rawValue, withKey: "distanceFilter")
        }
    }
    
}
