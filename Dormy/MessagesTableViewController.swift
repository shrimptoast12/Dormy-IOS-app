 //
//  MessagesTableViewController.swift
//  Dormy
//
//  Created by Benjamin Lee on 11/5/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MessagesTableViewController: UITableViewController {
    
    var msgUsers = [User]()
    var firstMsg = [Message]()
    var messageGroup = [String: Message]()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    //Being used to select for whom to compose a message
    func viewAllUsers() {
        let newMessageController = AllUsersViewController()
        let navController = UINavigationController(rootViewController: newMessageController)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    @IBAction func composeNewMessage(sender: AnyObject) {
        self.viewAllUsers()
    }
    
    func setUpNavBarColor() {
        let nav = self.navigationController?.navigationBar
        nav?.translucent = false
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img,forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.barTintColor = AppDelegate().RGB(240.0,g: 208.0,b: 138.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpNavBarColor()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        tableView.rowHeight = 55
        tableView.registerClass(userMsgCell.self, forCellReuseIdentifier: "cellId")
        
        //fetchUsers()
        firstMsg.removeAll()
        messageGroup.removeAll()
        tableView.reloadData()
        fetchUserData()
        print(msgUsers.count)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func fetchUserData() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let ref = FIRDatabase.database().reference().child("user-messages1").child(uid)
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let messageId = snapshot.key
            let allMessagesRef = FIRDatabase.database().reference().child("messages1").child(messageId)
            allMessagesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message()
                    message.setValuesForKeysWithDictionary(dictionary)
                    //self.firstMsg.append(message)
                    if let actualId = message.returnId() {
                        self.messageGroup[actualId] = message
                        self.firstMsg = Array(self.messageGroup.values)
                        self.firstMsg.sortInPlace({ (firstMessage, secondMessage) -> Bool in
                            return firstMessage.timeStamp > secondMessage.timeStamp
                        })
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
                }, withCancelBlock: nil)
            
            }, withCancelBlock: nil)
    }
    
    
    //handle the selection of cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let message = firstMsg[indexPath.row]
        print(message.text, message.toId, message.fromId)
        
        guard let otherChatUserId = message.returnId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(otherChatUserId)
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = User()
            user.RA = dictionary["RA"] as? String
            user.availability = dictionary["availability"] as? String
            user.descript = dictionary["descript"] as? String
            user.email = dictionary["email"] as? String
            user.imageURL = dictionary["imageURL"] as? String
            user.name = dictionary["name"] as? String
            user.id = otherChatUserId
            self.goToChat(user)
            
            }, withCancelBlock: nil)
        //let user: User = msgUsers[indexPath.row]
        //goToChat(user)
    }
    
    //go to chat log of selected user
    func goToChat(user: User){
        let chatLog = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLog.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MessagesTableViewController.goBack))
        let navController = UINavigationController(rootViewController: chatLog)
        chatLog.chatPartner = user
        presentViewController(navController, animated: true, completion: nil)
    }
    
    //add back button to navigation bar
    func goBack(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    //specify the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //specify number of rows
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return firstMsg.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("cellId", forIndexPath: indexPath) as! userMsgCell
//        
//        let user = msgUsers[indexPath.row]
//        cell.textLabel!.text = user.name!
//        if let profileImageUrl = user.imageURL {
//            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
//        }
        //let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cellId")
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId", forIndexPath: indexPath) as! userMsgCell
        let message = firstMsg[indexPath.row]
        cell.message = message
        
        return cell
    }
    
}
