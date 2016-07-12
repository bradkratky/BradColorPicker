//
//  BradColorDisplay.swift
//  BradColorPicker
//
//  Created by Brad on 2016-07-03.
//  Copyright © 2016 braddev. All rights reserved.
//
//  UIView which displays the final selected color.
//  Stores this value in color and checkers the backgroun
//  if a transparent or translucent color is selected.

import UIKit

class BradColorDisplay:UIView{
    
    var color:UIColor = UIColor.whiteColor(){
        didSet{
            setNeedsDisplay();
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.clipsToBounds = true;
        self.layer.cornerRadius = BRAD_CORNER_RADIUS;
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        self.clipsToBounds = true;
        self.layer.cornerRadius = BRAD_CORNER_RADIUS;
        self.layer.borderColor = UIColor.lightGrayColor().CGColor;
        self.layer.borderWidth = 0.5;
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect);
        
        let context = UIGraphicsGetCurrentContext();
        
        // draw position
        if CGColorGetAlpha(self.color.CGColor) < 1 {
            drawAlphaBackground(context, rect: rect);
        }
        
        UIColor.whiteColor().set();
        CGContextStrokeRectWithWidth(context, rect, 2);
        
        UIColor.blackColor().set();
        CGContextStrokeRect(context, rect);
        
        color.set();
        CGContextFillRect(context, rect);
    }
}
