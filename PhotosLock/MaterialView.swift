//
//  MaterialView.swift
//  PhotosLock
//
//  Created by Lalit on 2016-02-06.
//  Copyright © 2016 Bagga. All rights reserved.
//

import UIKit

class MaterialView: UITextField {

    override func awakeFromNib() {
        layer.cornerRadius = 20.0
        layer.shadowColor = UIColor(red: SHADOW_COLOUR, green: SHADOW_COLOUR, blue: SHADOW_COLOUR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
        
    }
}
