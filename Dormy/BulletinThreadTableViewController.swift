//
//  BulletinThreadTableViewController.swift
//  Dormy
//
//  Created by Benjamin Lee on 11/20/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase
class BulletinThreadTableViewController: UITableViewController {

    var post = Post()
    var comments = [Comment]()
    var my_group = dispatch_group_create()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Bulletin Board", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(BulletinThreadTableViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        fetchComments()
    }
    func fetchComments() {
        FIRDatabase.database().reference().child("bulletin").child(post.postId!).child("comments").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let comment = Comment()
                comment.setCommentWithDictionary(dictionary, commentId: snapshot.key, type: false)
                self.comments.append(comment)
                print("Comments Array1: \(self.comments.count)")
                dispatch_group_enter(self.my_group)
                FIRDatabase.database().reference().child("bulletin").child(self.post.postId!).child("comments").child(snapshot.key).child("nested").observeEventType(.ChildAdded, withBlock: { (snapshot2) in
                    if let dictionary = snapshot2.value as? [String: AnyObject] {
                        let comment = Comment()
                        comment.setCommentWithDictionary(dictionary, commentId: snapshot2.key, type: true)
                        self.comments.append(comment)
                        print("Comments Array2: \(self.comments.count)")
//                        dispatch_group_leave(self.my_group)
//                        dispatch_async(dispatch_get_main_queue(), {
//                            self.tableView.reloadData()
//                        })

                    }
                    dispatch_group_leave(self.my_group)
                    dispatch_group_notify(self.my_group, dispatch_get_main_queue(), {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                    })
                    }, withCancelBlock: nil)
//                dispatch_group_notify(self.my_group, dispatch_get_main_queue(), {
////                    dispatch_async(dispatch_get_main_queue(), {
////                        self.tableView.reloadData()
////                    })
//                })
            }
            }, withCancelBlock: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count + 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("threadCell", forIndexPath: indexPath) as! ThreadPostTableViewCell
            // Configure the cell...
            tableView.rowHeight = 264
            cell.postTitleLabel?.text = post.title!
            cell.nameLabel?.text = post.owner!
            let timeStampDate = NSDate(timeIntervalSince1970: post.timeStamp!.doubleValue)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "h:mm a MM/dd/yy"
            cell.timeStampLabel?.text = dateFormatter.stringFromDate(timeStampDate)
            cell.descriptionLabel?.text = post.description!
            let url = NSURL(string: post.profileImage!)
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                if (error != nil) {
                    print(error)
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    cell.userImage?.image = UIImage(data: data!)
                })
            }).resume()
            return cell
        }
        else if(comments[indexPath.row - 1].commentType == false){
            print("Getting cell, count = \(comments.count)")
            let cell = tableView.dequeueReusableCellWithIdentifier("commentId", forIndexPath: indexPath) as! CommentCell
            tableView.rowHeight = 150
            let comment = comments[indexPath.row - 1]
            let url = NSURL(string: comment.profileImage!)
            let timeStampDate = NSDate(timeIntervalSince1970: comment.timeStamp!.doubleValue)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "h:mm a MM/dd/yy"
            cell.timeStamp?.text = dateFormatter.stringFromDate(timeStampDate)
            
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                if (error != nil) {
                    print(error)
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    cell.profileImage?.image = UIImage(data: data!)
                })
            }).resume()
            cell.replyButton.tag = indexPath.row - 1
            cell.nameLabel?.text = comment.user!
            cell.commentLabel?.text = comment.comment!
            return cell
        } else {
            
            
            let cell = tableView.dequeueReusableCellWithIdentifier("subCommentId", forIndexPath: indexPath) as! SubCommentCell
            tableView.rowHeight = 150
            let comment = comments[indexPath.row - 1]
            let url = NSURL(string: comment.profileImage!)
            let timeStampDate = NSDate(timeIntervalSince1970: comment.timeStamp!.doubleValue)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "h:mm a MM/dd/yy"
            cell.timeStamp?.text = dateFormatter.stringFromDate(timeStampDate)
            
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                if (error != nil) {
                    print(error)
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    cell.imageProfile?.image = UIImage(data: data!)
                })
            }).resume()
            cell.nameLabel?.text = comment.user!
            cell.commentLabel?.text = comment.comment!
            return cell

        }
    }
 
    func back(sender: UIBarButtonItem) {
        performSegueWithIdentifier("backToBoard", sender: sender)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let index = sender!.tag
        if (segue.identifier == "writeCommentSegue") {
            let destination = segue.destinationViewController as? WriteCommentViewController
            destination?.post = post
            destination?.nested = false
        }
        
        if (segue.identifier == "nestedCommentSegue") {
            let destination = segue.destinationViewController as? WriteCommentViewController
            destination?.post = post
            destination?.nested = true
            destination?.commentId = comments[index].commentId!
        }
    }
 

}
