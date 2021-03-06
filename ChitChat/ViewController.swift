//
//  ViewController.swift
//  ChitChat
//
//  Created by Easter, Alice on 4/16/19.
//  Copyright © 2019 Easter, Alice. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var table: UITableView!
    var mMessages: [Message] = []
    var mLikeIds: [String] = []
    @IBOutlet weak var mMessageField: UITextField!
    let refresh = UIRefreshControl()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.table.delegate = self
        self.table.dataSource = self
        // pull to refresh from: https://medium.com/anantha-krishnan-k-g/pull-to-refresh-how-to-implement-f915743703f8
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.table.addSubview(self.refresh)
        mLikeIds = UserDefaults.standard.object(forKey: "liked") as? [String] ?? [String]()
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        getMessages()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getMessages()
        refreshControl.endRefreshing()
    }
    
    func getMessages() {
        netRequest(
            path: "",
            method: .get,
            message: nil, parameters: ""
        ) { response in
            if let json = response.result.value as? [String: Any],
                let messages = json["messages"] as? [[String: Any]] {
                self.mMessages = []
                for entry in messages {
                    if let message = Message(json: entry) {
                        self.mMessages.append(message)
                    }
                }
                
                self.table.reloadData()
            }
        }
    }
    
    func sendMessage(message: String) {
        let escapedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let location = locationManager.location?.coordinate
        
        netRequest(
            path: "",
            method: .post,
            message: escapedMessage, parameters: "&lat=\(location?.latitude as? Double ?? 0.0)&lon=\(location?.longitude as? Double ?? 0.0)"
        ) { response in
            if let json = response.result.value as? [String: Any] {
                if let success = json["code"] as? String {
                    if success == "1" {
                        self.getMessages()
                    }
                }
            }
        }
    }
    
    func likeMessage(message: Message, good: Bool) {
        if message.like(good: good) {
            netRequest(path: "/\(good ? "like" : "dislike")/\(message._id)", method: .get, message: nil, parameters: "") { response in
                if let json = response.result.value as? [String: Any] {
                    if let success = json["code"] as? String {
                        if success == "1" {
                            self.mLikeIds.append(message._id)
                            UserDefaults.standard.set(self.mLikeIds, forKey: "liked")
                            
                            self.getMessages()
                        }
                    }
                }
            }
        }
    }
    
    func netRequest(path: String,
                    method: HTTPMethod,
                    message: String?,
                    parameters: String,
                    cb: @escaping (DataResponse<Any>) -> Void) {
        var url = "https://www.stepoutnyc.com/chitchat\(path)?key=c9be0e9b-6265-41c6-9090-fd83f6e4537e&client=shawn.fortin@mymail.champlain.edu\(parameters)"
        
        if message != nil {
            url = "\(url)&message=\(message!)"
        }
        
        Alamofire.request(
            url,
            method: method
        ).responseJSON(completionHandler: cb)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let like = UITableViewRowAction(style: .normal, title: "Like", handler: {(action, indexPath) in
            if !self.mLikeIds.contains(self.mMessages[indexPath.row]._id) {
                self.likeMessage(message: self.mMessages[indexPath.row], good: true)
            }
        })
        
        let dislike = UITableViewRowAction(style: .normal, title: "Dislike", handler: {(action, indexPath) in
            if !self.mLikeIds.contains(self.mMessages[indexPath.row]._id) {
                self.likeMessage(message: self.mMessages[indexPath.row], good: false)
            }
        })
        
        like.backgroundColor = UIColor.green
        dislike.backgroundColor = UIColor.red
        
        return [like, dislike]
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
        
        // URL DETECTOR FROM : https://www.hackingwithswift.com/example-code/strings/how-to-detect-a-url-in-a-string-using-nsdatadetector
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(
            in: message.message,
            options: [],
            range: NSRange(
                location: 0,
                length: message.message.utf16.count
            )
        )
        
        for match in matches {
            guard let range = Range(match.range, in: message.message) else { continue }
            
            let url: URL = URL(string: String(message.message[range]))!
            let data: Data = try! Data(contentsOf: url)
                
            (cell.contentView.viewWithTag(2) as! UIImageView).image = UIImage.init(data: data)
        }
        
        if matches.count == 0 {
            (cell.contentView.viewWithTag(1) as! UILabel).text = message.message
        }
        
        (cell.contentView.viewWithTag(4) as! UILabel).text = "\(message.likes)"
        (cell.contentView.viewWithTag(5) as! UILabel).text = "\(message.dislikes)"
        (cell.contentView.viewWithTag(3) as! UILabel).text = "\(message.loc[1]), \(message.loc[0])"
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            let next = segue.destination as! MapDetailViewController
            let message = mMessages[(table.indexPathForSelectedRow?.row)!]
            next.latitude = Double (message.loc[1])
            next.longitude = Double (message.loc[0])
        }
    }
    
    @IBAction func like(_ sender: Any) {
        if let cell = (sender as! UIButton).superview?.superview as? UITableViewCell {
            if !mLikeIds.contains(mMessages[(table.indexPath(for: cell)?.row)!]._id) {
                likeMessage(message: mMessages[(table.indexPath(for: cell)?.row)!], good: true)
            }
        }
    }
    
    @IBAction func dislike(_ sender: Any) {
        if let cell = (sender as! UIButton).superview?.superview as? UITableViewCell {
            if !mLikeIds.contains(mMessages[(table.indexPath(for: cell)?.row)!]._id) {
                likeMessage(message: mMessages[(table.indexPath(for: cell)?.row)!], good: false)
            }
        }
    }
    
    @IBAction func send(_ sender: Any) {
        sendMessage(message: mMessageField.text ?? "")
        mMessageField.text = ""
    }
}

