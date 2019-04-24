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
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 200
        getMessages()
        //sendMessage(message: "hello world")
    }
    
    func getMessages() {
        netRequest(
            path: "",
            method: .get,
            message: nil
        ) { response in
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
        let escapedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        netRequest(
            path: "",
            method: .post,
            message: escapedMessage
        ) { response in
            if let json = response.result.value as? [String: Any],
                let resp = json["code"] as? Int {
                if resp == 1 {
                    self.getMessages()
                }
            }
        }
    }
    
    func likeMessage(message: Message, good: Bool) {
        if message.like(good: good) {
            netRequest(path: "/\(good ? "like" : "dislike")/\(message._id)", method: .get, message: nil) { response in
                if let json = response.result.value as? [String: Any],
                    let resp = json["code"] as? Int {
                    if resp == 1 {
                        self.getMessages()
                    }
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
        (cell.contentView.viewWithTag(4) as! UILabel).text = "\(message.likes)"
        (cell.contentView.viewWithTag(5) as! UILabel).text = "\(message.dislikes)"
        (cell.contentView.viewWithTag(3) as! UILabel).text = "\(message.loc[0]), \(message.loc[1])"
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            print("show map")
            let next = segue.destination as! MapDetailViewController
            let message = mMessages[(table.indexPathForSelectedRow?.row)!]
            next.latitude = Double (message.loc[0])
            next.longitude = Double (message.loc[1])
        }
    }
    
    @IBAction func like(_ sender: Any) {
        if let cell = (sender as! UIButton).superview?.superview as? UITableViewCell {
            mMessages[(table.indexPath(for: cell)?.row)!].like(good: true)
            table.reloadData()
        }
    }
    
    @IBAction func dislike(_ sender: Any) {
        if let cell = (sender as! UIButton).superview?.superview as? UITableViewCell {
            mMessages[(table.indexPath(for: cell)?.row)!].like(good: false)
            table.reloadData()
        }
    }
}

