//
//  RestaurantService
//  Foodie
//
//  Created by Alton Lau on 2016-04-16.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import Foundation
import MapKit
import RealmSwift
import UIKit

protocol RestaurantService {
    
    func insert(_ restaurant: Restaurant) -> Bool
    func get(_ restaurant: Restaurant) -> Restaurant?
    func get(name: String, cuisines: [Cuisine], location: CLLocation, image: UIImage?) -> Restaurant?
    func get(_ name: String) -> [Restaurant]?
    func getAll() -> [Restaurant]?
    func getRandom() -> Restaurant?
    func getRandom(_ location: CLLocation) -> Restaurant?
    func remove(_ restaurant: Restaurant)
    func removeAll()
    func update(old: Restaurant, new: Restaurant) -> Bool
    
}

class RestaurantServiceImplementation: RestaurantService {
    
    private let middleDistanceRange = [1000.0, 5000.0]
    
    func insert(_ restaurant: Restaurant) -> Bool {
        if get(restaurant) == .none {
            do {
                let realm = try Realm()
                try realm.write {
                    let cuisineRealmList = List<CuisineRealm>()
                    
                    for cuisine in restaurant.cuisines {
                        let cuisinePredicate = NSPredicate(format: "name = %@ AND type = %@", cuisine.name, cuisine.type)
                        if let cuisineRealm = realm.objects(CuisineRealm.self).filter(cuisinePredicate).first {
                            cuisineRealmList.append(cuisineRealm)
                        } else {
                            cuisineRealmList.append(CuisineRealm(value: [cuisine.name, cuisine.type]))
                        }
                    }
                    
                    let restaurantRealm = RestaurantRealm(value: ["name" : restaurant.name, "cuisines" : cuisineRealmList, "latitude" : restaurant.location.coordinate.latitude, "longitude" : restaurant.location.coordinate.longitude])
                    if let image = restaurant.image {
                        restaurantRealm.image = UIImagePNGRepresentation(image)
                    }
                    
                    realm.add(restaurantRealm)
                }
                
                return true
            } catch let error as NSError {
                Log.error(error.localizedDescription)
            }
        }
        
        return false
    }
    
    func get(_ restaurant: Restaurant) -> Restaurant? {
        return get(name: restaurant.name, cuisines: restaurant.cuisines, location: restaurant.location, image: restaurant.image)
    }
    
    func get(name: String, cuisines: [Cuisine], location: CLLocation, image: UIImage?) -> Restaurant? {
        return get(name)?.filter({ (restaurant) -> Bool in
            Restaurant(name: name, cuisines: cuisines, location: location, image: image).isEqual(restaurant)
        }).first
    }
    
    func get(_ name: String) -> [Restaurant]? {
        return getAll()?.filter({ (restaurant) -> Bool in
            restaurant.name.lowercased().replacingOccurrences(of: " ", with: "") == name.lowercased().replacingOccurrences(of: " ", with: "")
        })
    }
    
    func getAll() -> [Restaurant]? {
        do {
            let realm = try Realm()
            let restaurantRealmResult = realm.objects(RestaurantRealm.self)
            var restaurantList = [Restaurant]()
            
            for restaurantRealm in Array(restaurantRealmResult) {
                restaurantList.append(get(fromRealm: restaurantRealm))
            }
            
            if restaurantList.count > 0 {
                return restaurantList
            }
        } catch let error as NSError {
            Log.error(error.localizedDescription)
        }
        
        return .none
    }
    
    func getRandom() -> Restaurant? {
        guard var restaurantList = getAll() else {
            return .none
        }
        let settingsService = AllServices.services.container.resolve(SettingsService.self)!
        
        if settingsService.cuisineFilter.count > 0 {
            restaurantList = restaurantList.filter({ (restaurant) -> Bool in
                for cuisine in restaurant.cuisines {
                    if settingsService.cuisineFilter.contains(cuisine) {
                        return true
                    }
                }
                
                return false
            })
        }
        
        if restaurantList.count > 0 {
            return restaurantList[Int(arc4random_uniform(UInt32(restaurantList.count)))]
        }
        
        return .none
    }
    
    func getRandom(_ location: CLLocation) -> Restaurant? {
        guard var restaurantList = getAll() else {
            return .none
        }
        let settingsService = AllServices.services.container.resolve(SettingsService.self)!
        
        if settingsService.cuisineFilter.count > 0 {
            restaurantList = restaurantList.filter({ (restaurant) -> Bool in
                for cuisine in restaurant.cuisines {
                    if settingsService.cuisineFilter.contains(cuisine) {
                        return true
                    }
                }
                
                return false
            })
        }
        
        if settingsService.distanceFilter != .any {
            restaurantList = restaurantList.filter({ (restaurant) -> Bool in
                let distance = location.distance(from: restaurant.location)
                
                switch (settingsService.distanceFilter) {
                case .near: return distance <= middleDistanceRange[0]
                case .middle: return middleDistanceRange[0] < distance && distance <= middleDistanceRange[1]
                case .far: return middleDistanceRange[1] < distance
                default: return true
                }
            })
        }
        
        if restaurantList.count > 0 {
            return restaurantList[Int(arc4random_uniform(UInt32(restaurantList.count)))]
        }
        
        return .none
    }
    
    func remove(_ restaurant: Restaurant) {
        var restaurantRealmResult: Results<RestaurantRealm>
        
        do {
            let realm = try Realm()
            let cuisineRealmList = List<CuisineRealm>()
            var restaurantPredicate: NSPredicate
            
            for cuisine in restaurant.cuisines {
                let cuisinePredicate = NSPredicate(format: "name = %@ AND type = %@", cuisine.name, cuisine.type)
                if let cuisineRealm = realm.objects(CuisineRealm.self).filter(cuisinePredicate).first {
                    cuisineRealmList.append(cuisineRealm)
                }
            }
            
            if cuisineRealmList.count > 0 {
                restaurantPredicate = NSPredicate(format: "name = %@ AND ANY cuisines IN %@", restaurant.name, cuisineRealmList)
                restaurantRealmResult = realm.objects(RestaurantRealm.self).filter(restaurantPredicate)
            } else {
                restaurantPredicate = NSPredicate(format: "name = %@", restaurant.name)
                restaurantRealmResult = realm.objects(RestaurantRealm.self).filter(restaurantPredicate)
            }
            
            if let restaurantRealm = restaurantRealmResult.first {
                try realm.write {
                    realm.delete(restaurantRealm)
                }
            }
        } catch let error as NSError {
            Log.error(error.localizedDescription)
        }
    }
    
    func removeAll() {
        do {
            let realm = try Realm()
            let restaurantRealmResult = realm.objects(RestaurantRealm.self)
            
            try realm.write {
                for restaurantRealm in restaurantRealmResult {
                    realm.delete(restaurantRealm)
                }
            }
        } catch let error as NSError {
            Log.error(error.localizedDescription)
        }
    }
    
    func update(old: Restaurant, new: Restaurant) -> Bool {
        if get(old) == .none {
            return false
        }
        
        if let restaurantList = get(new.name), restaurantList.count <= 1 {
            if let restaurant = restaurantList.first, restaurant.isEqual(old) && insert(new) {
                remove(old)
                return true
            } else if restaurantList.isEmpty && insert(new) {
                remove(old)
                return true
            }
        }
        
        return false
    }
    
    private func get(fromRealm realm: RestaurantRealm) -> Restaurant {
        var cuisineList = [Cuisine]()
        
        for cuisineRealm in realm.cuisines {
            cuisineList.append(Cuisine(name: cuisineRealm.name, type: cuisineRealm.type))
        }
        
        let latitude = realm.latitude
        let longitude = realm.longitude
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        let image: UIImage? = {
            guard let imageData = realm.image else {
                return .none
            }
            
            return UIImage(data: imageData)
        }()
        
        return Restaurant(name: realm.name, cuisines: cuisineList, location: location, image: image)
    }
    
}
