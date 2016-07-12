//
//  BradColorComponent.swift
//  BradColorPicker
//
//  Created by Brad on 2016-06-30.
//  Copyright © 2016 braddev. All rights reserved.
//
//  UIViewController contained in UIContainerView.
//  Controls a color component through text or slider
//  and can be altered with a custom stepper.

import UIKit

protocol BradColorComponentDelegate : class {
    func colorComponentChanged(sender: BradColorComponent);
}

class BradColorComponent: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var slider: BradColorSlider!
    
    @IBOutlet weak var decrement: UIButton!
    @IBOutlet weak var increment: UIButton!

    
    weak var delegate:BradColorComponentDelegate?;
    var setting:BradColorSetting = .RED;
    var value:Int = 0;
    var rgb:RGB = RGB(0,0,0) {
        didSet{
            
            switch setting {
            case .RED:
                updateValues(colorCGFloatToInt(rgb.r));
                break;
            case .GREEN:
                updateValues(colorCGFloatToInt(rgb.g));
                break;
            case .BLUE:
                updateValues(colorCGFloatToInt(rgb.b));
                break;
            case .HUE:
                break;
            case .SATURATION:
                break;
            case .VALUE:
                break;
            case .ALPHA:
                break;
            }
        }
    };
    var hsv:HSV = HSV(0,0,0) {
        didSet{
            switch setting {
            case .RED:
                break;
            case .GREEN:
                break;
            case .BLUE:
                break;
            case .HUE:
                updateValues(colorCGFloatToInt(hsv.h));
                break;
            case .SATURATION:
                updateValues(colorCGFloatToInt(hsv.s));
                break;
            case .VALUE:
                updateValues(colorCGFloatToInt(hsv.v));
                break;
            case .ALPHA:
                break;
            }
        }
    };
    var a:CGFloat = 0{
        didSet{
            if setting == .ALPHA {
                updateValues(colorCGFloatToInt(a));
            }
        }
    }
    
    convenience init(){
        self.init(nibName: "BradColorComponent", bundle: NSBundle(forClass: BradColorComponent.classForCoder()));
    }
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.label.text = "\(setting.rawValue):";
        self.slider.setting = self.setting;
        
        self.textField.delegate = self;
        self.textField.addTarget(self, action: #selector(textFieldChanged), forControlEvents: UIControlEvents.EditingChanged);
        self.slider.addTarget(self, action: #selector(sliderChanged), forControlEvents: UIControlEvents.ValueChanged);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func colorCGFloatToInt(colorValue:CGFloat) -> Int{
        var value = colorValue;
        
        // smooth out display for values very close to 1 and 0
        // necessary when moving the wheel selection on the outside - s flickers between 99 and 100
        if(value > (1 - 1.0 / colorRange(setting).max)){
            value = ceil(value * colorRange(setting).max) / colorRange(setting).max;
        }else if(value < (1.0 / colorRange(setting).max)){
            value = floor(value * colorRange(setting).max) / colorRange(setting).max;
        }
        return Int(min(colorRange(setting).max, max(colorRange(setting).min, CGFloat(colorRange(setting).max * value))));
    }

    func textFieldChanged(sender:UITextField){
        
        if let value:Int = Int(sender.text!) {
            setColorValue(Int(min(colorRange(setting).max, max(colorRange(setting).min, CGFloat(value)))));
        }else{
            setColorValue(0);
        }
    }
    
    func sliderChanged(sender:BradColorSlider){
        setColorValue(colorCGFloatToInt(sender.value));
    }
    
    @IBAction func incrementPressed(sender: UIButton) {
        value += 1;
        setColorValue(value);
    }
    
    @IBAction func decrementPressed(sender: UIButton) {
        value -= 1;
        setColorValue(value);
    }
    
    
    // value set from component (NOT from wheel)
    func setColorValue(value:Int){
        
        let fvalue = CGFloat(value) / colorRange(setting).max;
        
        switch setting {
        case .RED:
            rgb.r = fvalue;
            hsv = RGBtoHSV(rgb, oldHSV: hsv);
            break;
        case .GREEN:
            rgb.g = fvalue;
            hsv = RGBtoHSV(rgb, oldHSV: hsv);
            break;
        case .BLUE:
            rgb.b = fvalue;
            hsv = RGBtoHSV(rgb, oldHSV: hsv);
            break;
        case .HUE:
            hsv.h = fvalue;
            rgb = HSVtoRGB(h: hsv.h, s: hsv.s, v: hsv.v);
            break;
        case .SATURATION:
            hsv.s = fvalue;
            rgb = HSVtoRGB(h: hsv.h, s: hsv.s, v: hsv.v);
            break;
        case .VALUE:
            hsv.v = fvalue;
            rgb = HSVtoRGB(h: hsv.h, s: hsv.s, v: hsv.v);
            break;
        case .ALPHA:
            a = fvalue;
            break;
        }
        self.delegate?.colorComponentChanged(self);
        updateValues(value);
    }
    
    // update subviews with rgb, hsv values
    func updateValues(value:Int){
        
        self.value = value;
        
        if(self.value <= Int(colorRange(setting).min)){
            self.value = Int(colorRange(setting).min);
            decrement.enabled = false;
            increment.enabled = true;
        }else if(value >= Int(colorRange(setting).max)){
            self.value = Int(colorRange(setting).max);
            increment.enabled = false;
            decrement.enabled = true;
        }else{
            increment.enabled = true;
            decrement.enabled = true;
        }
        
        let fvalue = CGFloat(self.value) / colorRange(setting).max;
        
        self.textField.text = "\(self.value)";
        self.slider.value = fvalue;
        self.slider.rgb = rgb;
        self.slider.hsv = hsv;
        self.slider.a = a;
        
        //self.stepper.value = Double(value);
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newString = textField.text! as NSString;
        newString = newString.stringByReplacingCharactersInRange(range, withString: string);
        
        // allow zero characters if they want to clear and re-input everything
        if(newString.length == 0){
            return true;
            
        // limit to 3 char
        }else if(newString.length > 3){
            return false;
        }
        
        // only allow input if text remains a valid hex int
        if let newValue = Int(newString as String) {
            if(newValue < Int(colorRange(setting).min)){
                textField.text = String(Int(colorRange(setting).min));
                textFieldChanged(textField);
                return false;
            }else if(newValue > Int(colorRange(setting).max)){
                textField.text = String(Int(colorRange(setting).max));
                textFieldChanged(textField);
                return false;
            }
            return true;
        }else{
            return false;
        }
    }
    
}
