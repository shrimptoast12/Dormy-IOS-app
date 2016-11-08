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

    @IBOutlet weak var machineSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addMachineAction(sender: AnyObject) {
        var machineName:String = ""
        
        switch self.machineSegment.selectedSegmentIndex {
            case 0:
                machineName = "Washer"
            case 1:
                machineName = "Dryer"
            default:
                break;
        }
        
        let timeString = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        let values = ["name": "",
                      "availibility": "",
                      "startTime": timeString,
                      "endTime": "",
                      "machineType": machineName,
                      "inUseBy": ""]
        
        let ref = FIRDatabase.database().referenceFromURL("https://dormy-e6239.firebaseio.com/")
        //let machineRef = ref.child("laundry").child("dorm-name").child("machine-count")
        let machineNum:String = "Machine"
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
    
//    func updateTime() {
//        let timeString = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
//        print(timeString)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
