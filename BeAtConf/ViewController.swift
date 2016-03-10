//
//  ViewController.swift
//  BeAtConf
//
//  Created by Jan Terlecki on 3/10/16.
//  Copyright © 2016 Jan Terlecki. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var roomList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Throw loading screen
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        
        //Checks if userName exists, if not sends to ProvideName screen
        handleUserName()
        
        let serverController = ServerController()
        let jsonDeserializer = JsonDeserializer()
        
        //getJsons
        let roomJson = serverController.getRoomJson()
        let serverJson = serverController.getConfigJson()
        
        //Get the serverConfig object
        let serverConfig = jsonDeserializer.deserializeConfig()
        
        //get roomList object
        let roomList = jsonDeserializer.deserializeResponse()
        
        
        
        

    }
    
    
    @IBAction func resetName(sender: AnyObject) {
        goToNameView()
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

    }

}

