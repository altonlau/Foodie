//
//  Cuisine.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-16.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import Foundation
import RealmSwift

class Cuisine: NSObject, NSCoding {
    
    //# MARK: - Variables
    
    var name: String
    var type: String
    
    
    //# MARK: - Init
    
    init(name: String, type: String? = "") {
        self.name = name
        self.type = type ?? ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        type = aDecoder.decodeObject(forKey: "type") as? String ?? ""
        super.init()
    }
    
    //# MARK: - Overridden Methods
    
    override var debugDescription: String {
        return description
    }
    
    override var description: String {
        return ["name" : name, "type" : type].description
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? Cuisine {
            return self == object
        }
        return false
    }
    
    
    //# MARK: - NSCoding Methods
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(type, forKey: "type")
    }
    
    
    //# MARK: - Public Methods
    
    func matches(_ queryString: String) -> Bool {
        return name.lowercased().contains(queryString.lowercased()) || type.lowercased().contains(queryString.lowercased())
    }
    
}

class CuisineRealm: Object {
    
    dynamic var name = ""
    dynamic var type = ""
    
}

func ==(lhs: Cuisine, rhs: Cuisine) -> Bool {
    return lhs.name == rhs.name && lhs.type == rhs.type
}
