//
//  Utils.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-20.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import AVFoundation
import Foundation
import Photos
import MapKit

//# MARK: - Grand Central Dispatch

/**
 Enqueue a block for execution after a specified time in seconds.
 
 - Parameters:
 - seconds: Delay in seconds.
 - block: The block to submit.
 */
public func dispatch_later(_ seconds: Double, block: @escaping () -> Void) {
    let delay = DispatchTime.now() + .milliseconds(Int(seconds * 1000))
    DispatchQueue.main.asyncAfter(deadline: delay, execute: block)
}

/**
 Use background thread
 
 - Parameters:
 - block: The block to submit.
 */
public func dispatch_to_background(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .default).async(execute: block)
}

/**
 Use main thread
 
 - Parameters:
 - block: The block to submit.
 */
public func dispatch_to_main(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}


//# MARK: - Serializers

/**
 Convert Data to JSON dictionary
 
 - Parameters:
 - block: Data that should have JSON.
 
 - Returns: JSON dicitionary is parse is successful. Otherwise, it returns .none
 */
public func dictionary(withData data: Data) -> Any? {
    do {
        return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    } catch let error as NSError {
        Log.error(error.localizedDescription)
        return .none
    }
}


//# MARK: - User Defaults / Shared Preferences

/**
 Setter for a UserDefaults.
 
 - Parameters:
 - object: Object you would like to save.
 - key: The key for the object you would like to save.
 */
public func set_pref(object: Any, withKey key: String) {
    UserDefaults.standard.set(object, forKey: key)
}

/**
 Getter for a UserDefaults.
 
 - Parameters:
 - key: The key for the object you would like to save.
 
 - Returns: Object that you saved with the key.
 */
public func get_pref(forKey
    key: String) -> Any? {
    return UserDefaults.standard.object(forKey: key)
}


//# MARK: - Permissions

/**
 Provides boolean value of whether camera access is allowed.
 
 - Returns: Bool
 */
public var cameraAccessAvailable = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized

/**
 Provides boolean value of whether photo library access is allowed.
 
 - Returns: Bool
 */
public var photoLibraryAccessAvailable = PHPhotoLibrary.authorizationStatus() == .authorized

/**
 Requests for camera access.
 
 - Parameters:
 - success: The block giving a boolean value of whether access is granted.
 */
public func requestForCameraAccess(_ success: @escaping (Bool) -> Void) {
    switch (AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)) {
    case .authorized:
        success(true)
    case .notDetermined:
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (status) in
            success(status)
        })
    default:
        success(false)
    }
}

/**
 Requests for photo library access.
 
 - Parameters:
 - success: The block giving a boolean value of whether access is granted.
 */
public func requestForPhotoLibraryAccess(_ success: @escaping (Bool) -> Void) {
    switch (PHPhotoLibrary.authorizationStatus()) {
    case .authorized:
        success(true)
    case .notDetermined:
        PHPhotoLibrary.requestAuthorization({ (status) in
            success(status == .authorized)
        })
    default:
        success(false)
    }
}


//# MARK: - Regex Handlers

/**
 Extracts string with given regex string.
 
 - Parameters:
 - string: String to extract.
 - regex: String that is used to create a regex to extract string.
 
 - Returns:
 - Extracted string.
 */
public func extractString(string: String, regex: String) -> String? {
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        guard let result = regex.matches(in: string, options: [], range: NSMakeRange(0, string.characters.count)).first else {
            return .none
        }
        
        return (string as NSString).substring(with: result.range) as String
    } catch let error as NSError {
        Log.error(error.localizedDescription)
        return .none
    }
}


//# MARK: - Misc

/**
 Convert TimeInterval into a human readable format
 
 - Parameters:
 - timeInterval: The time interval that needs to be converted
 
 - Returns:
 - String in the format of 'xx'h'xx'm
 */
public func interval_to_string(_ timeInterval: TimeInterval) -> String {
    let second: Double = 1
    let minute: Double = second * 60
    let hour: Double = minute * 60
    let day: Double = hour * 24
    let week: Double = day * 7
    
    var timeInterval = Double(timeInterval)
    var timeString = [String]()
    
    if timeInterval >= week {
        let amount = floor(timeInterval / week)
        timeInterval -= amount * week
        timeString.append("\(Int(amount))w")
    }
    
    if timeInterval >= day {
        let amount = floor(timeInterval / day)
        timeInterval -= amount * day
        timeString.append("\(Int(amount))d")
    }
    
    if timeInterval >= hour {
        let amount = floor(timeInterval / hour)
        timeInterval -= amount * hour
        timeString.append("\(Int(amount))h")
    }
    
    if timeInterval >= minute {
        let amount = floor(timeInterval / minute)
        timeInterval -= amount * minute
        timeString.append("\(Int(amount))m")
    }
    
    if timeString.isEmpty && timeInterval >= second {
        timeString.append("\(Int(timeInterval))s")
    }
    
    return timeString.joined(separator: " ")
}
