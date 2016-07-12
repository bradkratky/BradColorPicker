//
//  ViewController.swift
//  BradColorPicker
//
//  Created by brad on 07/08/2016.
//  Copyright (c) 2016 brad. All rights reserved.
//

import UIKit
import BradColorPicker

class ViewController: UIViewController, BradColorPickerDelegate {
    
    @IBOutlet weak var colorDisplay: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnLaunchPressed(sender: AnyObject) {
        
        let picker:BradColorPicker = BradColorPicker(delegate: self);
        self.presentViewController(picker, animated: true, completion: {});
    }
    
    // MARK: BradColorPickerDelegate
    func bradColorPicked(color: UIColor) {
        colorDisplay.backgroundColor = color;
    }
}

