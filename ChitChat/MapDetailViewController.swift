//
//  MapDetailViewController.swift
//  ChitChat
//
//  Created by Fortin, Shawn on 4/23/19.
//  Copyright © 2019 Easter, Alice. All rights reserved.
//

import UIKit
import MapKit

class MapDetailViewController: UIViewController {
    var latitude: Double!
    var longitude: Double!
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = "Message Location"
        map.addAnnotation(annotation)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
