//
//  showCell.swift
//  PhotosLock
//
//  Created by Lalit on 2016-02-08.
//  Copyright © 2016 Bagga. All rights reserved.
//

import UIKit

class showCell: UICollectionViewCell {
    @IBOutlet weak var photoImage: UIImageView!
    
    
    func configureCell(photo:Photos){
       photoImage.image = photo.getImage()
        
         
    }
    
    
}
