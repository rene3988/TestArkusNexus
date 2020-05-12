//
//  DetailViewController.swift
//  ArkusNexusTest
//
//  Created by Rene Cabañas Lopez on 11/05/20.
//  Copyright © 2020 Rene Cabañas Lopez. All rights reserved.
//

import UIKit
import SwiftyJSON
import Reachability
import CoreLocation
import MapKit
import Cosmos
import Kingfisher

class DetailViewController: UIViewController, MKMapViewDelegate {

    // Data model: These strings will be the data for the table view cells
    let items: [String] = ["Directions", "Call", "Visit Website"]
    let cellReuseIdentifier = "OptionTableViewCell"

    var item: JSON!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelAdresse: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var imagePetFriendly: UIImageView!
    @IBOutlet weak var viewStars: CosmosView!
    // MARK: - Properties
    let regionRadius: CLLocationDistance = 1000
    var cuerrentLocationUser:CLLocationCoordinate2D!
    var currentMKAnnotation:MKAnnotation!
    var timeRoute:TimeInterval!

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("item detail %@",item)
        self.title = "Detail"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.timeRoute = TimeInterval(0.0)
        
        let Latitude = item["Latitude"].double!
        let Longitude = item["Longitude"].double!
        let placeLocation = CLLocation(latitude: Latitude, longitude: Longitude)
        let location:CLLocationCoordinate2D = placeLocation.coordinate
        setLocation(locValue: location)
        
        /*
         {
           "PlaceId": "ChIJjS5n_YLMj4ARlfgRtxtoW00",
           "PlaceName": "IHOP",
           "Address": "644 N 1st St, San Jose",
           "Category": "restaurant",
           "IsOpenNow": "Open now",
           "Latitude": 37.348115,
           "Longitude": -121.8990835,
           "Thumbnail": "https://maps.googleapis.com/maps/api/place/photo?maxwidth=2400&photoreference=CmRaAAAAe8OYJqvYpTKJR3EkuxBukX1ox0gm9-8NNO19OvbCRtiSvKHthC_3_8KAsq6-ARBRR1T-zzigB8k8THFVAQsYTJD3ibe_LE_Cwi4whBVkKBhO6R-HQIpKpFYVcDAq3rEoEhANPd06Rb2KwWN3HGJ0rVBhGhRLWqZY9nHwHf7tCRSMjiYtmeD1Lw&key=AIzaSyBKYncKJA-Uu060807q_t3g1Y6o6Y9fyaI",
           "Rating": 4.2,
           "IsPetFriendly": false,
           "AddressLine1": "644 N 1st St",
           "AddressLine2": "San Jose",
           "PhoneNumber": "(664) 326 2312",
           "Site": "http://www.arkusnexus.com"
         "distance" : 66.331764982604255

         }
         */
        if(item!["distance"].exists()){
            self.labelDistance.text = getDistance(distance: item!["distance"].number!)
        }else{
            self.labelDistance.text = "NA"
        }
         
        let IsPetFriendly = item!["IsPetFriendly"].bool!
        if (IsPetFriendly){
            self.imagePetFriendly.isHidden = false
        }else{
            self.imagePetFriendly.isHidden = true
        }
        self.viewStars.isUserInteractionEnabled = false
        self.viewStars.settings.fillMode = .precise
        self.viewStars.rating = item!["Rating"].double!
        self.labelName.text = item!["PlaceName"].string!
        self.labelAdresse.text = item!["Address"].string!
        
        // Do any additional setup after loading the view.
        getRoute()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }

        // Better to make this class property
        let annotationIdentifier = "AnnotationIdentifier"

        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }

        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "pinSelected")
        }

        return annotationView
    }
    
    func setLocation(locValue: CLLocationCoordinate2D){
        let annotation:MKAnnotation = MapPin(coordinate: locValue, title:self.item!["PlaceName"].string!, subtitle: self.item!["Address"].string!)
        self.mapView.addAnnotation(annotation)
        let location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        self.centerMapOnLocation(location:location)
    }

    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }

    func getRoute(){
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.cuerrentLocationUser.latitude, longitude: self.cuerrentLocationUser.longitude), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: item["Latitude"].double!, longitude: item["Longitude"].double!), addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        self.timeRoute = 0
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }

            for route in unwrappedResponse.routes {
                print(route.name)
                self.timeRoute = route.expectedTravelTime
            }
            
            self.tableView.reloadData()
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
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

extension DetailViewController : UITableViewDelegate, UITableViewDataSource {
 
    func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

         let cell:OptionTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! OptionTableViewCell
        // set the text from the data model
        //cell.textLabel?.text = self.items[indexPath.row]
        cell.tag = indexPath.row
        cell.selectionStyle = .none
        cell.labelTitle.text = self.items[indexPath.row]
        if(indexPath.row == 0){
            cell.labelSubTitle.text =  self.timeRoute.stringFromTimeInterval()   +  " drive"
            cell.imageIcon.image = UIImage(named: "icons8RouteFilled")
        }else if(indexPath.row == 1){
            cell.labelSubTitle.text =  item["PhoneNumber"].string!

            cell.imageIcon.image = UIImage(named: "cellIconsPhoneCopy1")
        }else{
            cell.labelSubTitle.text = item["Site"].string!
            cell.imageIcon.image = UIImage(named: "cellIconsWebsite")
        }
    
        return cell
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        if(indexPath.row == 0){
            openMapForPlace(PlaceName: item["PlaceName"].string!,latitude:item["Latitude"].double! ,longitude:item["Longitude"].double! )
        }else if(indexPath.row == 1){
            let phoneNumber = ((item["PhoneNumber"].string!).digits).trimmingCharacters(in: .whitespaces)
            guard let url = URL(string: "tel://\(phoneNumber)") else {
              return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }

        }else if(indexPath.row == 2){
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let webViewController = storyBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.url_site =  item["Site"].string!
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
          return UITableView.automaticDimension
      }
      
}

class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage? = nil

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

extension String {
    private static var digits = UnicodeScalar("0")..."9"
    var digits: String {
        return String(unicodeScalars.filter(String.digits.contains))
    }
}

extension TimeInterval{

    func stringFromTimeInterval() -> String {
        let time = NSInteger(self)
        _ = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        return String(format: "%0.2d:%0.2d:%0.2d.%0",hours,minutes,seconds)

    }
}
