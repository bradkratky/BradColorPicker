//
//  File.swift
//  BradColorPicker
//
//  Created by Brad on 2016-07-03.
//  Copyright © 2016 braddev. All rights reserved.
//

import UIKit

class BradColorButton: UIButton {
    
    
    let bkrdNormal:UIColor = UIColor.white;
    let bkrdSelected:UIColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1);
    
    override var isEnabled:Bool{
        didSet{
            if isEnabled {
                backgroundColor = bkrdNormal;
            }else{
                backgroundColor = bkrdSelected;
            }
        }
    }
    
    override var isHighlighted:Bool{
        didSet{
            if isEnabled {
                if isHighlighted {
                    backgroundColor = bkrdSelected;
                }else{
                    backgroundColor = bkrdNormal;
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.setup();
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        self.setup();
    }
    
    func setup(){
        self.layer.cornerRadius = BRAD_CORNER_RADIUS;
        self.layer.borderColor = UIColor.lightGray.cgColor;
        self.layer.borderWidth = 0.5;
        
        self.setTitleColor(UIColor.black, for: UIControlState());
        self.setTitleColor(bkrdNormal, for: UIControlState.highlighted);

    }

    
    
}
