//
//  Photos.swift
//  PhotosLock
//
//  Created by Lalit on 2016-02-08.
//  Copyright © 2016 Bagga. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Photos: NSManagedObject {

    // Insert code here to add functionality to your managed object subclass    func setImage(img:UIImage){
    func setPhotosImage(img:UIImage){
    let data = UIImagePNGRepresentation(img)
    self.photoImage = data
    }
    func getImage()->UIImage{
    let img = UIImage(data: self.photoImage!)
    return img!
}   


}
