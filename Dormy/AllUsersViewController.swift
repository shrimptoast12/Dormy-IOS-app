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
    
    // Adds some UI elements to the nav bar to make it look nicer
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
        fetchUser()
    }
    
    // Fetches the user from the database and appends the user to a User array
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.id = snapshot.key
                
                user.setUserWithDictionary(dictionary, uid: user.id!)

                self.users.append(user)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
            }
            
        }, withCancelBlock: nil)
        
    }
    
    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Return number of rows based on how many users there are
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    // Load the users
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId", forIndexPath: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        
        if user.imageURL == "" {
            cell.profileImageView.image = UIImage(named: "empty_profile")
        }
        else {
            if let profileImageUrl = user.imageURL {
                cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            }
        }
        return cell
    }
    
    // clicking on a user cell opens up their chat log
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let user: User = users[indexPath.row]
        goToChat(user)
    }
    
    //go to chat log of selected user
    func goToChat(user: User){
        let chatLog = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLog.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AllUsersViewController.goBack))
        let navController = UINavigationController(rootViewController: chatLog)
        chatLog.chatPartner = user
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
