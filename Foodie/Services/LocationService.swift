//
//  LocationService.swift
//  Foodie
//
//  Created by Alton Lau on 2016-08-27.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import CoreLocation

protocol LocationService {
    
    func getAddress(fromLocation location: CLLocation, completion: @escaping (String?) -> Void)
    func getLocation(fromAddress address: String, completion: @escaping (CLLocation?) -> Void)
    
}

class LocationServiceImplementation: LocationService {
    
    func getAddress(fromLocation location: CLLocation, completion: @escaping (String?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)) { (placemarks, error) in
            if let error = error {
                Log.error(error.localizedDescription)
                completion(.none)
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(.none)
                return
            }
            
            let address: String = {
                var addressList = [String]()
                if let name = placemark.name {
                    addressList.append(name)
                }
                if let locality = placemark.locality {
                    addressList.append(locality)
                }
                if let administrativeArea = placemark.administrativeArea {
                    addressList.append(administrativeArea)
                }
                if let country = placemark.country {
                    addressList.append(country)
                }
                return addressList.joined(separator: ", ")
            }()
            
            completion(address)
        }
    }
    
    func getLocation(fromAddress address: String, completion: @escaping (CLLocation?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                Log.error(error.localizedDescription)
                completion(.none)
                return
            }
            
            guard let location = placemarks?.first?.location else {
                completion(.none)
                return
            }
            
            completion(location)
        }
    }
    
}
