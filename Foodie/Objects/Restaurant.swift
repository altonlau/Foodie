//
//  Restaurant.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-16.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import CoreLocation
import Foundation
import RealmSwift
import UIKit

class Restaurant: NSObject {
    
    //# MARK: - Variables
    
    var name: String
    var cuisines: [Cuisine]
    var image: UIImage?
    var location: CLLocation
    
    
    //# MARK: - Init
    
    init(name: String, cuisines: [Cuisine], location: CLLocation, image: UIImage? = .none) {
        self.name = name
        self.cuisines = cuisines
        self.image = image
        self.location = location
    }
    
    
    //# MARK: - Overridden Methods
    
    override var debugDescription: String {
        return description
    }
    
    override var description: String {
        return ["name" : name, "cuisines" : cuisines, "location" : "[\(location.coordinate.latitude),\(location.coordinate.longitude)]", "image" : (image != .none) ? "Has Image" : "No Image"].description
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? Restaurant {
            return self == object
        }
        return false
    }
    
    
    //# MARK: - Public Methods
    
    func matches(_ queryString: String) -> Bool {
        return name.lowercased().contains(queryString.lowercased())
    }
    
}

class RestaurantRealm: Object {
    
    dynamic var name = ""
    let cuisines = List<CuisineRealm>()
    dynamic var image: Data? = .none
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    
}

func ==(lhs: Restaurant, rhs: Restaurant) -> Bool {
    let nameIsEqual = lhs.name.lowercased().replacingOccurrences(of: " ", with: "") == rhs.name.lowercased().replacingOccurrences(of: " ", with: "")
    let cuisinesIsEqual = lhs.cuisines.elementsEqual(rhs.cuisines)
    let locationIsEqual = lhs.location.coordinate.latitude == rhs.location.coordinate.latitude && lhs.location.coordinate.longitude == rhs.location.coordinate.longitude
    
    if let lhsImage = lhs.image, let rhsImage = rhs.image, let imageData = UIImagePNGRepresentation(lhsImage), let compareImageData = UIImagePNGRepresentation(rhsImage) {
        return nameIsEqual && cuisinesIsEqual && locationIsEqual && imageData == compareImageData
    }
    
    if (lhs.image == .none && rhs.image != .none) || (lhs.image != .none && rhs.image == .none) {
        return false
    }
    
    return nameIsEqual && cuisinesIsEqual && locationIsEqual
}
