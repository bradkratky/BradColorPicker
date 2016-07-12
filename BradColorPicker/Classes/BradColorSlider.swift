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
    
    var setting:BradColorSetting = .GREEN;
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        self.layer.cornerRadius = BRAD_CORNER_RADIUS;
        self.clipsToBounds = true;
        self.contentMode = .Redraw;
    }
    
    func setValue(){
        switch setting {
        case .RED:
            value = rgb.r;
            break;
        case .GREEN:
            value = rgb.g;
            break;
        case .BLUE:
            value = rgb.b;
            break;
        case .HUE:
            value = hsv.h;
            break;
        case .SATURATION:
            value = hsv.s;
            break;
        case .VALUE:
            value = hsv.v;
            break;
        case .ALPHA:
            value = a;
            break;
        }
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event);
        
        self.handleTouch(touch);
        
        return true;
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event);
        
        self.handleTouch(touch);
        
        return true;
    }
    
    func handleTouch(touch: UITouch){
        self.value = touch.locationInView(self).x / self.bounds.width;
        
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged);
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect);
        
        var colors:[CGFloat] = [];
        var colorLocations:[CGFloat] = [0.0, 1.0];
        
        var num:Int = 2;
        
        // updates the background gradient to reflect the current rgb/hsv values
        switch setting {
        case .RED:
            colors = [0, rgb.g, rgb.b, 1, 1, rgb.g, rgb.b, 1];
            break;
        case .GREEN:
            colors = [rgb.r, 0, rgb.b, 1, rgb.r, 1, rgb.b, 1];
            break;
        case .BLUE:
            colors = [rgb.r, rgb.g, 0, 1, rgb.r, rgb.g, 1, 1];
            break;
        case .HUE:
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
        case .SATURATION:
            let start:RGB = HSVtoRGB(h: hsv.h, s: 0, v: hsv.v);
            let end:RGB = HSVtoRGB(h: hsv.h, s: 1, v: hsv.v);
            colors = [start.r, start.g, start.b, 1, end.r, end.g, end.b, 1];
            break;
        case .VALUE:
            let start:RGB = HSVtoRGB(h: hsv.h, s: hsv.s, v: 0);
            let end:RGB = HSVtoRGB(h: hsv.h, s: hsv.s, v: 1);
            colors = [start.r, start.g, start.b, 1, end.r, end.g, end.b, 1];
            break;
        case .ALPHA:
            let start:RGB = HSVtoRGB(h: hsv.h, s: 0, v: hsv.v);
            let end:RGB = HSVtoRGB(h: hsv.h, s: 1, v: hsv.v);
            colors = [start.r, start.g, start.b, 0, end.r, end.g, end.b, 1];
            break;
        }
        
        let context = UIGraphicsGetCurrentContext();
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        let gradient = CGGradientCreateWithColorComponents(colorSpace, colors, colorLocations, num);
        let startPt = CGPoint(x: 0, y: 0);
        let endPt = CGPoint(x: rect.width, y: 0);
        
        // draw checkered background
        if setting == .ALPHA {
            drawAlphaBackground(context, rect: rect);
        }
        
        // draw gradient
        CGContextDrawLinearGradient(context, gradient, startPt, endPt, CGGradientDrawingOptions.init(rawValue: 0));
        
        // draw indicator position
        UIColor(white: 0.0, alpha: 1.0).set();
        CGContextStrokeEllipseInRect(context, CGRectMake(value * rect.width - BRAD_INDICATOR_WIDTH/2, rect.height / 2 - BRAD_INDICATOR_WIDTH/2, BRAD_INDICATOR_WIDTH, BRAD_INDICATOR_WIDTH));
        UIColor(white: 1.0, alpha: 1.0).set();
        CGContextStrokeEllipseInRect(context, CGRectMake(value * rect.width - (BRAD_INDICATOR_WIDTH-1)/2, rect.height / 2 - (BRAD_INDICATOR_WIDTH-1)/2, (BRAD_INDICATOR_WIDTH-1), (BRAD_INDICATOR_WIDTH-1)));
    }
}
