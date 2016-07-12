//
//  BradColorPicker.swift
//  BradColorPicker
//
//  Created by Brad on 2016-06-29.
//  Copyright © 2016 braddev. All rights reserved.
//

import UIKit

public protocol BradColorPickerDelegate : class {
    func bradColorPicked(color:UIColor);
}

public class BradColorPicker : UIViewController, BradColorComponentDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var displayColor: BradColorDisplay!
    @IBOutlet weak var colorPicker: BradColorWheel!
    @IBOutlet weak var hexField: UITextField!
    
    @IBOutlet var containers: [UIView]!
    
    public weak var delegate:BradColorPickerDelegate?;
    
    var a:CGFloat = 1;
    var rgb:RGB = RGB(1,1,1);
    var hsv:HSV = HSV(0,0,1);
    
    var components:[BradColorComponent] = [];
    
    convenience init(){
        self.init(nibName: "BradColorPicker", bundle: NSBundle(forClass: BradColorPicker.classForCoder()));
    }
    
    public convenience init(delegate:BradColorPickerDelegate){
        self.init();
        self.delegate = delegate;
    }
    
    required override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        for (index, container) in containers.enumerate() {
            let component = BradColorComponent();
            switch index {
            case 0:
                component.setting = .RED;
                break;
            case 1:
                component.setting = .GREEN;
                break;
            case 2:
                component.setting = .BLUE;
                break;
            case 3:
                component.setting = .HUE;
                break;
            case 4:
                component.setting = .SATURATION;
                break;
            case 5:
                component.setting = .VALUE;
                break;
            case 6:
                component.setting = .ALPHA;
                break;
            default:
                continue;
            }
            component.delegate = self;
            component.view.frame = CGRectMake(0, 0, container.frame.size.width, container.frame.size.height);
            self .addChildViewController(component);
            container .addSubview(component.view);
            component .didMoveToParentViewController(self);
            components.append(component);
        }
        
        // can use #selector(colorPicked:) in swift 2.2
        self.colorPicker.addTarget(self, action: #selector(colorPicked), forControlEvents: UIControlEvents.ValueChanged);
        self.hexField.addTarget(self, action: #selector(hexChanged), forControlEvents: UIControlEvents.EditingChanged);
        self.hexField.delegate = self;
        
        updateHex();
        updateColor();
        
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Sets the textfield hex based on self.rgb and self.a
    func updateHex(){
        
        
        let alphahex = Int(a*255);
        let hex = Int(rgb.r*255)*256*256 + Int(rgb.g*255)*256 + Int(rgb.b*255);
        
        hexField.text = String(format: "%02X%06X", alphahex, hex);
    }
    
    // updates the color wheel indicator position
    // the color wheel color does not change so it is always clear the v = 1 color being chosen
    func updateWheel(){
        // updating v necessary for the RETURN color, will not change the wheel
        self.colorPicker.v = hsv.v;
        self.colorPicker.xyFromColor(hsv);
    }
    
    // updates the color components, slider positions and display color
    func updateColor (){
        for component:BradColorComponent in components{
            component.rgb = self.rgb;
            component.hsv = self.hsv;
            component.a = self.a;
        }
        self.displayColor.color = UIColor.init(colorLiteralRed: Float(rgb.r), green: Float(rgb.g), blue: Float(rgb.b), alpha: Float(a));
    }
    
    
    @IBAction func donePressed(sender: BradColorButton) {
        self.delegate?.bradColorPicked(self.displayColor.color);
        self.dismissViewControllerAnimated(true, completion: nil);
    }

    // MARK: ControlEvents
    
    // color wheel value changed event
    // - update hex and components
    func colorPicked(wheel: BradColorWheel) {
        rgb = wheel.rgb;
        hsv = RGBtoHSV(rgb, oldHSV: hsv);
        
        updateHex();
        updateColor();
    }
    
    // text field value changed event
    // - update wheel and components
    func hexChanged(field: UITextField){
        
        if let hex = UInt64(field.text!, radix:16) {
            
            // separate components of hex int
            a = ((CGFloat(hex) / 256 / 256 / 256) % 256) / 255;
            rgb.r = ((CGFloat(hex) / 256 / 256) % 256) / 255;
            rgb.g = ((CGFloat(hex) / 256) % 256) / 255;
            rgb.b = (CGFloat(hex) % 256) / 255;
            
            hsv = RGBtoHSV(rgb, oldHSV: hsv);
            
            updateWheel();
            updateColor();
            
        }else{
            // not a valid hex code
        }
        
    }
    
    // MARK: UITextFieldDelegate
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newString = textField.text! as NSString;
        newString = newString.stringByReplacingCharactersInRange(range, withString: string);
        
        // allow zero characters if they want to clear and re-input everything
        if(newString.length == 0){
            return true;
            
        // limit to 8 char
        }else if(newString.length > 8){
            return false;
        }
        
        // only allow input if text remains a valid hex int
        if let _ = UInt64(newString as String, radix:16) {
            return true;
        }else{
            return false;
        }
    }
    
    // MARK: BradColorComponentDelegate
    
    // color component changed
    // - update other components, wheel and display color
    func colorComponentChanged(sender: BradColorComponent) {
        self.rgb = sender.rgb;
        self.hsv = sender.hsv;
        self.a = sender.a;
        updateWheel();
        updateHex();
        updateColor();
    }
}