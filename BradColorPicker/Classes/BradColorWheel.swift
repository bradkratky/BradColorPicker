//
//  BradColorPickerControl.swift
//  BradColorPicker
//
//  Created by Brad on 2016-06-29.
//  Copyright © 2016 braddev. All rights reserved.
//
//  A color palette for selecting colors.  Uses HSV
//  to project the colors, though V is maintained
//  at 1 for rendering the palette.
//
//  The value of this control is the selected color.

import UIKit

struct Pixel {
    var a:UInt8;
    var r:UInt8;
    var g:UInt8;
    var b:UInt8;
}

class BradColorWheel: UIControl {
    
    // palette radius, < self.frame.size.width/2
    var radius:CGFloat = 0;
    
    // indicator position
    var pos = CGPoint.init(x: 0, y: 0);
    var v:CGFloat = 1.0;
    var rgb:RGB = RGB(0,0,0);
    
    var palette:UIImage = UIImage();
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.setup();
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        self.setup();
    }
    
    // the rendered palette has a margin so the indicator circle
    // is not clipped at extremes.
    let BRAD_MARGIN:CGFloat = BRAD_INDICATOR_WIDTH / 2 + 1;
    
    func setup () {
        radius = self.bounds.width/2 - BRAD_MARGIN;
        pos = CGPoint.init(x: frame.size.width/2, y: frame.size.height/2);
        
        palette = paletteImage();
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
    
    func paletteImage() -> UIImage{
        let rect = self.frame;
        
        let w = Int(rect.width);
        let h = Int(rect.height);
        
        let white = Pixel(a: 255, r: 255, g: 255, b: 255);
        var pixelData = [Pixel](count: (w*h), repeatedValue: white);
        
        // set pixels to render the hsv palette
        for i in 0..<h {
            for j in 0..<w {
                let index = j + i * w;
                
                let rgb:RGB = self.colorFromXY(CGFloat(j), y: CGFloat(i), v: 1);
                (pixelData[index].r, pixelData[index].g, pixelData[index].b) = RGBtoUInt8(rgb);
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let provider = CGDataProviderCreateWithCFData(NSData(bytes: &pixelData, length: pixelData.count * sizeof(Pixel)));
        
        let cgimage = CGImageCreate(w, h, 8, 32, w * Int(sizeof(Pixel)), colorSpace, CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue), provider, nil, true, .RenderingIntentDefault);
        var image = UIImage(CGImage: cgimage!);

        // clip image to circle
        let imageRect = CGRectMake(BRAD_MARGIN,BRAD_MARGIN,radius*2, radius*2);
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
        let circleClip = UIBezierPath.init(roundedRect: imageRect, cornerRadius: radius).addClip();
        image.drawInRect(imageRect)
        let clippedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return clippedImage;
    }
    
    // sets the indicator position and retrieves the selected color
    func handleTouch(touch: UITouch){
        pos = touch.locationInView(self);
        
        let x = pos.x - self.bounds.width / 2;
        let y = pos.y - self.bounds.height / 2;
        let hy = x*x+y*y;
        if hy > radius*radius {
            var theta = atan(y / x);
            
            if x == 0 {
                theta = (y > 0) ? CGFloat(M_PI)/2 : 3*CGFloat(M_PI)/2;
            }else if x < 0 {
                theta += CGFloat(M_PI);
            }

            pos.x = (self.bounds.width / 2) + radius * cos(theta);
            pos.y = (self.bounds.width / 2) + radius * sin(theta);
            
        }
        
        
        rgb = self.colorFromXY(pos.x, y: pos.y, v: self.v);
        setNeedsDisplay();
        
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged);
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect);
        
        palette.drawInRect(rect);
        
        let context = UIGraphicsGetCurrentContext();
        // draw indicator position
        UIColor(white: 0.0, alpha: 1.0).set();
        CGContextStrokeEllipseInRect(context, CGRectMake(pos.x - BRAD_INDICATOR_WIDTH/2, pos.y - BRAD_INDICATOR_WIDTH/2, BRAD_INDICATOR_WIDTH, BRAD_INDICATOR_WIDTH));
        UIColor(white: 1.0, alpha: 1.0).set();
        CGContextStrokeEllipseInRect(context, CGRectMake(pos.x - (BRAD_INDICATOR_WIDTH-1)/2, pos.y - (BRAD_INDICATOR_WIDTH-1)/2, (BRAD_INDICATOR_WIDTH-1), (BRAD_INDICATOR_WIDTH-1)));
    }
    
    // returns a color from an x,y position within the palette
    func colorFromXY(x:CGFloat, y:CGFloat, v:CGFloat) -> (RGB) {
        
        let width = self.bounds.width;
        let height = self.bounds.height;
        
        let jj = Double(x) - Double(width) / 2.0;
        let ii = Double(y) - Double(height) / 2.0;
        
        var hue = atan(ii / jj) * 180 / M_PI;
        if(x >= width/2){
            hue += 180;
        }else if(y > height/2){
            hue += 360;
        }
        var s = sqrt(jj*jj + ii*ii) / Double(radius);
        
        if(s > 1){
            s = 1;
        }
        
        hue += 180;
        if(hue >= 360){
            hue -= 360;
        }
        
        hue /= 360;
        
        return HSVtoRGB(h: CGFloat(hue), s: CGFloat(s), v: v);
    }
    
    // updates the indicator position to the coordinate of the given color
    func xyFromColor(hsv:HSV){
        
        let h = Double(hsv.h * 360);
        let s = Double(hsv.s);
        
        let x = Double(self.bounds.width)/2 + Double(radius) * s * cos(h * M_PI / 180);
        let y = Double(self.bounds.height)/2 + Double(radius) * s * sin(h * M_PI / 180);
        
        pos = CGPoint.init(x: x, y: y);
        
        setNeedsDisplay();
    }
   
    
    
}