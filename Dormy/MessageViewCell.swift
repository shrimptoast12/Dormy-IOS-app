 //
//  MessageViewCell.swift
//  Dormy
//
//  Created by Tran, Viet Q on 11/11/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase
 
class MessageViewCell: UICollectionViewCell {
    let messageText: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFontOfSize(18)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.clearColor()
        textView.textColor = UIColor.whiteColor()
        return textView
    }()
    
    let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    
    var backgroundTextViewWidth: NSLayoutConstraint?
    var backgroundTextRightAnchor: NSLayoutConstraint?
    var backgroundTextLeftAnchor: NSLayoutConstraint?
    
    let backgroundTextView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = AppDelegate().RGB(68.0, g: 176.0,b:80.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // add the background color for the message
        addSubview(backgroundTextView)
        backgroundTextRightAnchor = backgroundTextView.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -8)
        backgroundTextRightAnchor?.active = true
        backgroundTextLeftAnchor = backgroundTextView.leftAnchor.constraintEqualToAnchor(profileImage.rightAnchor, constant: 8)
        
        backgroundTextView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        backgroundTextViewWidth = backgroundTextView.widthAnchor.constraintEqualToConstant(200)
        backgroundTextViewWidth?.active = true
        backgroundTextView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true

        
        // add message into the MessageViewCell with appropriate constraints
        addSubview(messageText)
        messageText.leftAnchor.constraintEqualToAnchor(backgroundTextView.leftAnchor, constant: 7).active = true
        messageText.rightAnchor.constraintEqualToAnchor(backgroundTextView.rightAnchor).active = true
        messageText.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        messageText.widthAnchor.constraintEqualToConstant(200).active = true
        messageText.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
        
        // add profile image into messsaging with appropriate constraints
        addSubview(profileImage)
        profileImage.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
        profileImage.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        profileImage.heightAnchor.constraintEqualToConstant(48).active = true
        profileImage.widthAnchor.constraintEqualToConstant(48).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Error. Implement init.")
    }
}
