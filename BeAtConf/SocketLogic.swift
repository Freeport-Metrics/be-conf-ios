//
//  SocketLogic.swift
//  BeAtConf
//
//  Created by Jan Terlecki on 3/16/16.
//  Copyright © 2016 Jan Terlecki. All rights reserved.
//

import Foundation

class SocketLogic{
    
    static var socket = SocketIOClient(socketURL: NSURL(string: "http://beatconf-freeportmetrics.rhcloud.com")!, options: [
        "reconnects": true,
        "log":false,
        "voipEnabled": true
        ])
    
    
}