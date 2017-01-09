//
//  BradColorSliderControl.swift
//  BradColorPicker
//
//  Created by Brad on 2016-06-30.
//  Copyright © 2016 braddev. All rights reserved.
//
//  Control which shows a color as it is selected
//  using a slider.

import UIKit

class BradColorSlider: UIControl {
    
    var value:CGFloat = 0 {
        didSet{
            setNeedsDisplay();
        }
    };
    var a:CGFloat = 0 {
        didSet{
            setValue();
        }
    }
    
    var rgb:RGB = RGB(0,0,0) {
        didSet{
            setValue();
        }
    }
    var hsv:HSV = HSV(0,0,0){
        didSet{
            setValue();
        }
    }
    
    var setting:BradColorSetting = .green;
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        self.layer.cornerRadius = BRAD_CORNER_RADIUS;
        self.clipsToBounds = true;
        self.contentMode = .redraw;
    }
    
    func setValue(){
        switch setting {
        case .red:
            value = rgb.r;
            break;
        case .green:
            value = rgb.g;
            break;
        case .blue:
            value = rgb.b;
            break;
        case .hue:
            value = hsv.h;
            break;
        case .saturation:
            value = hsv.s;
            break;
        case .value:
            value = hsv.v;
            break;
        case .alpha:
            value = a;
            break;
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event);
        
        self.handleTouch(touch);
        
        return true;
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event);
        
        self.handleTouch(touch);
        
        return true;
    }
    
    func handleTouch(_ touch: UITouch){
        self.value = touch.location(in: self).x / self.bounds.width;
        
        self.sendActions(for: UIControlEvents.valueChanged);
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect);
        
        var colors:[CGFloat] = [];
        var colorLocations:[CGFloat] = [0.0, 1.0];
        
        var num:Int = 2;
        
        // updates the background gradient to reflect the current rgb/hsv values
        switch setting {
        case .red:
            colors = [0, rgb.g, rgb.b, 1, 1, rgb.g, rgb.b, 1];
            break;
        case .green:
            colors = [rgb.r, 0, rgb.b, 1, rgb.r, 1, rgb.b, 1];
            break;
        case .blue:
            colors = [rgb.r, rgb.g, 0, 1, rgb.r, rgb.g, 1, 1];
            break;
        case .hue:
            colorLocations = [0.0, 0.167, 0.333, 0.5, 0.667, 0.833, 1.0];
            num = 7;
            colors = [  1, 0, 0, 1,
                1, 1, 0, 1,
                0, 1, 0, 1,
                0, 1, 1, 1,
                0, 0, 1, 1,
                1, 0, 1, 1,
                1, 0, 0, 1];
            break;
        case .saturation:
            let start:RGB = HSVtoRGB(h: hsv.h, s: 0, v: hsv.v);
            let end:RGB = HSVtoRGB(h: hsv.h, s: 1, v: hsv.v);
            colors = [start.r, start.g, start.b, 1, end.r, end.g, end.b, 1];
            break;
        case .value:
            let start:RGB = HSVtoRGB(h: hsv.h, s: hsv.s, v: 0);
            let end:RGB = HSVtoRGB(h: hsv.h, s: hsv.s, v: 1);
            colors = [start.r, start.g, start.b, 1, end.r, end.g, end.b, 1];
            break;
        case .alpha:
            let start:RGB = HSVtoRGB(h: hsv.h, s: 0, v: hsv.v);
            let end:RGB = HSVtoRGB(h: hsv.h, s: 1, v: hsv.v);
            colors = [start.r, start.g, start.b, 0, end.r, end.g, end.b, 1];
            break;
        }
        
        let context = UIGraphicsGetCurrentContext();
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colors, locations: colorLocations, count: num);
        let startPt = CGPoint(x: 0, y: 0);
        let endPt = CGPoint(x: rect.width, y: 0);
        
        // draw checkered background
        if setting == .alpha {
            drawAlphaBackground(context, rect: rect);
        }
        
        // draw gradient
        context?.drawLinearGradient(gradient!, start: startPt, end: endPt, options: CGGradientDrawingOptions.init(rawValue: 0));
        
        // draw indicator position
        UIColor(white: 0.0, alpha: 1.0).set();
        context?.strokeEllipse(in: CGRect(x: value * rect.width - BRAD_INDICATOR_WIDTH/2, y: rect.height / 2 - BRAD_INDICATOR_WIDTH/2, width: BRAD_INDICATOR_WIDTH, height: BRAD_INDICATOR_WIDTH));
        UIColor(white: 1.0, alpha: 1.0).set();
        context?.strokeEllipse(in: CGRect(x: value * rect.width - (BRAD_INDICATOR_WIDTH-1)/2, y: rect.height / 2 - (BRAD_INDICATOR_WIDTH-1)/2, width: (BRAD_INDICATOR_WIDTH-1), height: (BRAD_INDICATOR_WIDTH-1)));
    }
}
