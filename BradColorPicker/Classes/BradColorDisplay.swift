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
    
    var color:UIColor = UIColor.white{
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
        self.layer.borderColor = UIColor.lightGray.cgColor;
        self.layer.borderWidth = 0.5;
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect);
        
        let context = UIGraphicsGetCurrentContext();
        
        // draw position
        if self.color.cgColor.alpha < 1 {
            drawAlphaBackground(context, rect: rect);
        }
        
        UIColor.white.set();
        context?.stroke(rect, width: 2);
        
        UIColor.black.set();
        context?.stroke(rect);
        
        color.set();
        context?.fill(rect);
    }
}
