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
    
    var backgroundTextViewWidth: NSLayoutConstraint?
    
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
        backgroundTextView.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -8).active = true
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Error. Implement init.")
    }
}
