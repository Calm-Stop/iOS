//
//  AppDelegate.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 3/20/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import CoreLocation

var beaconIDString = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?

    var locationManager: CLLocationManager?
    var lastProximity: CLProximity?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Use Firebase library to configure APIs
        FIRApp.configure()
        
        // Start ---------- iBeacon ----------
        let uuidString = "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"
        let beaconRegionIdentifier = "CalmStop"
        let beaconUUID: NSUUID = NSUUID(uuidString: uuidString)!
        
        let beaconRegion: CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID as UUID, identifier: beaconRegionIdentifier)
        
        locationManager = CLLocationManager()
        
        if(locationManager!.responds(to: "requestAlwaysAuthorization")){
            locationManager!.requestAlwaysAuthorization()
        }
        
        
        locationManager!.delegate = self
        locationManager!.pausesLocationUpdatesAutomatically = false
        
        locationManager!.startMonitoring(for: beaconRegion)
        
        // Start monitoring in case we have a beacon in our region
        locationManager!.startRangingBeacons(in: beaconRegion)
        locationManager!.startUpdatingLocation()
        
        UIApplication.shared.registerUserNotificationSettings(
            UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil))
        
        
        // End ---------- iBeacon ----------
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
         self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CalmStopCitizen")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    // iBEACON
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
        manager.startUpdatingLocation()
        
        print("You entered the region")
        
        let notification = UILocalNotification()
        notification.alertBody = "An Officer is pulling you over, please open CalmStop to reply!"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.presentLocalNotificationNow(notification)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
        manager.stopUpdatingLocation()
        
        print("You exited the region")
        beaconIDString = "No Beacons"
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("DidRangeBeacon: ", beacons.count)
        
        if beacons.count > 0 {
            beaconIDString = beacons[0].major.stringValue
            print(beaconIDString)
        }
    }

}

