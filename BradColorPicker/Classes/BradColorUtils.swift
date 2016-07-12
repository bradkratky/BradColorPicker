//
//  BradColorUtils.swift
//  BradColorPicker
//
//  Created by Brad on 2016-06-30.
//  Copyright © 2016 braddev. All rights reserved.
//

import UIKit

let BRAD_CORNER_RADIUS = CGFloat.init(5);

// indicator circle width for color sliders and wheel
let BRAD_INDICATOR_WIDTH = CGFloat.init(6);

public typealias RGB = (r: CGFloat, g:CGFloat, b:CGFloat);
typealias HSV = (h: CGFloat, s:CGFloat, v:CGFloat);

enum BradColorSetting :Character{
    case RED = "R"
    case GREEN = "G"
    case BLUE = "B"
    case HUE = "H"
    case SATURATION = "S"
    case VALUE = "V"
    case ALPHA = "A"
}

// max ranges for different color components
func colorRange(setting:BradColorSetting) -> (min:CGFloat, max:CGFloat){
    switch setting {
    case .RED: fallthrough
    case .GREEN: fallthrough
    case .BLUE: fallthrough
    case .ALPHA:
        return (0, 255);
    case .HUE:
        return (0, 360);
    case .SATURATION: fallthrough
    case .VALUE:
        return (0, 100);
    }
}

func RGBtoUInt8(rgb:RGB) -> (r:UInt8, g:UInt8, b:UInt8){
    return (CGFloatToUInt8(rgb.r), CGFloatToUInt8(rgb.g), CGFloatToUInt8(rgb.b));
}

func CGFloatToUInt8(float:CGFloat) -> UInt8{
    return UInt8(max(0, min(255, 255 * float)));
}

// size of alpha checkering
let ALPHA_TILE:CGFloat = 8;

// draws a checkered background for displaying tranlucent colors
func drawAlphaBackground(context:CGContext?, rect:CGRect){
    UIColor.lightGrayColor().colorWithAlphaComponent(0.5).set();
    for x in  0...Int(rect.width / ALPHA_TILE) {
        for y in 0...Int(rect.height / ALPHA_TILE) {
            if (x % 2 == 0 && y % 2 == 0) || (x % 2 == 1 && y % 2 == 1){
                CGContextFillRect(context, CGRectMake(CGFloat(x) * ALPHA_TILE, CGFloat(y) * ALPHA_TILE, ALPHA_TILE, ALPHA_TILE))
            }
        }
    }
}

// converts HSV to RGB
func HSVtoRGB(h hue:CGFloat, s:CGFloat, v:CGFloat) -> (RGB) {
    var h = hue;
    
    h *= 360;
    if(h >= 360){
        h -= 360;
    }

    let hprime = h / 60;
    
    var r,g,b:CGFloat;
    
    if(s <= 0){
        r = v;
        g = v;
        b = v;
    }else{
        
        
        let f = hprime - floor(hprime);
        let p = v * (1 - s);
        let q = v * (1 - s * f);
        let t = v * (1 - s * (1 - f));
        
        
        switch(floor(hprime)){
        case 0:
            r = v;
            g = t;
            b = p;
            break;
        case 1:
            r = q;
            g = v;
            b = p;
            break;
        case 2:
            r = p;
            g = v;
            b = t;
            break;
        case 3:
            r = p;
            g = q;
            b = v;
            break;
        case 4:
            r = t;
            g = p;
            b = v;
            break;
        default:
            r = v;
            g = p;
            b = q;
            break;
        }
    }
    
    return RGB(r, g, b);
}

// converts RGB to HSV, returning oldHSV if the hue cannot be determined.
func RGBtoHSV(rgb:RGB, oldHSV:HSV) -> (HSV) {
    var hsv:HSV;
    var cmin:CGFloat;
    var cmax:CGFloat;
    var delta:CGFloat;
    
    cmin = min(rgb.r, min(rgb.g, rgb.b));
    cmax = max(rgb.r, max(rgb.g, rgb.b));
    
    hsv.v = cmax;
    
    delta = cmax - cmin;
    
    if(cmax != 0){
        hsv.s = delta / cmax;
    }else{
        hsv.h = -1;
        hsv.s = 0;
        return hsv;
    }
    
    if(rgb.r == cmax){
        hsv.h = (rgb.g - rgb.b) / delta;
    }else if(rgb.g == cmax){
        hsv.h = 2 + (rgb.b - rgb.r) / delta;
    }else{
        hsv.h = 4 + (rgb.r - rgb.g) / delta;
    }
    
    hsv.h *= 60;
    if(hsv.h < 0){
        hsv.h += 360;
    }
    
    hsv.h /= 360;
    
    if(isnan(hsv.h)){
        return oldHSV;
    }
    
    return hsv;
}

