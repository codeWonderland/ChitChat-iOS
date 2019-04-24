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
        sendMessage(message: "hello world")
    }
    
    func getMessages() {
        netRequest(path: "", method: .get, message: nil) { response in
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
    
    func sendMessage(message: String) {
        let escapedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        netRequest(path: "", method: .post, message: escapedMessage) { response in
            if let json = response.result.value as? [String: Any],
                let resp = json["code"] as? Int {
                if resp == 1 {
                    self.getMessages()
                }
            }
        }
    }
    
    func netRequest(path: String,
                    method: HTTPMethod,
                    message: String?,
                    cb: @escaping (DataResponse<Any>) -> Void) {
        var url = "https://www.stepoutnyc.com/chitchat\(path)?key=c9be0e9b-6265-41c6-9090-fd83f6e4537e&client=shawn.fortin@mymail.champlain.edu"
        
        if message != nil {
            url = "\(url)&message=\(message!)"
        }
        
        Alamofire.request(
            url,
            method: method
        ).responseJSON(completionHandler: cb)
    }

}

