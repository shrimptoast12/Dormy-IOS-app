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
        
        fetchUsers()

        print(msgUsers.count)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    //get user data
    func fetchUsers(){
        let userId = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference().child("user-messages").child(userId!)
        ref.observeEventType(.ChildAdded, withBlock: {(snapshot) in
            
            let msgUserId = snapshot.key
            print(msgUserId)
            let allUsersRef = FIRDatabase.database().reference().child("users").child(msgUserId)
            
            allUsersRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User()
                    user.id = snapshot.key
                    user.setValuesForKeysWithDictionary(dictionary)
                    self.msgUsers.append(user)
                    print(user.name!)
                    print(user.id!)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
                
            }, withCancelBlock: nil)
        })
    }
    
    //handle the selection of cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let user: User = msgUsers[indexPath.row]
        goToChat(user)
    }
    
    //go to chat log of selected user
    func goToChat(user: User){
        let chatLog = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLog.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "goBack")
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
        return msgUsers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId", forIndexPath: indexPath) as! userMsgCell
        
        let user = msgUsers[indexPath.row]
        cell.textLabel!.text = user.name!
        if let profileImageUrl = user.imageURL {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        return cell
    }
        

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
}
