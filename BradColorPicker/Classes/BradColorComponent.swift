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
    func colorComponentChanged(_ sender: BradColorComponent);
}

class BradColorComponent: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var slider: BradColorSlider!
    
    @IBOutlet weak var decrement: UIButton!
    @IBOutlet weak var increment: UIButton!

    
    weak var delegate:BradColorComponentDelegate?;
    var setting:BradColorSetting = .red;
    var value:Int = 0;
    var rgb:RGB = RGB(0,0,0) {
        didSet{
            
            switch setting {
            case .red:
                updateValues(colorCGFloatToInt(rgb.r));
                break;
            case .green:
                updateValues(colorCGFloatToInt(rgb.g));
                break;
            case .blue:
                updateValues(colorCGFloatToInt(rgb.b));
                break;
            case .hue:
                break;
            case .saturation:
                break;
            case .value:
                break;
            case .alpha:
                break;
            }
        }
    };
    var hsv:HSV = HSV(0,0,0) {
        didSet{
            switch setting {
            case .red:
                break;
            case .green:
                break;
            case .blue:
                break;
            case .hue:
                updateValues(colorCGFloatToInt(hsv.h));
                break;
            case .saturation:
                updateValues(colorCGFloatToInt(hsv.s));
                break;
            case .value:
                updateValues(colorCGFloatToInt(hsv.v));
                break;
            case .alpha:
                break;
            }
        }
    };
    var a:CGFloat = 0{
        didSet{
            if setting == .alpha {
                updateValues(colorCGFloatToInt(a));
            }
        }
    }
    
    convenience init(){
        self.init(nibName: "BradColorComponent", bundle: Bundle(for: BradColorComponent.classForCoder()));
    }
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
        self.textField.addTarget(self, action: #selector(textFieldChanged), for: UIControlEvents.editingChanged);
        self.slider.addTarget(self, action: #selector(sliderChanged), for: UIControlEvents.valueChanged);
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
    
    func colorCGFloatToInt(_ colorValue:CGFloat) -> Int{
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

    func textFieldChanged(_ sender:UITextField){
        
        if let value:Int = Int(sender.text!) {
            setColorValue(Int(min(colorRange(setting).max, max(colorRange(setting).min, CGFloat(value)))));
        }else{
            setColorValue(0);
        }
    }
    
    func sliderChanged(_ sender:BradColorSlider){
        setColorValue(colorCGFloatToInt(sender.value));
    }
    
    @IBAction func incrementPressed(_ sender: UIButton) {
        value += 1;
        setColorValue(value);
    }
    
    @IBAction func decrementPressed(_ sender: UIButton) {
        value -= 1;
        setColorValue(value);
    }
    
    
    // value set from component (NOT from wheel)
    func setColorValue(_ value:Int){
        
        let fvalue = CGFloat(value) / colorRange(setting).max;
        
        switch setting {
        case .red:
            rgb.r = fvalue;
            hsv = RGBtoHSV(rgb, oldHSV: hsv);
            break;
        case .green:
            rgb.g = fvalue;
            hsv = RGBtoHSV(rgb, oldHSV: hsv);
            break;
        case .blue:
            rgb.b = fvalue;
            hsv = RGBtoHSV(rgb, oldHSV: hsv);
            break;
        case .hue:
            hsv.h = fvalue;
            rgb = HSVtoRGB(h: hsv.h, s: hsv.s, v: hsv.v);
            break;
        case .saturation:
            hsv.s = fvalue;
            rgb = HSVtoRGB(h: hsv.h, s: hsv.s, v: hsv.v);
            break;
        case .value:
            hsv.v = fvalue;
            rgb = HSVtoRGB(h: hsv.h, s: hsv.s, v: hsv.v);
            break;
        case .alpha:
            a = fvalue;
            break;
        }
        self.delegate?.colorComponentChanged(self);
        updateValues(value);
    }
    
    // update subviews with rgb, hsv values
    func updateValues(_ value:Int){
        
        self.value = value;
        
        if(self.value <= Int(colorRange(setting).min)){
            self.value = Int(colorRange(setting).min);
            decrement.isEnabled = false;
            increment.isEnabled = true;
        }else if(value >= Int(colorRange(setting).max)){
            self.value = Int(colorRange(setting).max);
            increment.isEnabled = false;
            decrement.isEnabled = true;
        }else{
            increment.isEnabled = true;
            decrement.isEnabled = true;
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newString = textField.text! as NSString;
        newString = newString.replacingCharacters(in: range, with: string) as NSString;
        
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
