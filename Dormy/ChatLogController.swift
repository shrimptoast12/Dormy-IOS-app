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
    
    var chatPartners = [User]()
    var messages = [Message]()
    
    
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
        
        collectionView!.registerClass(MessageViewCell.self, forCellWithReuseIdentifier: "cellId")
        setUpNavBarColor()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatLogController.tapHandler(_:)))
        view.addGestureRecognizer(tapRecognizer)
        createMessageInput()
        addNavItems()
        collectionView?.backgroundColor = UIColor.whiteColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ChatLogController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatLogController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: self.view.window)
        
        collectionView?.alwaysBounceVertical = true
        
        // adjust part of message controller and pad it to let messages display nicer
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 60, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        
        msgField.delegate = self
        fetchUserMsg()
    }
    
    func getChatID() -> String{
        let currentUserID: String = (FIRAuth.auth()?.currentUser?.uid)!
        var chatId = ""
        
        //check to see if the current user is already in the conversation
        //if so, no need to add user uid to from of conversation id
        var userPresent: Bool = false
        for b in 0 ..< chatPartners.count{
            if (chatPartners[b].id! == currentUserID) {
                userPresent = true
            }
        }
        if (!userPresent){
            chatId += currentUserID
            chatId += " "
        }
        for a in 0 ..< chatPartners.count{
            chatId += chatPartners[a].id!
            if (a != chatPartners.count - 1){
                chatId += " "
            }
        }
        return chatId
    }
    
    //Gets the user message id numbers
    func fetchUserMsg(){
        let currentUserId = FIRAuth.auth()?.currentUser?.uid
        let chatId = getChatID()
        if (chatPartners.count == 1){
            FIRDatabase.database().reference().child("user-messages").child(currentUserId!).child(chatId).observeEventType(.Value, withBlock: {(snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let keys: [String] = Array(dictionary.keys)
                    self.getMessages(keys, user: currentUserId!)
                }
            })
        } else {
            FIRDatabase.database().reference().child("user-messages").child(currentUserId!).child("group_messages").child(chatId).observeEventType(.Value, withBlock: {(snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let keys: [String] = Array(dictionary.keys)
                    self.getMessages(keys, user: currentUserId!)
                }
            })
        }
        
    }
    
    //fetches the message data using the message id numbers passed by fetchUserMsg
    func getMessages(dict: [String], user: String){
        FIRDatabase.database().reference().child("messages").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            self.messages.removeAll()
            if let dictionary = snapshot.value as? [String: AnyObject]{
                for a in 0 ..< dict.count {
                    let msg = Message()
                    let temp2 = dict[a]
                    let temp = dictionary[temp2]
                    msg.setMsgWithDictionary(temp as! NSDictionary)
                    self.messages.append(msg)
                    self.messages.sortInPlace({ (firstMessage, secondMessage) -> Bool in
                        return secondMessage.timeStamp as! Int > firstMessage.timeStamp as! Int
                    })
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView?.reloadData()
            })
        })
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
    
    func getNames() -> String {
        var groupNames: String = ""
        for a in 0 ..< chatPartners.count {
            if (a != chatPartners.count - 1){
                groupNames += chatPartners[a].name!
                groupNames += " "
            } else {
                groupNames += chatPartners[a].name!
            }
            
        }
        return groupNames
    }
    
    func getID() -> String {
        let currentUserID: String = (FIRAuth.auth()?.currentUser?.uid)!
        var groupUID: String = ""
        
        //check to see if the current user is already in the conversation
        //if so, no need to add user uid to from of conversation id
        var userPresent: Bool = false
        for b in 0 ..< chatPartners.count{
            if (chatPartners[b].id! == currentUserID) {
                userPresent = true
            }
        }
        if (!userPresent){
            groupUID += currentUserID
            groupUID += " "
        }
        //Concat user uids
        for a in 0 ..< chatPartners.count {
            if (a != chatPartners.count - 1){
                groupUID += chatPartners[a].id!
                groupUID += " "
            } else {
                groupUID += chatPartners[a].id!
            }
            
        }
        return groupUID
    }
    
    //Format the navigation bar
    func addNavItems(){
        
        if (chatPartners.count == 1){
            self.navigationItem.title = (chatPartners[0].name)!
        } else {
            self.navigationItem.title = getNames()
        }
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
        
        let ref = FIRDatabase.database().reference().child("messages")
        let child = ref.childByAutoId()
        
        //To handle a message to a single user
        if (chatPartners.count == 1){
            let toId = chatPartners[0].id
            let fromId = FIRAuth.auth()!.currentUser!.uid
            let timeStamp: NSNumber = Int(NSDate().timeIntervalSince1970)
            let values: [String: AnyObject] = ["text": msgField.text!,"toId": toId!, "fromId": fromId, "timeStamp": timeStamp]
            child.updateChildValues(values) { (error, ref) in
                if error != nil {
                    print (error)
                    return
                }
                
                let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId!)
                let messageId = child.key
                userMessagesRef.updateChildValues([messageId: 1])
                
                let recipient = FIRDatabase.database().reference().child("user-messages").child(toId!).child(fromId)
                recipient.updateChildValues([messageId: 1])
            }
        } else {
            //Handle a message to a group
            let toId = getID()
            let fromId = FIRAuth.auth()!.currentUser!.uid
            let timeStamp: NSNumber = Int(NSDate().timeIntervalSince1970)
            let values: [String: AnyObject] = ["text": msgField.text!,"toId": toId, "fromId": fromId, "timeStamp": timeStamp]
            child.updateChildValues(values) { (error, ref) in
                if error != nil {
                    print (error)
                    return
                }
                let groupId = self.getID()
                let groupMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child("group_messages").child(groupId)
                let messageId = child.key
                groupMessagesRef.updateChildValues([messageId: 1])
                
                //***********************************
                //ADDED CONDITIONAL TO RECIPIENTS
                //***********************************
                
                for a in 0 ..< self.chatPartners.count {
                    let recipient = self.chatPartners[a].id!
                    if (recipient != fromId){
                        let recipientRef = FIRDatabase.database().reference().child("user-messages").child(recipient).child("group_messages").child(groupId)
                        recipientRef.updateChildValues([messageId: 1])
                    }
                }
            }
        }
        msgField.resignFirstResponder()
        msgField.text = ""
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView?.reloadData()
        })
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var height:CGFloat = 150
        if let text = messages[indexPath.item].text {
            height = adjustMessageSize(text).height + 20
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    func adjustMessageSize(message: String) -> CGRect {
        let size = CGSize(width: 200, height: 1200)
        let options = NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(18)]
        return NSString(string: message).boundingRectWithSize(size, options: options, attributes: attributes, context: nil)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellId", forIndexPath: indexPath) as! MessageViewCell
        let actualText = messages[indexPath.item]
        cell.messageText.text = actualText.text
        
        var index: Int = 0
        for a in 0 ..< chatPartners.count {
            if(self.chatPartners[a].id! == messages[indexPath.row].fromId!){
                index = a
            }
        }
        if let imageURL = self.chatPartners[index].imageURL {
            cell.profileImage.loadImageUsingCacheWithUrlString(imageURL)
        }
        
        // if it is not the current user, then make the text bubbles gray
        if (actualText.fromId != FIRAuth.auth()?.currentUser?.uid) {
            cell.backgroundTextView.backgroundColor = UIColor.lightGrayColor()
            cell.backgroundTextRightAnchor?.active = false
            cell.backgroundTextLeftAnchor?.active = true
            cell.profileImage.hidden = false
        }
        else {
            cell.backgroundTextView.backgroundColor = AppDelegate().RGB(68.0, g: 176.0,b:80.0)
            cell.messageText.textColor = UIColor.whiteColor()
            cell.backgroundTextRightAnchor?.active = true
            cell.backgroundTextLeftAnchor?.active = false
            cell.profileImage.hidden = true
        }
        
        // modify the text's size
        cell.backgroundTextViewWidth?.constant = adjustMessageSize(actualText.text!).width + 40
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView?.reloadData()
        })
        
        return cell
    }
}