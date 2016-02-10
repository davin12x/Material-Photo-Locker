//
//  DetailVC.swift
//  PhotosLock
//
//  Created by Lalit on 2016-02-08.
//  Copyright © 2016 Bagga. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {

    @IBOutlet weak var imageView:UIImageView!
    var photo:Photos!
    override func viewDidLoad() {
        super.viewDidLoad()
       imageView.image = photo.getImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
}
