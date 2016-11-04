//
//  ChatLogTableViewController.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 11/3/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ChatLogController: UICollectionViewController {
    
    let msgField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Message"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createMessageInput()
        addNavItems()
        collectionView?.backgroundColor = UIColor.whiteColor()
        
    }
    
    //Format the navigation bar
    func addNavItems(){
    
    }
    
    //create view to contain message input textbox
    func createMessageInput(){
        let containerView = UIView()
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
    
        //Add constraints to the view
        containerView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        containerView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        containerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        containerView.heightAnchor.constraintEqualToConstant(50).active = true
        
        //create the send button
        let sendMsgButton = UIButton(type: .System)
        sendMsgButton.setTitle("Send", forState: .Normal)
        sendMsgButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendMsgButton)
        sendMsgButton.addTarget(self, action: #selector(sendButtonHandler), forControlEvents: .TouchUpInside)
        
        sendMsgButton.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        sendMsgButton.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor).active = true
        sendMsgButton.widthAnchor.constraintEqualToConstant(80).active = true
        sendMsgButton.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        
        
        containerView.addSubview(msgField)
    
        msgField.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: 10).active = true
        msgField.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        msgField.rightAnchor.constraintEqualToAnchor(sendMsgButton.leftAnchor).active = true
        msgField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        
        let msgBoxLine = UIView()
        msgBoxLine.backgroundColor = UIColor.lightGrayColor()
        msgBoxLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(msgBoxLine)
        
        msgBoxLine.bottomAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        msgBoxLine.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        msgBoxLine.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor).active = true
        msgBoxLine.heightAnchor.constraintEqualToConstant(1).active = true


    }
    
    func sendButtonHandler(){
        let msg: String? = msgField.text
    }
}