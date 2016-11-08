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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //   let storageRef = FIRStorage.storage().reference().child("laundryIcon").child("washer.png")
        
        //Compression factor of 0.1 on laundry icon
        //        if let uploadData = UIImagePNGRepresentation(self.laundryIcon.image!) {
        //            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
        //                if error != nil {
        //                    print(error)
        //                    return
        //                }
        //                // Set the imageURL for a laundry icon
        //                let ref = FIRDatabase.database().referenceFromURL("https://dormy-e6239.firebaseio.com/")
        //                let laundryRef = ref.child("laundry").child("image")
        //
        //
        //                    let imageURL = metadata?.downloadURL()?.absoluteString
        //                    FIRDatabase.database().reference().child("laundry").child("image").setValue(imageURL)
        //
        //            })
        //        }
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
