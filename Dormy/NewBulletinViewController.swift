//
//  NewBulletinViewController.swift
//  Dormy
//
//  Created by Benjamin Lee on 12/7/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit


class NewBulletinViewController: UIViewController {
    
    @IBOutlet weak var EventButton: UIButton!
    @IBOutlet weak var QuestionButton: UIButton!
    @IBOutlet weak var AlertButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Sets UI looks for the buttons
        EventButton.layer.cornerRadius = 5
        EventButton.layer.borderWidth = 1
        EventButton.layer.borderColor = UIColor.clearColor().CGColor
        AlertButton.layer.cornerRadius = 5
        AlertButton.layer.borderWidth = 1
        AlertButton.layer.borderColor = UIColor.clearColor().CGColor
        QuestionButton.layer.cornerRadius = 5
        QuestionButton.layer.borderWidth = 1
        QuestionButton.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
