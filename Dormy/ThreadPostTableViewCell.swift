//
//  ThreadPostTableViewCell.swift
//  Dormy
//
//  Created by Tran, Viet Q on 12/7/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class ThreadPostTableViewCell: UITableViewCell {

    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImage.translatesAutoresizingMaskIntoConstraints = false
        userImage.layer.cornerRadius = 25
        userImage.layer.masksToBounds = true
        userImage.contentMode = .ScaleAspectFill
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
