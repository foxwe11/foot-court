//
//  CuctomTableViewCell.swift
//  Foot court
//
//  Created by Admin on 04/11/2019.
//  Copyright © 2019 Anton Varenik. All rights reserved.
//

import UIKit
import Cosmos

class CuctomTableViewCell: UITableViewCell {

    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace?.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace?.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var locationLable: UILabel!
    @IBOutlet weak var typeLable: UILabel!
    @IBOutlet weak var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
    

}
