//
//  LaundryHelperTableViewController.swift
//  Dormy
//
//  Created by Tran, Viet Q on 11/6/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class LaundryHelperTableViewController: UITableViewController {
    
    var machines = [LaundryMachine]()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var addMachine: UIBarButtonItem!
    
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
        
        // If you are an RA, then you will be able to see the machine adding button, else you won't
        self.title = "Laundry Helper"
        self.navigationController?.navigationBar.barTintColor = AppDelegate().RGB(240.0,g: 208.0,b: 138.0)
        let user = FIRAuth.auth()?.currentUser
        let uid = user?.uid
        FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let raFlag = dictionary["RA"] as? String
                self.addMachine.enabled = false
                self.addMachine.tintColor = UIColor.clearColor()
                if (raFlag == "true") {
                    self.addMachine.enabled = true
                    self.addMachine.tintColor = nil
                }
            }
            
            }, withCancelBlock: nil)
        fetchMachine()
    }
    
    // grabs corresponding machines and appends it to a machine array
    func fetchMachine() {
        FIRDatabase.database().reference().child("laundry").child("dorm-name").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let machine = LaundryMachine()
                machine.setValuesForKeysWithDictionary(dictionary)
                self.machines.append(machine)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            }, withCancelBlock: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return machines.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // set the cell as a custom Laundry cell
        let cell = tableView.dequeueReusableCellWithIdentifier("laundryCell", forIndexPath: indexPath) as! LaundryTableViewCell
        cell.laundryIcon?.image = UIImage(named: "dryer")
        cell.freeButton.hidden = true
        // Set up the cell by retrieving data from Firebase and updating the labels
        let machineNum = "Machine \(indexPath.row + 1)"
        FIRDatabase.database().reference().child("laundry").child("dorm-name").child(machineNum).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                if let laundryImageURL = dictionary["machineIcon"] as? String {
                    let url = NSURL(string: laundryImageURL)
                    NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                        if (error != nil) {
                            print(error)
                            return
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.laundryIcon?.image = UIImage(data: data!)
                        })
                    }).resume()
                }
                
                // Set the machine's availability per cell
                let availability = dictionary["availibility"] as? String
                cell.availabilityLabel?.text = availability
                cell.availabilityLabel.textColor = UIColor.greenColor()
                if (availability == "Available") {
                    cell.reserveButton.hidden = false
                    cell.currentUseLabel.hidden = true
                    cell.startTimeLabel.hidden = true
                    cell.endTimeLabel.hidden = true
                    cell.freeButton.hidden = true
                }
                else if (availability == "Unavailable") {
                    cell.reserveButton.hidden = true
                    let inUseBy = dictionary["inUseBy"] as? String
                    let startTime = dictionary["startTime"] as? String
                    let endTime = dictionary["endTime"] as? String
                    
                    // update the labels if the machine is unavailable
                    cell.availabilityLabel?.text = "Unavailable"
                    cell.availabilityLabel.textColor = UIColor.redColor()
                    cell.currentUseLabel?.text = "Currently In Use By: \(inUseBy!)"
                    cell.startTimeLabel?.text = "Start time: \(startTime!)"
                    cell.endTimeLabel?.text = "Approx. Finish: \(endTime!)"
                    cell.currentUseLabel.hidden = false
                    cell.startTimeLabel.hidden = false
                    cell.endTimeLabel.hidden = false
                    
                    // Only show the free button to the user that actually reserved the machine
                    // grab the current user's name
                    let uid = FIRAuth.auth()?.currentUser?.uid
                    var currentUserName = ""
                    FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot2) in
                        if let dictionary = snapshot2.value as? [String: AnyObject] {
                            currentUserName = (dictionary["name"] as? String)!
                            if (currentUserName == inUseBy!) {
                                cell.freeButton.hidden = false
                            }
                        }
                        }, withCancelBlock: nil)
                }
                
                // Set the machine's name label per cell
                let name = dictionary["name"] as? String
                cell.nameLabel?.text = name
            }
            
            }, withCancelBlock: nil)
        
        // Configure the cell...
        // makes the reserveButton show an alert message when pressed
        cell.reserveButton.tag = indexPath.row + 1
        cell.reserveButton.addTarget(self, action: #selector(LaundryHelperTableViewController.showReserveAlert(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        // makes the free button free the laundry machine
        cell.freeButton.tag = indexPath.row + 1
        cell.freeButton.addTarget(self, action: #selector(LaundryHelperTableViewController.freeLaundryMachine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    @IBAction func addMachineAction(sender: AnyObject) {
    }
    
    // Shows an alert to ask if user really wants to reserve the machine
    func showReserveAlert (sender:UIButton!) {
        let machineNum = "Machine \(sender.tag)"
        var currentUserName = ""
        var machineType  = ""
        
        // grabs the current time
        let startTime = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        let calender = NSCalendar.currentCalendar()
        
        // grab the current user's name
        let uid = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                currentUserName = (dictionary["name"] as? String)!
            }
            }, withCancelBlock: nil)
        
        // grabs the machine type the user wants to reserve
        FIRDatabase.database().reference().child("laundry").child("dorm-name").child(machineNum).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                machineType = (dictionary["machineType"] as? String)!
            }
            }, withCancelBlock: nil)
        
        // Alert controller that asks the user if he is 100% sure he wants to reserve the machine
        let alertController = UIAlertController(title: "Important", message: "Are you sure you want to reserve?", preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action:UIAlertAction) in
            FIRDatabase.database().reference().child("laundry").child("dorm-name").child(machineNum).child("inUseBy").setValue(currentUserName)
            FIRDatabase.database().reference().child("laundry").child("dorm-name").child(machineNum).child("startTime").setValue(startTime)
            FIRDatabase.database().reference().child("laundry").child("dorm-name").child(machineNum).child("availibility").setValue("Unavailable")
            if (machineType == "Dryer") {
                let date = calender.dateByAddingUnit(.Hour, value: 1, toDate: NSDate(), options: [])
                let endTime = NSDateFormatter.localizedStringFromDate(date!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                FIRDatabase.database().reference().child("laundry").child("dorm-name").child(machineNum).child("endTime").setValue(endTime)
            }
            else if (machineType == "Washer") {
                let date = calender.dateByAddingUnit(.Minute, value: 30, toDate: NSDate(), options: [])
                let endTime = NSDateFormatter.localizedStringFromDate(date!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                FIRDatabase.database().reference().child("laundry").child("dorm-name").child(machineNum).child("endTime").setValue(endTime)
            }
            self.tableView.reloadData()
        }
        let defaultAction = UIAlertAction(title: "No", style: .Default, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(defaultAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Function used to free a laundry machine if it is in use.
    func freeLaundryMachine (sender: UIButton!) {
        let machineNum = "Machine \(sender.tag)"
        
        let alertController = UIAlertController(title: "Important", message: "Are you sure you want to free this machine?", preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action:UIAlertAction) in
            FIRDatabase.database().reference().child("laundry").child("dorm-name").child(machineNum).child("inUseBy").setValue("")
            FIRDatabase.database().reference().child("laundry").child("dorm-name").child(machineNum).child("startTime").setValue("")
            FIRDatabase.database().reference().child("laundry").child("dorm-name").child(machineNum).child("availibility").setValue("Available")
            FIRDatabase.database().reference().child("laundry").child("dorm-name").child(machineNum).child("endTime").setValue("")
            self.tableView.reloadData()
        }
        let defaultAction = UIAlertAction(title: "No", style: .Default, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(defaultAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
