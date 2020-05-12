//
//  ItemTableViewCell.swift
//  ArkusNexusTest
//
//  Created by Rene Cabañas Lopez on 11/05/20.
//  Copyright © 2020 Rene Cabañas Lopez. All rights reserved.
//

import UIKit
import SwiftyJSON
import Cosmos
import Kingfisher
import CoreLocation

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelAdresse: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var labelPetFriendly: UILabel!
    @IBOutlet weak var imagePetFriendly: UIImageView!
    @IBOutlet weak var imageAvatar: UIImageView!
    @IBOutlet weak var buttonArrow: UIButton!
    @IBOutlet weak var viewStars: CosmosView!
    
    private let startRating: Float = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var item: JSON? = nil{
        didSet {
            self.updateData()
        }
    }
                     
    override func layoutSubviews() {
       updateUI()
    }
    
    func updateUI(){
        self.layoutIfNeeded()
        self.viewStars.settings.fillMode = .precise
        self.imageAvatar.layer.cornerRadius = 8.0
        self.imageAvatar.clipsToBounds = true
    }
    
    func updateData(){
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
            self.labelPetFriendly.isHidden = false
        }else{
            self.imagePetFriendly.isHidden = true
            self.labelPetFriendly.isHidden = true
        }
        self.viewStars.isUserInteractionEnabled = false
        self.viewStars.settings.fillMode = .precise
        self.viewStars.rating = item!["Rating"].double!
        self.labelName.text = item!["PlaceName"].string!
        self.labelAdresse.text = item!["Address"].string!
        let url = URL(string: item!["Thumbnail"].string!)
        let processor = DownsamplingImageProcessor(size: imageAvatar.bounds.size)
        self.imageAvatar.contentMode = .scaleToFill
        self.imageAvatar.kf.indicatorType = .activity
        self.imageAvatar.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder_image"),
            options: [
                .processor(processor),
                .scaleFactor(1.0),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }

}
