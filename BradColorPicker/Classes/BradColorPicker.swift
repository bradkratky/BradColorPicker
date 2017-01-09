//
//  BradColorPicker.swift
//  BradColorPicker
//
//  Created by Brad on 2016-06-29.
//  Copyright © 2016 braddev. All rights reserved.
//

import UIKit

public protocol BradColorPickerDelegate : class {
    func bradColorPicked(_ color:UIColor);
}

open class BradColorPicker : UIViewController, BradColorComponentDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var displayColor: BradColorDisplay!
    @IBOutlet weak var colorPicker: BradColorWheel!
    @IBOutlet weak var hexField: UITextField!
    
    @IBOutlet var containers: [UIView]!
    
    open weak var delegate:BradColorPickerDelegate?;
    
    var a:CGFloat = 1;
    var rgb:RGB = RGB(1,1,1);
    var hsv:HSV = HSV(0,0,1);
    
    var components:[BradColorComponent] = [];
    
    convenience init(){
        self.init(nibName: "BradColorPicker", bundle: Bundle(for: BradColorPicker.classForCoder()));
    }
    
    public convenience init(delegate:BradColorPickerDelegate){
        self.init();
        self.delegate = delegate;
    }
    
    public convenience init(delegate:BradColorPickerDelegate, color:UIColor){
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0;
        color.getRed(&r, green: &g, blue: &b, alpha: &a);
        self.init(delegate: delegate, r:r, g:g, b:b, a:a);
    }
    
    public convenience init(delegate:BradColorPickerDelegate, r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat){
        self.init(delegate: delegate);
        self.rgb = (r, g, b);
        self.a = a;
        self.hsv = RGBtoHSV(rgb, oldHSV: hsv);
    }
    
    required override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        for (index, container) in containers.enumerated() {
            let component = BradColorComponent();
            switch index {
            case 0:
                component.setting = .red;
                break;
            case 1:
                component.setting = .green;
                break;
            case 2:
                component.setting = .blue;
                break;
            case 3:
                component.setting = .hue;
                break;
            case 4:
                component.setting = .saturation;
                break;
            case 5:
                component.setting = .value;
                break;
            case 6:
                component.setting = .alpha;
                break;
            default:
                continue;
            }
            component.delegate = self;
            component.view.frame = CGRect(x: 0, y: 0, width: container.frame.size.width, height: container.frame.size.height);
            self .addChildViewController(component);
            container .addSubview(component.view);
            component .didMove(toParentViewController: self);
            components.append(component);
        }
        
        // can use #selector(colorPicked:) in swift 2.2
        self.colorPicker.addTarget(self, action: #selector(colorPicked), for: UIControlEvents.valueChanged);
        self.hexField.addTarget(self, action: #selector(hexChanged), for: UIControlEvents.editingChanged);
        self.hexField.delegate = self;
        
        updateHex();
        updateWheel();
        updateColor();
    }
    
    override open func didReceiveMemoryWarning() {
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
    
    
    @IBAction func donePressed(_ sender: BradColorButton) {
        self.delegate?.bradColorPicked(self.displayColor.color);
        self.dismiss(animated: true, completion: nil);
    }

    // MARK: ControlEvents
    
    // color wheel value changed event
    // - update hex and components
    func colorPicked(_ wheel: BradColorWheel) {
        rgb = wheel.rgb;
        hsv = RGBtoHSV(rgb, oldHSV: hsv);
        
        updateHex();
        updateColor();
    }
    
    // text field value changed event
    // - update wheel and components
    func hexChanged(_ field: UITextField){
        
        if let hex = UInt64(field.text!, radix:16) {
            
            // separate components of hex int
            a = ((CGFloat(hex) / 256 / 256 / 256).truncatingRemainder(dividingBy: 256)) / 255;
            rgb.r = ((CGFloat(hex) / 256 / 256).truncatingRemainder(dividingBy: 256)) / 255;
            rgb.g = ((CGFloat(hex) / 256).truncatingRemainder(dividingBy: 256)) / 255;
            rgb.b = (CGFloat(hex).truncatingRemainder(dividingBy: 256)) / 255;
            
            hsv = RGBtoHSV(rgb, oldHSV: hsv);
            
            updateWheel();
            updateColor();
            
        }else{
            // not a valid hex code
        }
        
    }
    
    // MARK: UITextFieldDelegate
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newString = textField.text! as NSString;
        newString = newString.replacingCharacters(in: range, with: string) as NSString;
        
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
    func colorComponentChanged(_ sender: BradColorComponent) {
        self.rgb = sender.rgb;
        self.hsv = sender.hsv;
        self.a = sender.a;
        updateWheel();
        updateHex();
        updateColor();
    }
}
