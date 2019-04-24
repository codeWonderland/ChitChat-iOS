//
//  ViewController.swift
//  ChitChat
//
//  Created by Easter, Alice on 4/16/19.
//  Copyright © 2019 Easter, Alice. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    var mMessages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.table.delegate = self
        self.table.dataSource = self
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
                        self.table.reloadData()
                    }
                }
            }
        }
    }
    
    func sendMessage(message: String) {
        netRequest(path: "", method: .post, message: message) { response in
            if let json = response.result.value as? [String: Any] {
                print(json)
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

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        let message = mMessages[indexPath.row]
        print(message.message)
        (cell.contentView.viewWithTag(1) as! UILabel).text = message.message
        return cell
    }

}

