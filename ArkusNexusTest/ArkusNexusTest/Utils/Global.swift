//
//  Global.swift
//  ArkusNexusTest
//
//  Created by Rene Cabañas Lopez on 11/05/20.
//  Copyright © 2020 Rene Cabañas Lopez. All rights reserved.

import Foundation
import UIKit
import Reachability
import Alamofire
import CoreLocation
import MapKit
// MARK: - Color scheme
let COLOR_WHITE_TRANS = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.0)
let COLOR_WHITE_ALPHA_MIDDLE = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
let COLOR_WHITE = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
let COLOR_ORANGE = UIColor(red: 255.0/255.0, green: 163.0/255.0, blue: 0.0/255.0, alpha: 1.0)
let COLOR_GRAY = UIColor(red: 223.0/255.0, green: 223.0/255.0, blue: 225.0/255.0, alpha: 1.0)
let COLOR_BLUE = UIColor(red: 44.0/255.0, green: 96.0/255.0, blue: 133.0/255.0, alpha: 1.0)
let COLOR_GREENBLUE = UIColor(red: 119.0/255.0, green: 208.0/255.0, blue: 206.0/255.0, alpha: 1.0)
let COLOR_DARK_GRAY = UIColor(red: 127.0/255.0, green: 136.0/255.0, blue: 143.0/255.0, alpha: 1.0)
let COLOR_GUMMETAL = UIColor(red: 87.0/255.0, green: 91.0/255.0, blue: 94.0/255.0, alpha: 1.0)
let COLOR_TEALISH = UIColor(red: 47.0/255.0, green: 179.0/255.0, blue: 180.0/255.0, alpha: 1.0)
let COLOR_BLACK = UIColor(red: 3.0/255.0, green: 3.0/255.0, blue: 3.0/255.0, alpha: 1.0)
let COLOR_SEMI_BLACK = UIColor(red: 32.0/255.0, green: 32.0/255.0, blue: 32.0/255.0, alpha: 1.0)


let URL_ENDPOINT =  "http://www.mocky.io/v2/"
let URL_WEBSITE =  "http://www.arkusnexus.com"
let NUMBER_PHONE =  "+52 (813) 067 4942"

func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
}

func getDistanceDouble(userLocation:CLLocation, placeLocation:CLLocation) -> Double {
    //Measuring my distance to my buddy's (in km)
    let distance = userLocation.distance(from: placeLocation) / 1000

    //Display the result in km
    return distance
}

func getDistance(distance:NSNumber) -> String {
    //Display the result in km
    return String(format: "%.01f km", distance.doubleValue)
}

func openMapForPlace(PlaceName:String,latitude:Double,longitude:Double ) {

    let lat1 : NSString = "\(latitude)" as NSString
    let lng1 : NSString = "\(longitude)" as NSString

    let latitude:CLLocationDegrees =  lat1.doubleValue
    let longitude:CLLocationDegrees =  lng1.doubleValue

    let regionDistance:CLLocationDistance = 10000
    let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
    let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
    let options = [
        MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
        MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
    ]
    let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = "\(PlaceName)"
    mapItem.openInMaps(launchOptions: options)

}

func downloadImage(from url: URL, imageView:UIImageView ) {
    print("Download Started")
    getData(from: url) { data, response, error in
        guard let data = data, error == nil else { return }
        print(response?.suggestedFilename ?? url.lastPathComponent)
        print("Download Finished")
        DispatchQueue.main.async() {
            imageView.image = UIImage(data: data)
        }
    }
}

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

func isConnect() -> Bool {
    return NetworkReachabilityManager()!.isReachable
}

func getFormattedDate(date: Date, format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        dateformat.locale = Locale.current
        dateformat.timeZone = TimeZone.current
        return dateformat.string(from: date)
}

func convertDoubleToCurrency(amount: Double) -> String{
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.locale = NSLocale(localeIdentifier: "es_MX") as Locale
    return numberFormatter.string(from: NSNumber(value: amount))!
}

func convertCurrencyToDouble(input: String) -> Double? {
     let numberFormatter = NumberFormatter()
     numberFormatter.numberStyle = .currency
     numberFormatter.locale = NSLocale(localeIdentifier: "es_MX") as Locale

     return numberFormatter.number(from: input)?.doubleValue
}

func showAlertGeneric(vc:UIViewController,title:String, msg:String){
    let errorMessage = msg
    let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertAction.Style.default, handler: nil))
    vc.present(alert, animated: true, completion: nil)
}

func showLoading(){
    DispatchQueue.main.async {
        let imageviewLoading:UIImageView! = UIImageView()
        //imageviewLoading.loadGif(name: "loading_water")
        imageviewLoading.tintColor = UIColor.clear
        imageviewLoading.tag = 10001
        imageviewLoading.isHidden = false
        imageviewLoading.frame = (UIApplication.shared.delegate?.window??.frame)!
        imageviewLoading.contentMode = .center
        imageviewLoading.backgroundColor  = UIColor.white
        UIView.animate(withDuration: 1.0, animations: {
            UIApplication.shared.delegate?.window??.addSubview(imageviewLoading)
            UIApplication.shared.delegate?.window??.isUserInteractionEnabled = false
            for subview in  (UIApplication.shared.delegate?.window??.subviews)! {
                if subview.tag == 10001{
                    imageviewLoading.bringSubviewToFront(subview)
                }
            }
        },completion: { _ in
            
            
        })
    }
    
}

func hideLoading(){
    DispatchQueue.main.async {
        UIView.animate(withDuration: 0.5, animations: {
            for subview in  (UIApplication.shared.delegate?.window??.subviews)! {
                if subview.tag == 10001{
                    subview.removeFromSuperview()
                    UIApplication.shared.delegate?.window??.isUserInteractionEnabled = true
                    
                }
            }
        },completion: { _ in })
    }
    
}

func convertCurrencyFormat(value:Double) -> String{
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    currencyFormatter.locale = Locale.current
    return currencyFormatter.string(from: NSNumber(value: value))!
}

func alertSettingsNetworking(vc:UIViewController){
    
    let alertController = UIAlertController(title: "Error de conexión", message: "Falla en conexión a Internet", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "Aceptar", style: .default, handler: {(alert: UIAlertAction!) in
                   
    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    })
    alertController.addAction(OKAction)
    vc.present(alertController, animated: true, completion: nil)
}

func changeColorStatusBar(view:UIView){
    if #available(iOS 13.0, *) {
        let app = UIApplication.shared
        let statusBarHeight: CGFloat = app.statusBarFrame.size.height
        
        let statusbarView = UIView()
        statusbarView.backgroundColor = COLOR_WHITE
        view.addSubview(statusbarView)
      
        statusbarView.translatesAutoresizingMaskIntoConstraints = false
        statusbarView.heightAnchor
            .constraint(equalToConstant: statusBarHeight).isActive = true
        statusbarView.widthAnchor
            .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        statusbarView.topAnchor
            .constraint(equalTo: view.topAnchor).isActive = true
        statusbarView.centerXAnchor
            .constraint(equalTo: view.centerXAnchor).isActive = true
      
    } else {
        let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
        statusBar?.backgroundColor = COLOR_WHITE
    }
}

extension String{
    func convertHtml() -> NSAttributedString{
        guard data(using: .utf8) != nil else { return NSAttributedString() }
        do{
            return try NSAttributedString(data: Data(utf8),
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        }catch{
            return NSAttributedString()
        }
    }
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.height
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.width
    }
    
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        print(constraintRect.height)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
}

extension Data
{
    func toString() -> String
    {
        return String(data: self, encoding: .utf8)!
    }
}

