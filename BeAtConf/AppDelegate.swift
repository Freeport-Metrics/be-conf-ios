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
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate {

    var window: UIWindow?
    let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
    let locationManager = CLLocationManager()
    
    let enterUrl: String = "http://beatconf-freeportmetrics.rhcloud.com/enter_room"
    let leaveUrl: String = "http://beatconf-freeportmetrics.rhcloud.com/leave_room"
    
    var config:JSON = [:]
    var rooms:JSON = [:]
    var timer: dispatch_source_t!
    var counter = 0
    var roomConfigArray: [String] = []
    var isConfigSet: Bool = false
    var userNameId: String = ""
    var latestPrint: String = ""
    let nc = NSNotificationCenter.defaultCenter()
    var id: String = ""
    

    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion){
        handleBeacons(beacons)
        NSLog("ranged beacons")
    }
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        NSLog("error while ranging beacons (ranging beacons did fail for region)")
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion){
        NSLog("Entering Region, starting monitoring region")
        locationManager.startRangingBeaconsInRegion(self.region)
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        outsideRoom()
        NSLog("Exiting Region, stopping ranging for region")
        locationManager.stopRangingBeaconsInRegion(self.region)
    }
    
    func setDebugLabelText() -> String{
        return latestPrint
    }
    
    func setCounterLabelText() -> String{
        return String(self.counter)
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        print("id: " + self.id)
        return true
    }
    
    func startAppLogic(){
        NSLog("Starting app logic")
        setName()
        configSocket()
        registerBeacon()
        self.region.notifyEntryStateOnDisplay = true;
        locationManager.startMonitoringForRegion(region)
        NSLog("Starting Region Monitoring")

    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        NSLog("Performing Fetch")
        locationManager.startRangingBeaconsInRegion(self.region)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //nothing
    }
    
    func setName(){
        let defaults = NSUserDefaults.standardUserDefaults()
        self.userNameId = (defaults.objectForKey("userName") as? String)!
        self.id = (defaults.objectForKey("id") as? String)!
    }
    
    func registerBeacon(){
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways){
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.allowsBackgroundLocationUpdates = true
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
       // if (isConfigSet == true){
            let json = JSON(data)
            rooms = json[0]["rooms"]
            nc.postNotificationName("ReloadData", object: nil)
        //}else{
        //    print("config not yet set")
       // }
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
            
            for room in rooms {
                if (room.1["room_id"].stringValue == beaconId){
                    insideRoom(beacon, room: room.1, beaconId: beaconId)
                }
            }
            
        }
    }
    
    func insideRoom(beacon: CLBeacon, room: JSON, beaconId: String){
        //if room exists in room array, do nothing...?
        if(roomConfigArray.contains(beaconId)){
        
        }else{
        roomConfigArray.append(beaconId)
        enterRoom(beaconId)
        updateLabel("You are inside " + room["label"].string!)
            print(beacon.accuracy)
        }
        
        //else enter the room
    }
    
    func updateLabel(text: String){
        latestPrint = text
        nc.postNotificationName("setDebugLabel", object: nil)
    }
    
    func outsideRoom(){
        for beaconId in roomConfigArray{
            leaveRoom(beaconId)
            updateLabel("Leaving room " + beaconId)
            let index = roomConfigArray.indexOf(beaconId)
            roomConfigArray.removeAtIndex(index!)
        }
        for room in rooms{
            leaveRoom(room.1["room_id"].stringValue)
        }
        

    }
    
    func leaveEveryOtherRoom(beaconIdToLeave: String){
        for beaconId in roomConfigArray{
            if (beaconIdToLeave == beaconId){}else{
            leaveRoom(beaconId)
            updateLabel("Leaving room " + beaconId)
            let index = roomConfigArray.indexOf(beaconId)
            roomConfigArray.removeAtIndex(index!)
            }
        }
    }
    
    
    func enterRoom(beaconId: String){
        //send HTTP request to enter room?
        NSLog("Entering room " + beaconId)
        leaveEveryOtherRoom(beaconId)
        sendHttpRequest(beaconId, requestUrl: self.enterUrl)
    }
    
    func leaveRoom(beaconId: String){
        sendHttpRequest(beaconId, requestUrl: self.leaveUrl)
        NSLog("Leaving room " + beaconId)
    }

    func sendHttpRequest(beaconId: String, requestUrl: String){
        let postBody: NSString = "{\"room_id\"" + ":" + "\"" + beaconId + "\"" + "," + "\"id\"" + ":" + "\"" + self.id + "\"" + "," + "\"user_id\"" + ":" + "\"" + self.userNameId + "\"}"
        print(postBody)
        let url:NSURL = NSURL(string: requestUrl)!
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("3211")
        let session = NSURLSession.init(configuration: config, delegate:self, delegateQueue:nil)

        
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        request.HTTPBody = postBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task: NSURLSessionTask = session.uploadTaskWithStreamedRequest(request)
        
        task.resume()

    }
    

    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        locationManager.startRangingBeaconsInRegion(self.region)
        
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
        locationManager.startRangingBeaconsInRegion(self.region)
        NSLog("Started beacon ranging")

    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        outsideRoom()
        NSLog("Terminating app")
    }
    
    

}

