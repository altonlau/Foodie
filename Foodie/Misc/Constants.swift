//
//  Constants.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-16.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import Foundation
import SwiftyBeaver
import UIKit

//# MARK: - SwiftyBeaver Constants

public let Log = SwiftyBeaver.self


//# MARK: - Info.plist Properties

public let ShouldUseGoogleAPI = {
   return Bundle.main.object(forInfoDictionaryKey: "Use Google API") as? Bool ?? false
}()


//# MARK: - Google API

public let GoogleApiKey = "AIzaSyCjJ736_suNU6Dfcjqt-2zs9Zexqv394jI"


//# MARK: - UIImageView Animation Constants

public let DefaultAnimationDelay: Double = 0.0375


//# MARK: - CALayer Animation Key Paths

public let CAShadowOpacityKey = "shadowOpacity"


//# MARK: - Segue Identifiers

public let AllFoodiesSegueIdentifier = "allFoodiesSegueIdentifier"
public let FoodieSegueIdentifier = "foodieSegueIdentifier"
public let FoodieUnwindSegueIdentifier = "foodieUnwindSegueIdentifier"
public let InsertCuisineSegueIdentifier = "insertCuisineSegueIdentifier"
public let InsertFoodieSegueIdentifier = "insertFoodieSegueIdentifier"
public let InsertLocationSegueIdentifier = "insertLocationSegueIdentifier"
public let SettingsSegueIdentifier = "settingsSegueIdentifier"


//# MARK: - View Controller Identifiers

public let SettingsControllerIdentifier = "settingsControllerIdentifier"


//# MARK: - ModalCardSegue Constants

public let ModalCardSegueAnimationDuration: TimeInterval = 0.5
public let ModalCardSegueTintViewTag = 1
