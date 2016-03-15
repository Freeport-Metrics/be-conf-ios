//
//  TableViewController.swift
//  BeAtConf
//
//  Created by Jan Terlecki on 3/14/16.
//  Copyright © 2016 Jan Terlecki. All rights reserved.
//

import Foundation

import UIKit

class TableViewController: UITableViewController {
    
    
    @IBOutlet var roomList: UITableView!
    @IBOutlet weak var userName: UITextField!
    
    
    //@IBOutlet weak var RoomList: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    //override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 5
    //}
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath)
        
        // Configure the cell...'
        
        cell.textLabel?.text = "random"
        
        
        var label = UILabel(frame: CGRectMake(32.0, 43.0, 238.0, 115.0))
        label.text = "test"
        label.tag = indexPath.row
        cell.contentView.addSubview(label)
        
        return cell
    }
    
}
