//
//  MoreViewController.swift
//  WeatherDataScrollView
//
//  Created by Beniamin on 01.07.19.
//  Copyright © 2019 Beniamin. All rights reserved.
//

import UIKit
import MapKit

class MoreViewController: UIViewController {
    
    
    @IBOutlet weak var map: MKMapView!
    var city: String = ""
    var temp: String = ""
    
    var someNums = ["", "", "", "", "", ""]
    let names = ["Latitude", "Longitude", "Min temperature", "Max temperature", "Sunrise", "Sunset"]
    @IBOutlet weak var moreDataTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.moreDataTableView.delegate = self
        self.moreDataTableView.dataSource = self
        self.view.addBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        moreDataTableView.reloadData()
        let annotation = MKPointAnnotation()
        //print(someNums[0])
        annotation.coordinate = CLLocationCoordinate2D(latitude: Double(someNums[0])!, longitude: Double(someNums[1])!)
        annotation.title = city
        annotation.subtitle = "\(temp)" //add unit (C or F)
        map.addAnnotation(annotation)
        map.centerCoordinate = annotation.coordinate;
    }

}

extension MoreViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return someNums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreDataCell", for: indexPath)
        cell.textLabel?.text = "\(names[indexPath.row])" + ": " + "\(someNums[indexPath.row])"
        //cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        cell.textLabel?.textAlignment = .center
        cell.backgroundView = UIImageView(image: UIImage(named: "bg1a")!)
        
        return cell
    }

}


