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

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var chatPartner: User?
    
    let msgField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Message"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    func setUpNavBarColor() {
        let nav = self.navigationController?.navigationBar
        nav?.translucent = false
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img,forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.tintColor = AppDelegate().RGB(68.0, g: 176.0,b:80.0)
        self.navigationController?.navigationBar.barTintColor = AppDelegate().RGB(240.0,g: 208.0,b: 138.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBarColor()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatLogController.tapHandler(_:)))
        view.addGestureRecognizer(tapRecognizer)
        createMessageInput()
        addNavItems()
        collectionView?.backgroundColor = UIColor.whiteColor()
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ChatLogController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: self.view.window)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatLogController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: self.view.window)
        collectionView?.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        
        msgField.delegate = self
    }
    
    //Handling the keyboard entry
    func keyboardWillShow(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        if keyboardSize.height == offset.height {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y -= keyboardSize.height
            })
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
    }
    
    //Handle the keyboard dismissal
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject: AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        self.view.frame.origin.y += keyboardSize.height
    }
    
    //Format the navigation bar
    func addNavItems(){
        print((chatPartner?.name)!)
        self.navigationItem.title = (chatPartner?.name)!
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        msgField.resignFirstResponder()
        return true
    }
    
    func tapHandler(gesture: UITapGestureRecognizer){
        msgField.resignFirstResponder()
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
        let ref = FIRDatabase.database().reference().child("messages1")
        let child = ref.childByAutoId()
        print(chatPartner!.name)
        print(chatPartner!.id)
        let toId = chatPartner!.id
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timeStamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        print(toId)
        let values: [String: AnyObject] = ["text": msgField.text!,"toId": toId!, "fromId": fromId, "timeStamp": timeStamp]
        child.updateChildValues(values) { (error, ref) in
            if error != nil {
                print (error)
                return
            }
            let messageRef = FIRDatabase.database().reference().child("user-messages1").child(fromId)
            let messageId = child.key
            messageRef.updateChildValues([messageId: 1])
            
            let recipient = FIRDatabase.database().reference().child("user-messages1").child(toId!)
            recipient.updateChildValues([messageId: 1])
//            
//            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId!)
//            let messageId = child.key
//            userMessagesRef.updateChildValues([messageId: 1])
//            
//            let recipient = FIRDatabase.database().reference().child("user-messages").child(toId!).child(fromId)
//            recipient.updateChildValues([messageId: 1])
        }
        msgField.resignFirstResponder()
        msgField.text = ""
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: view.frame.height, height: 80)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellId", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.blueColor()
        return cell
    }
    
}