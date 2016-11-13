//
//  NewMessageController.swift
//  Dormy
//
//  Created by Benjamin Lee on 11/2/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class AllUsersViewController: UITableViewController {
    
    var users = [User]()
    
    var groupMessage = [User]()
    
    var userIdList = [String]()
    
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
        self.setUpNavBarColor()
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 55
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(handleDone))
        fetchUser()
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                let id = snapshot.key
                user.id = id
                user.setUserWithDictionary(dictionary, uid: id)
                if (FIRAuth.auth()!.currentUser!.uid != user.id!){
                    self.users.append(user)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
            }
            
            }, withCancelBlock: nil)
        
    }
    
    func handleDone() {
        if (groupMessage.count != 0) {
            goToChat()
        }
    }
    
    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId", forIndexPath: indexPath) as! UserCell
        cell.selectionStyle = .None
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        if (self.userIdList.contains(user.id!)) {
            cell.selected = true
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        if (user.imageURL == "") {
            cell.profileImageView.image = UIImage(named: "empty_profile")
        }
        else {
            if let profileImageUrl = user.imageURL {
                cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            }
        }
        return cell
    }
    
    // Function that defines what to do when a cell is selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let msgGroupUser = users[indexPath.row]
        if (cell?.accessoryType == UITableViewCellAccessoryType.Checkmark){
            cell!.accessoryType = UITableViewCellAccessoryType.None;
            self.groupMessage.removeAtIndex(self.groupMessage.indexOf(msgGroupUser)!)
            self.userIdList.removeAtIndex(self.userIdList.indexOf(msgGroupUser.id!)!)
        }
        else{
            self.groupMessage.append(msgGroupUser)
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark;
            self.userIdList.append(msgGroupUser.id!)
        }
    }
    
    //go to chat log of selected user
    func goToChat(){
        let chatLog = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLog.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AllUsersViewController.goBack))
        let navController = UINavigationController(rootViewController: chatLog)
        chatLog.chatPartners = groupMessage
        presentViewController(navController, animated: true, completion: nil)
    }
    
    //add back button to navigation bar
    func goBack(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

let imageCache = NSCache()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.objectForKey(urlString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = NSURL(string: urlString)
        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString)
                    
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
}
