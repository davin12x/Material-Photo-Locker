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
       
        var actualHeight = photo.getImage().size.height;
        var actualWidth = photo.getImage().size.width;
        var maxHeight = CGFloat()
        maxHeight = 200
        var maxWidth = CGFloat()
        maxWidth = 200
        var imgRatio = actualWidth/actualHeight;
        var maxRatio = maxWidth/maxHeight;
        var compressionQuality = CGFloat()//50 percent compression
        compressionQuality = 0.1
        
        if (actualHeight > maxHeight || actualWidth > maxWidth)
        {
            if(imgRatio < maxRatio)
            {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio)
            {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else
            {
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }
        var rect = CGRectMake(0, 0, actualWidth, actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        photo.getImage().drawInRect(rect)
        var img = UIGraphicsGetImageFromCurrentImageContext()
        var data = UIImageJPEGRepresentation(img, compressionQuality)!
        UIGraphicsEndImageContext();
        photoImage.image = UIImage(data: data)
        
         
    }
    
    
}
