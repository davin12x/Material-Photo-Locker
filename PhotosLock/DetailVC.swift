//
//  DetailVC.swift
//  PhotosLock
//
//  Created by Lalit on 2016-02-08.
//  Copyright © 2016 Bagga. All rights reserved.
//

import UIKit
import PhotoSlider

class DetailVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView:UIScrollView!
    var photo:Photos!
    var photoinarray = [Photos]()
    var indexPathOfSelectedImage : [Int]?
    var imageView: UIImageView!
    let width: CGFloat = 375
    let height : CGFloat = 467
    
    override func viewDidLoad() {
        scrollView.delegate = self
        super.viewDidLoad()
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = false
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 2.0
        scrollView.zoomScale = 1.0
        scrollView.flashScrollIndicators()
        let contentOffsetWidth = width * CGFloat(indexPathOfSelectedImage![0])
        let contentOffsetHeight = height * CGFloat(indexPathOfSelectedImage![0])
        
        for var i = 0 ; i < photoinarray.count; ++i {
             imageView = UIImageView(image: photoinarray[i].getImage())
            scrollView.addSubview(imageView)
            imageView.frame = CGRect(x:  (width * CGFloat(i)), y: 33, width: width, height: height)
        }
        scrollView.setContentOffset(CGPoint(x: contentOffsetWidth, y: contentOffsetHeight), animated: true)
        
       scrollView.contentSize = CGSizeMake(width * CGFloat(photoinarray.count), scrollView.frame.size.height)
        view.addSubview(scrollView)
       
    }
   

    
    

    
}
