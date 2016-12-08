//
//  LaundryTableViewCell.swift
//  Dormy
//
//  Created by Tran, Viet Q on 11/6/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class LaundryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var laundryIcon: UIImageView!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reserveButton: UIButton!
    @IBOutlet weak var freeButton: UIButton!
    
    @IBOutlet weak var currentUseLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.reserveButton.hidden = true
    }
    
    @IBAction func reserveAction(sender: AnyObject) {
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
