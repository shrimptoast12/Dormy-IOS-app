//
//  AddLaundryMachineViewController.swift
//  Dormy
//
//  Created by Tran, Viet Q on 11/8/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class AddLaundryMachineViewController: UIViewController {
    
    var count:Int = 0
    var washerCount:Int = 0
    var dryerCount:Int = 0
    
    @IBOutlet weak var machineSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Function used for when the RA decides to add a new laundry machine
    @IBAction func addMachineAction(sender: AnyObject) {
        var machineName:String = ""
        var machineIcon:String = ""
        var name:String = ""
        
        switch self.machineSegment.selectedSegmentIndex {
        case 0:
            machineName = "Washer"
            machineIcon = "https://firebasestorage.googleapis.com/v0/b/dormy-e6239.appspot.com/o/laundryIcon%2Fwasher.png?alt=media&token=90dba847-9d52-49a5-942b-c1202ac1ce5c"
        case 1:
            machineName = "Dryer"
            machineIcon = "https://firebasestorage.googleapis.com/v0/b/dormy-e6239.appspot.com/o/laundryIcon%2Fdryer.png?alt=media&token=654673cb-811a-42b2-ac9f-ee865325aee6"
        default:
            break;
        }
        
        // grab the machine count and set it to count
        FIRDatabase.database().reference().child("laundry").child("dorm-name").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                var machineCount = dictionary["machine-count"] as? String
                // increment the machine count by 1
                self.count = Int(machineCount!)! + 1
                machineCount = "\(self.count)"
                
                // increment the washer count by 1 if it is a washer
                var washCount = dictionary["washer-count"] as? String
                if (machineName == "Washer") {
                    self.washerCount = Int(washCount!)! + 1
                    washCount = "\(self.washerCount)"
                    name = "Washer \(self.washerCount)"
                }
                
                // increment the dryer count by 1 if it is a dryer
                var dryCount = dictionary["dryer-count"] as? String
                if (machineName == "Dryer") {
                    self.dryerCount = Int(dryCount!)! + 1
                    dryCount = "\(self.dryerCount)"
                    name = "Dryer \(self.dryerCount)"
                }
                
                let uid = FIRAuth.auth()?.currentUser?.uid
                if (uid != nil) {
                    FIRDatabase.database().reference().child("laundry").child("dorm-name").child("machine-count").setValue(machineCount)
                    FIRDatabase.database().reference().child("laundry").child("dorm-name").child("washer-count").setValue(washCount)
                    FIRDatabase.database().reference().child("laundry").child("dorm-name").child("dryer-count").setValue(dryCount)
                }
                // value dictionary that will be used to initalize a laundry machine
                let values = ["name": name,
                    "availibility": "Available",
                    "startTime": "",
                    "endTime": "",
                    "machineType": machineName,
                    "inUseBy": "",
                    "machineIcon": machineIcon]
                
                let ref = FIRDatabase.database().referenceFromURL("https://dormy-e6239.firebaseio.com/")
                let machineNum:String = "Machine \(self.count)"
                let laundryRef = ref.child("laundry").child("dorm-name").child(machineNum)
                laundryRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if err != nil {
                        print(err)
                        return
                    }
                    // else error doesn't occur and we successfully entered user into database
                    // Segues into the app home page
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }
            }, withCancelBlock: nil)
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
