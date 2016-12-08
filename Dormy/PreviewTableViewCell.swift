//
//  PostTableViewCell.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 12/6/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class PreviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleOfPost: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
