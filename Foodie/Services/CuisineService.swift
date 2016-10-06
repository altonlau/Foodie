//
//  CuisineService.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-16.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import Foundation
import RealmSwift

protocol CuisineService {
    
    func insert(_ cuisine: Cuisine) -> Bool
    func get(_ cuisine: Cuisine) -> Cuisine?
    func get(name: String, type: String) -> Cuisine?
    func get(_ name: String) -> [Cuisine]?
    func getAll() -> [Cuisine]?
    func remove(_ cuisine: Cuisine)
    func removeAll()
    func update(old: Cuisine, new: Cuisine) -> Bool
    
}

class CuisineServiceImplementation: CuisineService {
    
    func insert(_ cuisine: Cuisine) -> Bool {
        if get(cuisine) == .none {
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(CuisineRealm(value: [cuisine.name, cuisine.type]))
                }
                
                return true
            } catch let error as NSError {
                Log.error(error.localizedDescription)
            }
        }
        
        return false
    }
    
    func get(_ cuisine: Cuisine) -> Cuisine? {
        return get(name: cuisine.name, type: cuisine.type)
    }
    
    func get(name: String, type: String) -> Cuisine? {
        if let cuisineList = get(name) {
            return cuisineList.filter({ (cuisine) -> Bool in
                cuisine.type.lowercased().replacingOccurrences(of: " ", with: "") == type.lowercased().replacingOccurrences(of: " ", with: "")
            }).first
        }
        
        return .none
    }
    
    func get(_ name: String) -> [Cuisine]? {
        if let cuisineList = getAll() {
            return cuisineList.filter({ (cuisine) -> Bool in
                cuisine.name.lowercased().replacingOccurrences(of: " ", with: "") == name.lowercased().replacingOccurrences(of: " ", with: "")
            })
        }
        
        return .none
    }
    
    func getAll() -> [Cuisine]? {
        do {
            let realm = try Realm()
            let cuisineRealmResult = realm.objects(CuisineRealm.self)
            var cuisineList = [Cuisine]()
            
            for cuisineRealm in Array(cuisineRealmResult) {
                cuisineList.append(get(fromRealm: cuisineRealm))
            }
            
            if cuisineList.count > 0 {
                return cuisineList
            }
        } catch let error as NSError {
            Log.error(error.localizedDescription)
        }
        
        return .none
    }
    
    func remove(_ cuisine: Cuisine) {
        do {
            let realm = try Realm()
            let cuisinePredicate = NSPredicate(format: "name = %@ AND type = %@", cuisine.name, cuisine.type)
            if let cuisineRealm = realm.objects(CuisineRealm.self).filter(cuisinePredicate).first {
                try realm.write {
                    realm.delete(cuisineRealm)
                }
            }
        } catch let error as NSError {
            Log.error(error.localizedDescription)
        }
    }
    
    func removeAll() {
        do {
            let realm = try Realm()
            let cuisineRealmResult = realm.objects(CuisineRealm.self)
            
            try realm.write {
                for cuisineRealm in cuisineRealmResult {
                    realm.delete(cuisineRealm)
                }
            }
        } catch let error as NSError {
            Log.error(error.localizedDescription)
        }
    }
    
    func update(old: Cuisine, new: Cuisine) -> Bool {
        do {
            let realm = try Realm()
            var cuisinePredicate = NSPredicate(format: "name = %@ AND type = %@", new.name, new.type)
            var cuisineRealmResult = realm.objects(CuisineRealm.self).filter(cuisinePredicate)
            
            if cuisineRealmResult.isEmpty {
                cuisinePredicate = NSPredicate(format: "name = %@ AND type = %@", old.name, old.type)
                cuisineRealmResult = realm.objects(CuisineRealm.self).filter(cuisinePredicate)
                
                if let cuisineRealm = cuisineRealmResult.first {
                    try realm.write({
                        cuisineRealm.name = new.name
                        cuisineRealm.type = new.type
                    })
                    
                    return true
                }
            }
        } catch let error as NSError {
            Log.error(error.localizedDescription)
        }
        
        return false
    }
    
    private func get(fromRealm realm: CuisineRealm) -> Cuisine {
        return Cuisine(name: realm.name, type: realm.type)
    }
    
}
