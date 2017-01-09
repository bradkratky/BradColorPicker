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
    
    @IBAction func btnLaunchPressed(_ sender: AnyObject) {
        
        let picker:BradColorPicker = BradColorPicker(delegate: self); // init with white
        //let picker:BradColorPicker = BradColorPicker(delegate: self, r:0.5, g:0, b:0.5, a:1);
        //let picker:BradColorPicker = BradColorPicker(delegate: self, color: UIColor.greenColor());
        self.present(picker, animated: true, completion: {});
    }
    
    // MARK: BradColorPickerDelegate
    func bradColorPicked(_ color: UIColor) {
        colorDisplay.backgroundColor = color;
    }
}

