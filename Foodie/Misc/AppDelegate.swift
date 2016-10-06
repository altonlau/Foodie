//
//  AppDelegate.swift
//  Foodie
//
//  Created by Alton Lau on 2016-09-29.
//  Copyright © 2016 Alton. All rights reserved.
//

import GoogleMaps
import RealmSwift
import SVProgressHUD
import SwiftyBeaver
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(GoogleApiKey)
        performRealmMigration()
        setupSVProgressHUD()
        setupSwiftyBeaver()
        return true
    }
    
    
    //# MARK: - Private Methods
    
    private func performRealmMigration() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        do {
            let _ = try Realm()
        } catch let error as NSError {
            Log.error(error.localizedDescription)
        }
    }
    
    private func setupSVProgressHUD() {
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor.foodieGray)
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
    }
    
    private func setupSwiftyBeaver() {
        Log.addDestination(ConsoleDestination())
    }

}

