//
//  OptionTableViewCell.swift
//  ArkusNexusTest
//
//  Created by Rene Cabañas Lopez on 12/05/20.
//  Copyright © 2020 Rene Cabañas Lopez. All rights reserved.
//

import UIKit

class OptionTableViewCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubTitle: UILabel!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var buttonGo: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
