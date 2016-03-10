//
//  ServerController.swift
//  BeAtConf
//
//  Created by Jan Terlecki on 3/10/16.
//  Copyright © 2016 Jan Terlecki. All rights reserved.
//

import Foundation


class ServerController{
    
    func getRoomJson() -> String{
        return "rooms: [ { room_id: '5919_60231', label: 'Flight Control Room', users: [ 'Marcin', 'Jan', 'Tomasz' ]}, { room_id: '45287_53858', label: 'Sala Konferencyjna', users: []}, {room_id: '10344_31183', label: 'Carnegie Hall', users: []}]"
    }
    
    func getConfigJson(){
        
    }
    
}