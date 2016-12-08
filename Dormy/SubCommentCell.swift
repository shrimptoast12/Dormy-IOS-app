//
//  SubCommentCell.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 12/6/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class SubCommentCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        imageProfile.translatesAutoresizingMaskIntoConstraints = false
        imageProfile.layer.cornerRadius = 25
        imageProfile.layer.masksToBounds = true
        imageProfile.contentMode = .ScaleAspectFill
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGrayColor()
        label.font = UIFont.systemFontOfSize(8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
}
