//
//  ViewController.swift
//  ChitChat
//
//  Created by Easter, Alice on 4/16/19.
//  Copyright © 2019 Easter, Alice. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDelegate {
    
    var mMessages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        getMessages()
    }
    
    func getMessages() {
        Alamofire.request("https://www.stepoutnyc.com/chitchat?key=c9be0e9b-6265-41c6-9090-fd83f6e4537e&client=shawn.fortin@mymail.champlain.edu").responseJSON { response in
            if let json = response.result.value as? [String: Any],
                let messages = json["messages"] as? [[String: Any]] {
                for entry in messages {
                    if let message = Message(json: entry) {
                        self.mMessages.append(message)
                    }
                }
            }
        }
    }

}

