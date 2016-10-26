//
//  RoommateTableViewCell.swift
//  Dormy
//
//  Created by Benjamin Lee on 10/26/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class RoommateTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
