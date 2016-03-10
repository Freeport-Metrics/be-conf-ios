//
//  ProvideNameViewController.swift
//  BeAtConf
//
//  Created by Jan Terlecki on 3/10/16.
//  Copyright © 2016 Jan Terlecki. All rights reserved.
//

import Foundation

import UIKit

class ProvideNameViewController: UIViewController {
    
    
    @IBOutlet weak var userName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(userName.text ?? "", forKey: "userName")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewControllerWithIdentifier("ViewController") as UIViewController
        
        presentViewController(vc, animated: true, completion: nil)
    }
    
}

