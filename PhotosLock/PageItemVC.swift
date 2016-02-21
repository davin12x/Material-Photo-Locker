//
//  PageItemVC.swift
//  PhotosLock
//
//  Created by Lalit on 2016-02-19.
//  Copyright © 2016 Bagga. All rights reserved.
//

import UIKit
import ImageSlideshow

class PageItemVC: UIViewController,UIScrollViewDelegate {
     var imgOne = UIImageView?()
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var pageControl: UIPageControl!
    var itemIndex: Int = 0
    var imageViews:UIImageView!
    var photoinarray = [Photos]()
    var indexPathOfSelectedImage : [Int]?
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
//        scrollView.clipsToBounds = true
//        self.scrollView.backgroundColor = UIColor.blackColor()
//        //1
//        self.scrollView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
//        let scrollViewWidth:CGFloat = self.scrollView.frame.width
//        let scrollViewHeight:CGFloat = self.scrollView.frame.height/2
//        var photos = photoinarray.count
//        for var i = 0 ; i < photoinarray.count; ++i {
//            
//            imgOne = UIImageView(frame: CGRectMake((CGFloat(i) * scrollViewWidth), self.view.frame.height/3.0,scrollViewWidth, scrollViewHeight))
//            imgOne!.image = photoinarray[i].getImage()
//            self.scrollView.addSubview(imgOne!)
//            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width * CGFloat(photos), self.scrollView.frame.height)
//        }
//        scrollView.setContentOffset(CGPoint(x: scrollViewWidth * CGFloat(indexPathOfSelectedImage![0]), y:(scrollViewHeight/9)+2), animated: true)
//        self.scrollView.delegate = self
//        self.pageControl.currentPage = 0
        
    }
    

}
