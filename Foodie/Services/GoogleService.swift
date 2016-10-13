//
//  GoogleService.swift
//  Foodie
//
//  Created by Alton Lau on 2016-10-08.
//  Copyright © 2016 Alton. All rights reserved.
//

import Alamofire
import CoreGraphics
import CoreLocation
import UIKit

enum TravelMode: String {
    case walking = "walking"
    case bicycling = "bicycling"
    case driving = "driving"
    case transit = "transit"
}

protocol GoogleService {
    
    func getDetails(for place: [String : Any], completion: @escaping (_ result: [String : Any]?) -> Void)
    func getPhoto(for place: [String : Any], size: CGSize, completion: @escaping (_ result: UIImage?) -> Void)
    func getTravelTime(from fromLoc: CLLocation, to toLoc: CLLocation, completion: @escaping (_ result: [(mode: TravelMode, duration: TimeInterval)]) -> Void)
    func openMapsApplication(fromLocation fromLoc: CLLocation, toLocation toLoc: CLLocation, mode: TravelMode)
    func searchLocation(name: String, location: CLLocation, radius: Int, completion: @escaping (_ result: [String : Any]?) -> Void)
    
}

class GoogleServiceImplementation: GoogleService {
    
    private let kBaseUrl = "https://maps.googleapis.com/maps/api"
    private let kDetailsUrl = "/details"
    private let kDataTypeUrl = "/json"
    private let kPlaceUrl = "/place"
    private let kPhotoUrl = "/photo"
    private let kSearchUrl = "/nearbysearch"
    private let kTravelUrl = "/distancematrix"
    private let kSuccessStatusCode = 200
    
    private let kAppleMapsBaseUrl = "http://maps.apple.com/"
    private let kGoogleMapsBaseUrl = "comgooglemaps://"
    
    private let kDefaultMapZoomLevel: Float = 15.0
    private let kMinSize: CGFloat = 1.0
    private let kMaxSize: CGFloat = 1600.0
    
    func getDetails(for place: [String : Any], completion: @escaping (_ result: [String : Any]?) -> Void) {
        if !ShouldUseGoogleAPI {
            completion(.none)
            return
        }
        guard let id = place["place_id"] as? String else {
            completion(.none)
            return
        }
        let params: Parameters = [
            "placeid" : id,
            "key" : GoogleApiKey
        ]
        request(url: "\(kBaseUrl)\(kPlaceUrl)\(kDetailsUrl)\(kDataTypeUrl)", parameters: params) { (response) in
            completion(response)
        }
    }
    
    func getPhoto(for place: [String : Any], size: CGSize, completion: @escaping (_ result: UIImage?) -> Void) {
        if !ShouldUseGoogleAPI {
            completion(.none)
            return
        }
        guard let id = (place["photos"] as? [[String : Any]])?.first?["photo_reference"] as? String else {
            completion(.none)
            return
        }
        let params: Parameters = [
            "maxheight" : Int(clamp(size.height, min: kMinSize, max: kMaxSize)),
            "maxwidth" : Int(clamp(size.width, min: kMinSize, max: kMaxSize)),
            "photoreference" : id,
            "key" : GoogleApiKey
        ]
        download(url: "\(kBaseUrl)\(kPlaceUrl)\(kPhotoUrl)", parameters: params, completion: completion)
    }
    
    func getTravelTime(from fromLoc: CLLocation, to toLoc: CLLocation, completion: @escaping ([(mode: TravelMode, duration: TimeInterval)]) -> Void) {
        if !ShouldUseGoogleAPI {
            completion([])
            return
        }
        let url = "\(kBaseUrl)\(kTravelUrl)\(kDataTypeUrl)"
        let walkingParams: Parameters = [
            "destinations" : "\(toLoc.coordinate.latitude),\(toLoc.coordinate.longitude)",
            "mode" : TravelMode.walking.rawValue,
            "origins" : "\(fromLoc.coordinate.latitude),\(fromLoc.coordinate.longitude)",
            "key" : GoogleApiKey
        ]
        let bicyclingParams: Parameters = [
            "destinations" : "\(toLoc.coordinate.latitude),\(toLoc.coordinate.longitude)",
            "mode" : TravelMode.bicycling.rawValue,
            "origins" : "\(fromLoc.coordinate.latitude),\(fromLoc.coordinate.longitude)",
            "key" : GoogleApiKey
        ]
        let drivingParams: Parameters = [
            "destinations" : "\(toLoc.coordinate.latitude),\(toLoc.coordinate.longitude)",
            "mode" : TravelMode.driving.rawValue,
            "origins" : "\(fromLoc.coordinate.latitude),\(fromLoc.coordinate.longitude)",
            "key" : GoogleApiKey
        ]
        let transitParams: Parameters = [
            "destinations" : "\(toLoc.coordinate.latitude),\(toLoc.coordinate.longitude)",
            "mode" : TravelMode.transit.rawValue,
            "origins" : "\(fromLoc.coordinate.latitude),\(fromLoc.coordinate.longitude)",
            "key" : GoogleApiKey
        ]
        dispatch_to_background {
            let semaphore = DispatchSemaphore(value: 0)
            var results = [(mode: TravelMode, duration: TimeInterval)]()
            self.request(url: url, parameters: walkingParams) { (response) in
                if let duration = (((response?["rows"] as? [[String : Any]])?.first?["elements"] as? [[String : Any]])?.first?["duration"] as? [String : Any])?["value"] as? Int {
                    results.append((.walking, TimeInterval(duration)))
                }
                semaphore.signal()
            }
            self.request(url: url, parameters: bicyclingParams) { (response) in
                if let duration = (((response?["rows"] as? [[String : Any]])?.first?["elements"] as? [[String : Any]])?.first?["duration"] as? [String : Any])?["value"] as? Int {
                    results.append((.bicycling, TimeInterval(duration)))
                }
                semaphore.signal()
            }
            self.request(url: url, parameters: drivingParams) { (response) in
                if let duration = (((response?["rows"] as? [[String : Any]])?.first?["elements"] as? [[String : Any]])?.first?["duration"] as? [String : Any])?["value"] as? Int {
                    results.append((.driving, TimeInterval(duration)))
                }
                semaphore.signal()
            }
            self.request(url: url, parameters: transitParams) { (response) in
                if let duration = (((response?["rows"] as? [[String : Any]])?.first?["elements"] as? [[String : Any]])?.first?["duration"] as? [String : Any])?["value"] as? Int {
                    results.append((.transit, TimeInterval(duration)))
                }
                semaphore.signal()
            }
            semaphore.wait()
            semaphore.wait()
            semaphore.wait()
            semaphore.wait()
            dispatch_to_main {
                completion(results)
            }
        }
    }
    
    func openMapsApplication(fromLocation fromLoc: CLLocation, toLocation toLoc: CLLocation, mode: TravelMode) {
        let urlString: String
        let saddr = "saddr=\(fromLoc.coordinate.latitude),\(fromLoc.coordinate.longitude)"
        let daddr = "daddr=\(toLoc.coordinate.latitude),\(toLoc.coordinate.longitude)"
        
        if let url = URL(string: kGoogleMapsBaseUrl), UIApplication.shared.canOpenURL(url) {
            let mode = "directionsmode=\(mode.rawValue)"
            let zoom = "zoom=\(kDefaultMapZoomLevel)"
            urlString = "\(kGoogleMapsBaseUrl)?\(saddr)&\(daddr)&\(mode)&\(zoom)"
        } else {
            Log.warning("User does not have Google Maps installed. Attempting to open Apple Maps.")
            let mode = "dirflg=\((mode == .driving ? "d" : mode == .transit ? "r" : "w"))"
            urlString = "\(kAppleMapsBaseUrl)?\(daddr)&\(mode)"
        }
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    func searchLocation(name: String, location: CLLocation, radius: Int, completion: @escaping (_ result: [String : Any]?) -> Void) {
        if !ShouldUseGoogleAPI {
            completion(.none)
            return
        }
        guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.none)
            return
        }
        let params: Parameters = [
            "location" : "\(location.coordinate.latitude),\(location.coordinate.longitude)",
            "radius" : radius,
            "type" : "restaurant",
            "name" : encodedName,
            "key" : GoogleApiKey
        ]
        request(url: "\(kBaseUrl)\(kPlaceUrl)\(kSearchUrl)\(kDataTypeUrl)", parameters: params) { (response) in
            guard let locations = response?["results"] as? [[String : Any]] else {
                completion(.none)
                return
            }
            for location in locations {
                if let resultName = location["name"] as? String, resultName.lowercased().contains(name.lowercased()) || name.lowercased().contains(resultName.lowercased()) {
                    completion(location)
                }
            }
            completion(.none)
        }
    }
    
    private func download(url: URLConvertible, parameters: Parameters, completion: @escaping (_ result: UIImage?) -> Void) {
        Alamofire.request(url, parameters: parameters).responseData { (response) in
            if let status = response.response?.statusCode, status != self.kSuccessStatusCode {
                Log.error("Error with status code: \(status)")
                completion(.none)
            }
            guard let result = response.result.value else {
                completion(.none)
                return
            }
            completion(UIImage(data: result))
        }
    }
    
    private func request(url: URLConvertible, parameters: Parameters, completion: @escaping (_ result: [String : Any]?) -> Void) {
        Alamofire.request(url, parameters: parameters).responseJSON { (response) in
            if let status = response.response?.statusCode, status != self.kSuccessStatusCode {
                Log.error("Error with status code: \(status)")
                completion(.none)
            }
            guard let result = response.result.value as? [String : Any] else {
                completion(.none)
                return
            }
            completion(result)
        }
    }
    
}
