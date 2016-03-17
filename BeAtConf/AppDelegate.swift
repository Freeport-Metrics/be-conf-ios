//
//  AppDelegate.swift
//  BeAtConf
//
//  Created by Jan Terlecki on 3/10/16.
//  Copyright © 2016 Jan Terlecki. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
    let locationManager = CLLocationManager()
    let locationManager2 = CLLocationManager()
    
    var config:JSON = [:]
    var rooms:JSON = [:]
    var timer: dispatch_source_t!
    var counter = 0
    var roomConfigArray: [String] = []
    var isConfigSet: Bool = false
    var userNameId: String = ""
    var latestPrint: String = ""
    let nc = NSNotificationCenter.defaultCenter()

    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion){
        handleBeacons(beacons)
    }
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        NSLog("error while ranging beacons (ranging beacons did fail for region)")
        latestPrint = "Started Beacon Ranging"
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion){
        print("Entered a region")
        latestPrint = "Entered a region"
        nc.postNotificationName("setDebugLabel", object: nil)
        SocketLogic.socket.connect()
        enterRoom("5919_60231")
        NSLog("Entered room 5919_60231")
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Left a region")
        latestPrint = "Left a region"
        nc.postNotificationName("setDebugLabel", object: nil)
        leaveRoom("5919_60231")
    }
    
    func setDebugLabelText() -> String{
        return latestPrint
    }
    
    func setCounterLabelText() -> String{
        return String(self.counter)
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        setName()
        configSocket()
        registerBeacon()
        //locationManager2.delegate = self
        //locationManager2.desiredAccuracy = kCLLocationAccuracyKilometer
        //locationManager2.startUpdatingLocation()
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        locationManager.startRangingBeaconsInRegion(region)
        region.notifyEntryStateOnDisplay = true;
        locationManager.startMonitoringForRegion(region)
        return true
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        NSLog("Performing Fetch")
        self.counter = self.counter + 1
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //nothing
    }
    
    func setName(){
        let defaults = NSUserDefaults.standardUserDefaults()
        userNameId = (defaults.objectForKey("userName") as? String)!
    }
    
    func registerBeacon(){
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways){
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func configSocket(){
        SocketLogic.socket.on("config"){data, ack in
            self.handleConfig(data)
        };
        
        SocketLogic.socket.on("room_status"){data, ack in
            print("Room status received")
            self.handleRooms(data)
            
        };
        SocketLogic.socket.on("connect"){data, ack in
            print("socket connected");
        }
        SocketLogic.socket.connect()
        print("socket configured")
        
    }
    
    func handleRooms(data: AnyObject){
        if (isConfigSet == true){
            let json = JSON(data)
            rooms = json[0]["rooms"]
            nc.postNotificationName("ReloadData", object: nil)
        }else{
            print("config not yet set")
        }
    }
    
    func handleConfig(data: AnyObject){
        deserializeConfig(data)
        print("config is set")
        isConfigSet = true
    }
    
    func deserializeConfig(data: AnyObject){
        let json = JSON(data)
        config = json[0]["config"]
    }
    
    func getRoomCount() -> Int{
        return rooms.count
    }
    
    func getRooms() -> JSON{
        return rooms
    }

    func handleBeacons(beacons: [CLBeacon]){
        for beacon in beacons {
            let beaconId = "" + beacon.major.stringValue + "_" + beacon.minor.stringValue
            
            for room in config {
                if (room.1["b_id"].stringValue == beaconId){
                    let radius = room.1["room_radius"].int
                    let doubleRadius = Double(radius!)
                    if (beacon.accuracy < doubleRadius && beacon.accuracy > 0){
                        insideRoom(beacon, room: room.1, beaconId: beaconId)
                    }
                    if (beacon.accuracy > doubleRadius && beacon.accuracy > 0)
                    {
                        outsideRoom(beacon, room: room.1, beaconId: beaconId)
                    }
                }
            }
            
        }
    }
    
    func insideRoom(beacon: CLBeacon, room: JSON, beaconId: String){
        //if room exists in room array, do nothing...?
        if (roomConfigArray.contains(beaconId)){
        }else{
            roomConfigArray.append(beaconId)
            enterRoom(beaconId)
            NSLog("Entering Room")
            latestPrint = "Inside a room"
            nc.postNotificationName("setDebugLabel", object: nil)
        }
        //else enter the room
    }
    
    func outsideRoom(beacon: CLBeacon, room: JSON, beaconId: String){
        //if room non existant in room array, do nothing...
        //else leave the room
        if (roomConfigArray.contains(beaconId)){
            let index = roomConfigArray.indexOf(beaconId)
            roomConfigArray.removeAtIndex(index!)
            //print("leaving room" + beaconId + " with range")
            //print(beacon.accuracy)
            leaveRoom(beaconId)
            NSLog("Leaving Room")
            latestPrint = "outside a room"
            nc.postNotificationName("setDebugLabel", object: nil)
        }
    }
    
    func enterRoom(beaconId: String){
        //send HTTP request to enter room?
        SocketLogic.socket.emit("enterRoom", "{\"user_id\":\"" + self.userNameId + "\",\"room_id\":\"" + beaconId + "\"}")
    }
    
    func leaveRoom(beaconId: String){
        SocketLogic.socket.emit("leaveRoom", "{\"user_id\":\"" + self.userNameId + "\",\"room_id\":\"" + beaconId + "\"}")
    }


    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    

}

