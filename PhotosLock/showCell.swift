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
        let maxRatio = maxWidth/maxHeight;
        var compressionQuality = CGFloat()
        compressionQuality = 0.5
        
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
        let rect = CGRectMake(0, 0, actualWidth, actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        photo.getImage().drawInRect(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let data = UIImageJPEGRepresentation(img, compressionQuality)!
        UIGraphicsEndImageContext();
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),  {
            // Load image on a non-ui-blocking thread
            
            
            dispatch_sync(dispatch_get_main_queue(), {
                // Assign image back on the main thread
                     self.photoImage.image = UIImage(data: data)
               
                });
            });
        
        
         
    }
    
    
}
