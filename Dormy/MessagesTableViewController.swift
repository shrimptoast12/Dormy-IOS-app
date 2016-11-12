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
    var msgUserIdNums = [String]()
    var msgUsers = [[User]]()
    var allMessages = [[String]]()
    var mostRecent = [Message]()
    
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
        
        fetchSingleMessages()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    //get user data
    func fetchSingleMessages(){
        
        let userId = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference().child("user-messages").child(userId!)
        ref.observeEventType(.Value, withBlock: {(snapshot) in
            
            self.msgUserIdNums.removeAll()
            self.msgUsers.removeAll()
            self.allMessages.removeAll()
            self.mostRecent.removeAll()
            
            if let dictionary = snapshot.value as? [String: [String:AnyObject]]{
                
                //Dictionary keys are the single users that the current user is currently
                //in a conversation with
                var inGroupMsg: Bool = false
                let keys: [String] = Array(dictionary.keys)
                if (keys.count == 1 && keys[0] == "group_messages") {
                    self.fetchGroupMessages()
                }
                else {
                    for a in 0 ..< keys.count {
                        if (keys[0] != "group_messages"){
                            self.msgUserIdNums.append(keys[a])
                        } else {
                            inGroupMsg = true
                        }
                    }
                    //Dictionary value are dictionarys of the message ids
                    for a in 0 ..< (self.msgUserIdNums.count){
                        let temp: [String:AnyObject] = dictionary[self.msgUserIdNums[a]]!
                        let msgKeys: [String] = Array(temp.keys)
                        FIRDatabase.database().reference().child("messages").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            
                            if let dictionary = snapshot.value as? [String: [String: AnyObject]]{
                                var message: String = ""
                                var latest: NSNumber = 0
                                for c in 0 ..< msgKeys.count {
                                    let temp: [String: AnyObject] = dictionary[msgKeys[c]]!
                                    let time = temp["timeStamp"] as? NSNumber
                                    if (Int(time!) > Int(latest)){
                                        message = msgKeys[c]
                                        latest = time!
                                    }
                                    
                                }
                                let mostRecentMsg = Message()
                                let msgDictionary: [String: AnyObject] = dictionary[message]!
                                mostRecentMsg.setMsgWithDictionary(msgDictionary)
                                self.mostRecent.append(mostRecentMsg)
                            }
                            if (a == self.msgUserIdNums.count - 1){
                                if (inGroupMsg){
                                    self.fetchGroupMessages()
                                } else {
                                    self.fetchUserProfile()
                                }
                                
                            }
                            
                        }, withCancelBlock: nil)
                    }
                }
            }
            }, withCancelBlock: nil)
    }
    
    //get the Id numbers of the group messages
    func fetchGroupMessages(){
        
        let userId = FIRAuth.auth()?.currentUser?.uid
        
        //Entering in the group_messages node for the current user
        FIRDatabase.database().reference().child("user-messages").child(userId!).child("group_messages").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            
            //Creating a dictionary with gourp conversation id numbers as the keys and message dictionaries as the values
            if let dictionary = snapshot.value as? [String: [String:AnyObject]]{
                
                //obtain all conversation keys
                let keys: [String] = Array(dictionary.keys)
                for a in 0 ..< keys.count{
                    self.msgUserIdNums.append(keys[a])
                }
                
                //Find the most recent message
                for b in 0 ..< keys.count{
                    
                    let temp: [String:AnyObject] = dictionary[keys[b]]!
                    let msgKeys: [String] = Array(temp.keys)
                    FIRDatabase.database().reference().child("messages").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        
                        if let dictionary = snapshot.value as? [String: [String: AnyObject]]{
                            var message: String = ""
                            var latest: NSNumber = 0
                            for c in 0 ..< msgKeys.count {
                                let temp: [String: AnyObject] = dictionary[msgKeys[c]]!
                                let time = temp["timeStamp"] as? NSNumber
                                if (Int(time!) > Int(latest)){
                                    message = msgKeys[c]
                                    latest = time!
                                }
                            }
                            let mostRecentMsg = Message()
                            let msgDictionary: [String: AnyObject] = dictionary[message]!
                            mostRecentMsg.setMsgWithDictionary(msgDictionary)
                            self.mostRecent.append(mostRecentMsg)
                        }
                        if (b == keys.count - 1){
                            self.fetchUserProfile()
                        }
                        
                        }, withCancelBlock: nil)
                }
                
                
            } else {
                
                //If the current user is not involved in any group conversations then there are
                //no group conversations to fetch
                self.fetchUserProfile()
            }
            }, withCancelBlock: nil)
    }
    
    //Parse group Id numbers to get ids of individual users
    func parseKey(groupId: String) -> [String]{
        
        let users = groupId.characters.split{$0 == " "}.map(String.init)
        
        return users
    }
    
    //Get the user profiles
    func fetchUserProfile() {
        for a in 0 ..< msgUserIdNums.count {
            let userId: [String] = parseKey(msgUserIdNums[a])
            allMessages.append(userId)
        }
        FIRDatabase.database().reference().child("users").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                for b in 0 ..< self.allMessages.count {
                    var chatUsers = [User]()
                    for c in 0 ..< self.allMessages[b].count {
                        if (self.allMessages[b][c] != "group_messages"){
                            let temp = dictionary[self.allMessages[b][c]] as? [String: AnyObject]
                            let user = User()
                            let id = self.allMessages[b][c]
                            user.id = id
                            user.setUserWithDictionary(temp!, uid: id)
                            chatUsers.append(user)
                        }
                    }
                    if (!chatUsers.isEmpty){
                        self.msgUsers.append(chatUsers)
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            }, withCancelBlock: nil)
    }
    
    //handle the selection of cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let user: [User] = msgUsers[indexPath.row]
        goToChat(user)
    }
    
    //go to chat log of selected user
    func goToChat(user: [User]){
        let chatLog = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLog.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MessagesTableViewController.goBack))
        let navController = UINavigationController(rootViewController: chatLog)
        chatLog.chatPartners = user
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
        return msgUsers.count
    }
    
    func getNames(user: [User]) -> String {
        var groupNames: String = ""
        for a in 0 ..< user.count {
            if (a != user.count - 1){
                groupNames += user[a].name!
                groupNames += ", "
            } else {
                groupNames += user[a].name!
            }
            
        }
        return groupNames
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId", forIndexPath: indexPath) as! userMsgCell
        let user = msgUsers[indexPath.row]
        cell.textLabel!.text = getNames(user)
        if let profileImageUrl = user[0].imageURL {
            
            if (user[0].imageURL == "") {
                cell.profileImageView.image = UIImage(named: "empty_profile")
            }
            else {
                
                //If it is a group message
                if (user.count > 1) {
                    cell.profileImageView.loadImageUsingCacheWithUrlString("https://firebasestorage.googleapis.com/v0/b/dormy-e6239.appspot.com/o/group_empty_image.png?alt=media&token=2e1c5216-3bd8-4c7c-b8fe-fc7a269bdef4")
                } else {
                    cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                }
            }
        }
        cell.message = mostRecent[indexPath.row]
        return cell
    }

}
