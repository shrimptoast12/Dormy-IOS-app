//
//  userMsgCell.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 11/9/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class UserMsgCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            
            if let actualId = message?.returnId() {
                let ref = FIRDatabase.database().reference().child("users").child(actualId)
                ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        self.textLabel?.text = dictionary["name"] as? String
                        
                        if let imageUrl = dictionary["imageURL"] as? String {
                            self.profileImageView.loadImageUsingCacheWithUrlString(imageUrl)
                        }
                    }
                    
                    }, withCancelBlock: nil)
            }
            detailTextLabel?.text = message?.text
            timeLabel.text = message?.timeStamp
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRectMake(64, textLabel!.frame.origin.y - 2, textLabel!.frame.width, textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRectMake(64, detailTextLabel!.frame.origin.y + 2, detailTextLabel!.frame.width, detailTextLabel!.frame.height)
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        //set up the cell for individual profiles
        profileImageView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
        profileImageView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(48).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(48).active = true
        
        timeLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        timeLabel.centerYAnchor.constraintEqualToAnchor(textLabel?.centerYAnchor).active = true
        timeLabel.widthAnchor.constraintEqualToConstant(100).active = true
        timeLabel.heightAnchor.constraintEqualToAnchor(textLabel?.heightAnchor).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
