//
//  Message.swift
//  ChitChat
//
//  Created by Easter, Alice on 4/18/19.
//  Copyright © 2019 Easter, Alice. All rights reserved.
//

import Foundation

class Message {
    var _id: String
    var client: String
    var date: String
    var dislikes: Int
    var likes: Int
    var loc: [String]
    var message: String
    
    init?(json: [String: Any]) {
        guard let _id = json["_id"] as? String,
        let client = json["client"] as? String,
        let date = json["date"] as? String,
        let dislikes = json["dislikes"] as? Int,
        let likes = json["liks"] as? Int,
        let loc = json["loc"] as? [String],
        let message = json["message"] as? String
            else {
                return nil
        }
        
        self._id = _id
        self.client = client
        self.date = date
        self.dislikes = dislikes
        self.likes = likes
        self.loc = loc
        self.message = message
    }
}
