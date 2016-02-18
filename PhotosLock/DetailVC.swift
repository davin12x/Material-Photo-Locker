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
    @IBOutlet weak var pageControl:UIPageControl?
    var photo:Photos!
    var photoinarray = [Photos]()
    var indexPathOfSelectedImage : [Int]?
    var imageView: UIImageView!
    let width: CGFloat = 375
    let height : CGFloat = 339
    var pageViews: [UIImageView?] = []
    
    override func viewDidLoad() {
        scrollView.delegate = self
        super.viewDidLoad()
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = false
        scrollView.flashScrollIndicators()
        let scrollViewWidth = self.scrollView.frame.width
        let scrollViewHeight = self.scrollView.frame.height
        let contentOffsetWidth = scrollViewWidth * CGFloat(indexPathOfSelectedImage![0])
        let contentOffsetHeight = scrollViewHeight * CGFloat(indexPathOfSelectedImage![0])
        let imageCount = photoinarray.count
        
        pageControl!.currentPage = 0
        pageControl!.numberOfPages = imageCount
        
        for _ in 0..<imageCount {
            pageViews.append(nil)
        }
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(photoinarray.count),
            height: pagesScrollViewSize.height)
        loadVisiblePages()
        
        
//        for var i = 0 ; i < photoinarray.count; ++i {
//            let oneImage = photoinarray[i].getImage()
//             imageView = UIImageView(image: photoinarray[i].getImage())
//            scrollView.addSubview(imageView)
//            //imageView.frame = CGRect(x:(scrollViewWidth * CGFloat(i)), y: 15, width: scrollViewWidth, height: scrollViewHeight)
//            imageView.frame = CGRect(origin: CGPoint(x: scrollViewWidth * CGFloat(i), y: 15), size: oneImage.size)
//            view.addSubview(scrollView)
//            scrollView.contentSize = oneImage.size
//        }
        //scrollView.contentSize = CGSizeMake(scrollViewWidth * CGFloat(photoinarray.count), scrollViewHeight)
        
        scrollView.setContentOffset(CGPoint(x: contentOffsetWidth, y: contentOffsetHeight), animated: true)
        
      
        var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        //4
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleheight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleheight, scaleWidth)
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale;
        //centerScrollViewContents()

    }
    func loadPage(page: Int) {
        if page < 0 || page >= photoinarray.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // 1
        if let pageView = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            // 2
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            // 3
            let newPageView = UIImageView(image: photoinarray[page].getImage())
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
            
            // 4
            pageViews[page] = newPageView
        }
    }
    func purgePage(page: Int) {
        if page < 0 || page >= photoinarray.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
    func loadVisiblePages() {
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl!.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < photoinarray.count; ++index {
            purgePage(index)
        }
    }
//    func centerScrollViewContents() {
//        let boundsSize = scrollView.bounds.size
//        var contentsFrame = imageView.frame
//        
//        if contentsFrame.size.width < boundsSize.width {
//            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
//        } else {
//            contentsFrame.origin.x = 0.0
//        }
//        
//        if contentsFrame.size.height < boundsSize.height {
//            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
//        } else {
//            contentsFrame.origin.y = 0.0
//        }
//        
//        imageView.frame = contentsFrame
//    }
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        // 1
        let pointInView = recognizer.locationInView(imageView)
        
        // 2
        var newZoomScale = scrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
        
        // 3
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        // 4
        scrollView.zoomToRect(rectToZoomTo, animated: true)
    }
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(scrollView: UIScrollView) {
       // centerScrollViewContents()
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        loadVisiblePages()
    }
 
    
    

    
}
