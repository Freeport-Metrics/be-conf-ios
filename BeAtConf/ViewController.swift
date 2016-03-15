//
//  ViewController.swift
//  BeAtConf
//
//  Created by Jan Terlecki on 3/10/16.
//  Copyright © 2016 Jan Terlecki. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var roomList: UITableView!
    @IBOutlet weak var testLabel: UILabel!

    

    var socket = SocketIOClient(socketURL: NSURL(string: "http://beatconf-freeportmetrics.rhcloud.com")!, options: [
        "reconnects": true,
        "log":false
        ])
    
    var config:JSON = [:]
    var rooms:JSON = [:]
    var userNameId: String = ""
    var roomConfigArray: [String] = []
    var isConfigSet: Bool = false
    let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Throw loading screen
            handleUserName()
        configSocket()
        //let uuid  = NSUUID.init(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
        
        //let region = CLBeaconRegion.init(proximityUUID: uuid!, identifier: "Beacon")

        roomList.registerNib(UINib.init(nibName: "MyTableViewCell", bundle: nil),
            forCellReuseIdentifier: "LabelCell")
        
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways){
        locationManager.requestAlwaysAuthorization()
        }
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {

    }
    

    
    @IBAction func resetName(sender: AnyObject) {
        goToNameView()
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion){
        handleBeacons(beacons)
    }
    
    func handleBeacons(beacons: [CLBeacon]){
        for beacon in beacons {
            let beaconId = "" + beacon.major.stringValue + "_" + beacon.minor.stringValue

            
            for room in config {
                if (room.1["b_id"].stringValue == beaconId){
                    let radius = room.1["room_radius"].int
                    if (beacon.major == 45287){
                        print("beacon 45287")
                        print(beacon.accuracy)
                    }
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
            //print("room config contains " + beaconId)
        }else{
            roomConfigArray.append(beaconId)
                    //print("entering room" + beaconId + " with range")
                    //print(beacon.accuracy)
            enterRoom(beaconId)
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
        }
    }
    
    func enterRoom(beaconId: String){
        socket.emit("enterRoom", "{\"user_id\":\"" + self.userNameId + "\",\"room_id\":\"" + beaconId + "\"}")
    }
    
    func leaveRoom(beaconId: String){
        socket.emit("leaveRoom", "{\"user_id\":\"" + self.userNameId + "\",\"room_id\":\"" + beaconId + "\"}")
    }
    
    func goToNameView(){
        let storyboard = UIStoryboard(name: "ProvideNameScreen", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ProvideNameViewController") as UIViewController
        presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func handleUserName(){
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey("userName") == nil){
            goToNameView()
        }else{
            let userName = defaults.objectForKey("userName")
            testLabel.text = "Hello , \(userName!)"
        }
        self.userNameId = (defaults.objectForKey("userName") as? String)!

    }
    
    func configSocket(){
        self.socket.on("config"){data, ack in
            self.handleConfig(data)
        };
        
        self.socket.on("room_status"){data, ack in
            print("Room status received")
            self.handleRooms(data)
            
        };
        self.socket.on("connect"){data, ack in
            print("socket connected");
        }
        self.socket.connect()
        print("socket configured")

    }
    
    func deserializeConfig(data: AnyObject){
        let json = JSON(data)
        config = json[0]["config"]
    }
    
    /*func handleRooms(data: AnyObject){
        let json = JSON(data)
        rooms = json[0]["rooms"]
    }*/
    
    func handleRooms(data: AnyObject){
        if (isConfigSet == true){
            let json = JSON(data)
            rooms = json[0]["rooms"]
            roomList.reloadData()
            roomList.reloadInputViews()
        }else{
            print("config not yet set")
        }
    }
    
    
    func handleConfig(data: AnyObject){
        deserializeConfig(data)
        print("config is set")
        isConfigSet = true
        locationManager.startRangingBeaconsInRegion(region)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return rooms.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    //override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //return 5
    //}
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell") as! MyTableViewCell
        


        cell.titleLabel.text = rooms[indexPath.section]["label"].rawString()
        
        var users :String = ""
        for name in rooms[indexPath.section]["users"]{
            users = users + name.1["name"].rawString()!
        }
        cell.subtitleLabel.text = users
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}



