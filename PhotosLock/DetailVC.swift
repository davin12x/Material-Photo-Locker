//
//  DetailVC.swift
//  PhotosLock
//
//  Created by Lalit on 2016-02-08.
//  Copyright © 2016 Bagga. All rights reserved.
//

import UIKit

class DetailVC: UIViewController, UIScrollViewDelegate {
    
    //@IBOutlet weak var imageScrollView :UIScrollView!

    var photo:Photos!
    var photoinarray = [Photos]()
    var indexPathOfSelectedImage : [Int]?
    let width:CGFloat = 375
    let height:CGFloat = 339
    var imageView:UIImageView!
        var pageImages:[UIImage] = [UIImage]()
        var pageViews:[UIView?] = [UIView]()
        var mainScrollView: UIScrollView!
        var pageScrollViews:[UIScrollView?] = [UIScrollView]()
        var currentPageView: UIView!
        var pageControl : UIPageControl = UIPageControl() //frame: CGRectMake(50, 300, 200, 50))
        let viewForZoomTag = 1
        var initOnTouch:Bool = true
        var mainScrollViewContentSize: CGSize!
        
        override func viewDidLoad() {
            
            super.viewDidLoad()
            
            
            mainScrollView = UIScrollView(frame: self.view.bounds)
            mainScrollView.pagingEnabled = true
            mainScrollView.showsHorizontalScrollIndicator = false
            mainScrollView.showsVerticalScrollIndicator = false
            pageScrollViews = [UIScrollView?](count: photoinarray.count, repeatedValue: nil)
            let innerScrollFrame = mainScrollView.bounds
            mainScrollView.contentSize =
                CGSizeMake(innerScrollFrame.origin.x + innerScrollFrame.size.width,
                    mainScrollView.bounds.size.height)
            print(mainScrollView.contentSize)
            
            mainScrollView.backgroundColor = UIColor.blackColor()
            mainScrollView.delegate = self
            self.view.addSubview(mainScrollView)
            configScrollView()
            addPageControlOnScrollView()
            print("\(__FUNCTION__) mainScrollView.contentSize = \(mainScrollView.contentSize)")
            
            
        }
        
        override func viewWillAppear(animated: Bool) {
            loadVisiblePages()
            mainScrollView.setContentOffset(CGPoint(x: mainScrollView.frame.size.width * CGFloat(indexPathOfSelectedImage![0]), y: 12), animated: true)
        }
        
        
        
        func configScrollView() {
            print("\(__FUNCTION__)")
            self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.width * CGFloat(photoinarray.count),
                self.mainScrollView.frame.height)
            mainScrollViewContentSize = mainScrollView.contentSize
            print("fullContentSize=\(mainScrollViewContentSize)")
            print("\(__FUNCTION__) self.scrollView.contentSize \(self.mainScrollView.contentSize)")
        }
        
        
        func addPageControlOnScrollView() {
            
            print("\(__FUNCTION__)")
            self.pageControl.numberOfPages = photoinarray.count
            self.pageControl.currentPage = 0
            self.pageControl.tintColor = UIColor.redColor()
            self.pageControl.pageIndicatorTintColor = UIColor.whiteColor()
            self.pageControl.currentPageIndicatorTintColor = UIColor.greenColor()
            pageControl.addTarget(self, action: Selector("changePage:"), forControlEvents: UIControlEvents.ValueChanged)
            self.pageControl.frame = CGRectMake(0, self.view.frame.maxY - 44, self.view.frame.width, 44)
            self.view.addSubview(pageControl)
        }
        
        
        // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
        func changePage(sender: AnyObject) -> () {
            
            NSLog("\(__FUNCTION__)")
            
            let x = CGFloat(pageControl.currentPage) * mainScrollView.frame.size.width
            mainScrollView.setContentOffset(CGPointMake(x, 0), animated: true)
            loadVisiblePages()
            currentPageView = pageScrollViews[pageControl.currentPage]
            
            
        }
        func getViewAtPage(page: Int) -> UIView! {
            let imageForZooming = UIImageView(image: photoinarray[page].getImage())
    
            var innerScrollFrame = mainScrollView.bounds
            if page < photoinarray.count {
                innerScrollFrame.origin.x = innerScrollFrame.size.width * CGFloat(page)
            }
            imageForZooming.tag = viewForZoomTag
            let pageScrollView = UIScrollView(frame: innerScrollFrame)
            pageScrollView.contentSize = imageForZooming.bounds.size
            pageScrollView.delegate = self
            pageScrollView.showsVerticalScrollIndicator = false
            pageScrollView.showsHorizontalScrollIndicator = false
            pageScrollView.addSubview(imageForZooming)
            return pageScrollView
        }
    
        func setZoomScale(scrollView: UIScrollView) {
            
            let imageView = scrollView.viewWithTag(self.viewForZoomTag)

            let imageViewSize = imageView!.bounds.size
            let scrollViewSize = scrollView.bounds.size
            let widthScale = scrollViewSize.width / imageViewSize.width
            let heightScale = scrollViewSize.height / imageViewSize.height
            
            scrollView.minimumZoomScale = min(widthScale, heightScale)
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
        
        
        func loadVisiblePages() {
            var currentPage :Int
            if initOnTouch == true{
                currentPage = indexPathOfSelectedImage![0]
                initOnTouch = false
            }else{
                currentPage = pageControl.currentPage
            }
            
            
            let previousPage =  currentPage > 0 ? currentPage - 1 : 0
            let nextPage = currentPage + 1 > pageControl.numberOfPages ? currentPage : currentPage + 1
            for page in 0..<previousPage {
                purgePage(page)
            }
            
            for var page = nextPage + 1; page < pageControl.numberOfPages; page = page + 1 {
                purgePage(page)
            }
            
            for var page = previousPage; page <= nextPage; page++ {
                //Initial value is zero
                loadPage(page)
            }
            
        }
        
        
        
        func loadPage(page: Int) {
            
            if page < 0 || page >= pageControl.numberOfPages {
                return
            }
            
            // 1
            if let pageScrollView = pageScrollViews[page] {
                // Do nothing. The view is already loaded.
                
                //            print("\(__FUNCTION__) \(page) existed, call setZoomScale.")
                
                setZoomScale(pageScrollView)
                
            }
            else {
                let pageScrollView = getViewAtPage(page) as! UIScrollView
                setZoomScale(pageScrollView)
                mainScrollView.addSubview(pageScrollView)
                pageScrollViews[page] = pageScrollView
              
            }
            
        }
        
        
        func purgePage(page: Int) {
            
            //        print("\(__FUNCTION__) \(page)")
            
            if page < 0 || page >= pageScrollViews.count {
                
                //            print("\(__FUNCTION__) \(page) abort.")
                
                return
            }
            
            //        print("\(__FUNCTION__) \(page) try...")
            
            if let pageView = pageScrollViews[page] {
                
                //            print("\(__FUNCTION__) \(page) done!")
                
                pageView.removeFromSuperview()
                pageScrollViews[page] = nil
            }
            else {
                
                //            print("\(__FUNCTION__) \(page) nil, ignore.")
                
            }
            
        }
        
        
        func centerScrollViewContents(scrollView: UIScrollView) {
            
            let imageView = scrollView.viewWithTag(self.viewForZoomTag)
            let imageViewSize = imageView!.frame.size
            
            let scrollViewSize = scrollView.bounds.size
            
            let verticalPadding = imageViewSize.height < scrollViewSize.height ?
                (scrollViewSize.height - imageViewSize.height) / 2 : 0
            
            let horizontalPadding = imageViewSize.width < scrollViewSize.width ?
                (scrollViewSize.width - imageViewSize.width) / 2 : 0
            
            scrollView.contentInset = UIEdgeInsets(
                top: verticalPadding,
                left: horizontalPadding,
                bottom: verticalPadding,
                right: horizontalPadding)
        }
        
        
        
        func scrollViewDidZoom(scrollView: UIScrollView) {
            centerScrollViewContents(scrollView)
        }
        
        
        func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
            return scrollView.viewWithTag(viewForZoomTag)
            
            
        }
        func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            print("\(__FUNCTION__)")
        }
        
        func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
            print("\(__FUNCTION__)")
        }
        
        func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
            print("\(__FUNCTION__)")
        }
        
        
        func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            
            print("\(__FUNCTION__)")
            
            let targetOffset = targetContentOffset.memory.x
            print(" TargetOffset: \(targetOffset)")
            
            print(" pageControl.currentPage = \(pageControl.currentPage)")
            print(" scrollView.zoomScale = \(scrollView.zoomScale)")
            print(" scrollView.contentSize = \(scrollView.contentSize)")
            
            print(" scrollView.contentSize.height=\(scrollView.contentSize.height)")
            print(" mainScrollViewContentSize.height=\(mainScrollViewContentSize.height)")
            
            let zoomRatio = scrollView.contentSize.height / mainScrollViewContentSize.height
            
            print(" ratio=\(zoomRatio)")
            
            if zoomRatio == 1 {
                // mainScrollViewController
                
                print("\n mainScrollViewController")
                //        print(scrollView.contentSize.width / targetOffset)
                
                //        print("pageControl.numberOfPages=\(pageControl.numberOfPages)")
                //        print("pageControl.currentPage=\(pageControl.currentPage)")
                
                let mainScrollViewWidthPerPage = mainScrollViewContentSize.width / CGFloat(pageControl.numberOfPages)
                
                print(" mainScrollViewWidthPerPage = \(mainScrollViewWidthPerPage)")
                
                print(" zoomed mainScrollViewWidthPerPage = \(mainScrollViewWidthPerPage * zoomRatio)")
                
                
                let currentPage = targetOffset / (mainScrollViewWidthPerPage * zoomRatio)
                
                print(" currentPage=\(currentPage)")
                
                
                pageControl.currentPage = Int(currentPage)
                
                loadVisiblePages()
                
                
                
            }
            else {
                // pageScorllViewController
                
                print("\n pageScorllViewController")
                
                let mainScrollViewWidthPerPage = mainScrollViewContentSize.width / CGFloat(pageControl.numberOfPages)
                
                print(" mainScrollViewWidthPerPage = \(mainScrollViewWidthPerPage)")
                
                print(" zoomed mainScrollViewWidthPerPage = \(mainScrollViewWidthPerPage * zoomRatio)")
                
                
                let currentPage = targetOffset / (mainScrollViewWidthPerPage * zoomRatio)
                
                print(" currentPage=\(currentPage)")
                
            }
            
            
            
    }

    
}
