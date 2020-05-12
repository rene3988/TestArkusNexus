//
//  ViewController.swift
//  ArkusNexusTest
//
//  Created by Rene Cabañas Lopez on 11/05/20.
//  Copyright © 2020 Rene Cabañas Lopez. All rights reserved.
//

import UIKit
import SwiftyJSON
import Reachability
import CoreLocation

class ViewController: UIViewController {

    var jsonArray:[JSON]?
    var locationManager:CLLocationManager!
    var cuerrentLocationUser:CLLocationCoordinate2D!
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "ItemTableViewCell"

    var refreshControl = UIRefreshControl()
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        self.cuerrentLocationUser = CLLocationCoordinate2D()
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        self.jsonArray = [JSON]()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        request()
         // Do any additional setup after loading the view.
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        request()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        let logo = UIImage(named: "figoLogo")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
         
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func request(){
        if (isConnect()){
           self.callService()
        }else{
            alertSettingsNetworking(vc: self)
            refreshControl.endRefreshing()
        }
    }
    
    func callService(){
        showLoading()
        let request = ListRequest()
        request.completionBlock = { (response, error) in
            self.onListRequest(response: response, error: error)
        }
        request.execute()
    }
    
    func onListRequest(response: JSON?, error: Any?) {
        hideLoading()
        if (error != nil) {
            refreshControl.endRefreshing()
            showAlertGeneric(vc: self, title: "Error", msg: error.debugDescription)
            return

        }
        if let responseJson = response {
            if (responseJson != JSON.null) {
                let result =  responseJson.arrayValue
                if(!result.isEmpty){
                    var jsonArrayTemp = [JSON]()
                    self.jsonArray = [JSON]()
                    result.forEach { i in
                        var json = JSON()
                        json =  i
                        json["distance"] = JSON(getDistanceForItem(item: i))
                        jsonArrayTemp.append(json)
                    }
                    
                    jsonArrayTemp.sort { $0["distance"].doubleValue < $1["distance"].doubleValue }

                    jsonArrayTemp.forEach { i in
                        self.jsonArray?.append(i)
                    }
                    
                    tableView.reloadData()
                }else{
                    var error =  responseJson["error"].stringValue
                    if(error.isEmpty){
                        error = "Por el momento no hay información."
                    }
                    
                    showAlertGeneric(vc: self, title: "", msg: error)

                }
                refreshControl.endRefreshing()

            }
        }
        
    }
    
    func getDistanceForItem(item:JSON) -> Double{
        var distance = 0.0
        if(cuerrentLocationUser != nil){
            let userLocation = CLLocation(latitude: cuerrentLocationUser.latitude, longitude: cuerrentLocationUser.longitude)
                   
            let Latitude = item["Latitude"].double!
            let Longitude = item["Longitude"].double!
                   
            let placeLocation = CLLocation(latitude: Latitude, longitude: Longitude)
            distance = getDistanceDouble(userLocation: userLocation, placeLocation: placeLocation)
        }
        return distance
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
 
    func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jsonArray!.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

         let cell:ItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ItemTableViewCell


        // set the text from the data model
        //cell.textLabel?.text = self.items[indexPath.row]
        cell.tag = indexPath.row
        cell.selectionStyle = .none
        var item:JSON?
        item = self.jsonArray![indexPath.row]
        cell.item = item
        
        return cell
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        let item:JSON? = self.jsonArray![indexPath.row]
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailViewController = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailViewController.item = item!
        detailViewController.cuerrentLocationUser = self.cuerrentLocationUser!
        self.navigationController?.pushViewController(detailViewController, animated: true)

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
          return UITableView.automaticDimension
      }
      
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.cuerrentLocationUser = locValue
        self.request()
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}
