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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 55
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        fetchUser()
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.setValuesForKeysWithDictionary(dictionary)
                print(user.name, user.email)
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId", forIndexPath: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        
        if let profileImageUrl = user.imageURL {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        return cell
    }
    
    //
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        goToChat()
    }
    
    //go to chat log of selected user
    func goToChat(){
        let chatLog = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        let navController = UINavigationController(rootViewController: chatLog)
        presentViewController(navController, animated: true, completion: nil)
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
