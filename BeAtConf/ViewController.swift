//
//  ViewController.swift
//  BeAtConf
//
//  Created by Jan Terlecki on 3/10/16.
//  Copyright © 2016 Jan Terlecki. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIApplicationDelegate
{
    
    
        @IBOutlet weak var roomList: UITableView!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var testLabel: UILabel!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var userNameId: String = ""
            
    override func viewDidLoad() {
        super.viewDidLoad()


        debugLabel.text = ""
        self.view.backgroundColor = UIColor.lightGrayColor()
        let nc = NSNotificationCenter.defaultCenter()
        
        roomList.backgroundColor = UIColor.clearColor()
        
        nc.addObserver(self, selector: "handleDidEnterBackgroundNotification:",name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        nc.addObserver(self, selector: "reloadData:", name: "ReloadData", object:nil)
        
        nc.addObserver(self, selector: "setiDebugLabel:", name: "setDebugLabel", object:nil)

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [UIColor.lightGrayColor().CGColor, UIColor.whiteColor().CGColor]

        self.view.backgroundColor = view.backgroundColor
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        

        roomList.registerNib(UINib.init(nibName: "MyTableViewCell", bundle: nil),
            forCellReuseIdentifier: "LabelCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        handleUserName()
    }
    

    @objc func handleDidEnterBackgroundNotification(notification: NSNotification){
        print("rotr")
        
    }
    
    @IBAction func resetName(sender: AnyObject) {
        SocketLogic.socket.disconnect()
        goToNameView()
        SocketLogic.socket.connect()
    }
    
    @objc func reloadData(notification: NSNotification){
        print("reloading")
        roomList.reloadData()
        roomList.reloadInputViews()
    }
    
    
    @objc func setiDebugLabel(notification: NSNotification){
        debugLabel.text = appDelegate.setDebugLabelText()
    }
        
    func goToNameView(){
        let storyboard = UIStoryboard(name: "ProvideNameScreen", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ProvideNameViewController") as UIViewController
        presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func handleUserName(){
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey("userName") == nil || defaults.objectForKey("userName") as? String == ""){
            goToNameView()
            let id: String = NSUUID().UUIDString
            defaults.setObject(id, forKey: "id")
        }else{
            let userName = defaults.objectForKey("userName")
            testLabel.text = "Hello , \(userName!)"
            appDelegate.startAppLogic()
        }

        //self.userNameId = (defaults.objectForKey("userName") as? String)!

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return appDelegate.getRoomCount()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell") as! MyTableViewCell
        
        let rooms = appDelegate.getRooms()

        cell.titleLabel.text = rooms[indexPath.section]["label"].rawString()
        cell.titleLabel.alpha = 1
        var users :String = ""
        for name in rooms[indexPath.section]["users"]{
            users = users + name.1["name"].rawString()! + ", "
        }
        if (users != ""){
            users.removeAtIndex(users.endIndex.predecessor())
            users.removeAtIndex(users.endIndex.predecessor())
        }
        cell.subtitleLabel.text = users
        //cell.backgroundColor = UIColor.clearColor()
        //cell.backgroundView?.backgroundColor = UIColor.clearColor()
        //cell.contentView.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}



