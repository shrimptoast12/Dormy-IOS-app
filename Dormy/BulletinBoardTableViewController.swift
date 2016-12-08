//
//  BulletinBoardTableViewController.swift
//  Dormy
//
//  Created by Benjamin Lee on 11/20/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase
import Foundation

class BulletinBoardTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var posts = [Post]()
    
    // Sets up the UI components for the navigation bars to make it look nicer
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
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        tableView.rowHeight = 187

        
        fetchPosts()
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    func fetchPosts() {
        FIRDatabase.database().reference().child("bulletin").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let post = Post()
                post.setPostWithDictionary(dictionary, postId: snapshot.key)
                self.posts.append(post)
                
                dispatch_async(dispatch_get_main_queue(), { 
                    self.tableView.reloadData()
                })
            }
            }, withCancelBlock: nil)
    }
    
    func sortPosts() {
        posts.sortInPlace { (post1:Post, post2:Post) -> Bool in
            post1.timeStamp!.doubleValue > post2.timeStamp!.doubleValue
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostTableCell", forIndexPath: indexPath) as! PostTableViewCell
        sortPosts()
        let post = posts[indexPath.row]
        cell.titleOfPost?.text = post.title!
        cell.userName?.text = post.owner!
        cell.postDescription?.text = post.description!
        let timeStampDate = NSDate(timeIntervalSince1970: post.timeStamp!.doubleValue)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a MM/dd/yy"
        cell.timeStamp?.text = dateFormatter.stringFromDate(timeStampDate)
        if (post.postType! == "event") {
            cell.postImage?.image = UIImage(named: "event")
        }
        else if (post.postType! == "alert") {
            cell.postImage?.image = UIImage(named: "alert")
        }
        else if (post.postType! == "question") {
            cell.postImage?.image = UIImage(named: "question")
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showThread" {
            let destination = segue.destinationViewController as? BulletinThreadTableViewController
            let index = tableView.indexPathForSelectedRow?.row
            destination?.post = posts[index!]
        }
    }

}
