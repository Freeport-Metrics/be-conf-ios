//
//  TableViewCell.swift
//  BeAtConf
//
//  Created by Jan Terlecki on 3/14/16.
//  Copyright © 2016 Jan Terlecki. All rights reserved.
//

import Foundation
import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet var RoomLabel: [UILabel]!
    @IBOutlet weak var titleLabel: UILabel!
   
    @IBOutlet weak var RoomList: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    
}