//
//  showVC.swift
//  PhotosLock
//
//  Created by Lalit on 2016-02-08.
//  Copyright © 2016 Bagga. All rights reserved.
//

import UIKit
import CoreData
import Photos
import DKImagePickerController
import iAd
import AVFoundation
import SwiftSpinner


class showVC: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate, UINavigationControllerDelegate, ADBannerViewDelegate {
    @IBOutlet weak var collection : UICollectionView!
    let pickerController = DKImagePickerController()
    internal var selectedAssets = [DKAsset]()
    
    @IBOutlet var IADBanner: ADBannerView?
    
    @IBOutlet var storeLabel: UILabel!
    @IBOutlet weak var Activate: UIButton!
    var imagePicker = UIImagePickerController()
    var photos = [Photos]()
    var saveValue = [Int]()
    var clearImageData = 0
    var imageCounter = 0
    var delPhotos = [UIImage]()
    var importButton = Bool()
    var indexPathOfSelectedImage : [Int]?
    var selectedItems = Bool()
    var sfxTrash :AVAudioPlayer!
    var sfxSelect:AVAudioPlayer!
    var sfxEdit:AVAudioPlayer!
    var sfxAdd:AVAudioPlayer!
    var orignalImages :[UIImage] = []
    var isImageSaved = false
    var phasset = PHAsset()
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    @IBOutlet weak var trashButton: UIButton!
    
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet weak var exportButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.canDisplayBannerAds = true
        self.IADBanner?.delegate = self
        self.IADBanner?.hidden = true
        collection.allowsMultipleSelection = true
        collection.delegate = self
        collection.dataSource = self
        imagePicker.delegate = self
        trashButton.hidden = true
        trashButton.center.x = self.view.frame.width + 30
        pickerController.assetType = .AllPhotos
        pickerController.maxSelectableCount = 6
        fetchAndSetResult()
        toolBar.hidden = true
        
        screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        let layout: UICollectionViewFlowLayout = collection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3.1, height: screenWidth/3.2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
       
     

        
        do{
            try sfxTrash = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("delete", ofType: "wav")!))
            try sfxEdit = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("click", ofType: "mp3")!))
            try sfxAdd = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("AddButton", ofType: "wav")!))
            try sfxSelect = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("select", ofType: "wav")!))
            
            sfxEdit.prepareToPlay()
            sfxTrash.prepareToPlay()
            sfxAdd.prepareToPlay()
            sfxSelect.prepareToPlay()
            
        }catch let err as NSError{
            print(err)
        }
    
        
    }
    override func viewDidAppear(animated: Bool) {
        fetchAndSetResult()
    }
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        IADBanner?.hidden = false
        
    }
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        IADBanner?.hidden = true
    }
    
    func fetchAndSetResult(){
       let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Photos")
        do{
            let result = try context.executeFetchRequest(fetchRequest)
            self.photos = result as! [Photos]
            
            
        }catch let err as NSError{
            print(err.description)
        }
    }
   func getSelectedItemColour(){
    if selectedItems == true {
        let indexPathofAllSelectedItem = collection.indexPathsForSelectedItems()
        for indexPathofAllSelectedItems in indexPathofAllSelectedItem!{
            let cell = collection.cellForItemAtIndexPath(indexPathofAllSelectedItems)
            cell?.layer.borderWidth = 2.5
            cell?.layer.borderColor = UIColor.orangeColor().CGColor
            
        }
    }else if selectedItems == false{
        let indexPathofAllSelectedItem = collection.indexPathsForSelectedItems()
        for indexPathofAllSelectedItems in indexPathofAllSelectedItem!{
            collection.deselectItemAtIndexPath(indexPathofAllSelectedItems, animated: true)
            let cell = collection.cellForItemAtIndexPath(indexPathofAllSelectedItems)
            cell?.layer.borderColor = UIColor.clearColor().CGColor
        }
    
    }
    
    }
   
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collection.dequeueReusableCellWithReuseIdentifier("photos", forIndexPath: indexPath) as? showCell{
            let photo = photos[indexPath.row]
            //cell.frame.size.width = screenWidth / 3
            cell.layer.borderColor = UIColor.blackColor().CGColor
            cell.layer.borderWidth = 0.5
            getSelectedItemColour() //To get Colour when User Scroll
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),  {
                // Load image on a non-ui-blocking thread
                cell.configureCell(photo)
                
//                dispatch_sync(dispatch_get_main_queue(), {
//                    // Assign image back on the main thread
//                    
//                });
            });

            
            
        //    cell.layer.borderColor = UIColor.clearColor().CGColor
            return cell
        }else{
            return showCell()
        }
    }
    func cellCount()->Int{
         let cellCount =  self.collection.indexPathsForSelectedItems()!.count
        return cellCount
    }
    func selectItemToggle()->Bool{
        if selectedItems == false{
            selectedItems = true
            return selectedItems
        }
        else{
            selectedItems = false
            return selectedItems
        }
    
    }
    @IBAction func onSelectAllPressed(sender:UIButton){
        selectItemToggle()
        sfxSelect.play()
        isAllPhotoSelected()
        
    }
    func isAllPhotoSelected(){
        if selectedItems == true{
            for (var i = 0; i < collection.numberOfItemsInSection(0); ++i)
            {
                //Selecting all Items
                collection.selectItemAtIndexPath(NSIndexPath(forRow: i, inSection: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.Left)
                
            }
        }
        getSelectedItemColour()
    
    }
        func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            sfxSelect.play()
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
          
            let photo = photos[indexPath.row]
            let selectedItem = collection.indexPathsForSelectedItems()
            for indexpath in selectedItem!{
                print([indexpath.row])
                indexPathOfSelectedImage = [indexpath.row]
            }
            if buttonChecker() == true{
                if cell?.selected == true{
                    cell?.layer.borderWidth = 2.5
                    cell?.layer.borderColor = UIColor.orangeColor().CGColor
                    view.makeToast(message: "\(cellCount()) Item selected")
                }

            }else{
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options:UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
                    cell?.frame = collectionView.bounds
                    }, completion: { (finished:Bool) -> Void in
                        collectionView.reloadItemsAtIndexPaths([indexPath])
                        
                })
                self.performSegueWithIdentifier("DetailVC", sender:photo)
            }
        
        
        
        }
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        sfxSelect.play()
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        if cell?.selected == false{
                cell?.layer.borderColor = UIColor.clearColor().CGColor
                view.makeToast(message: "\(cellCount()) Item selected")
        }
        
    }
    func Toggle()->Int{
        if Activate.tag == 0{
           return 1
        }
        else{
            return 0
        }
    }
   
    func animatedTrash(position:Int){
        UIView.animateWithDuration(0.5, delay:0.1, usingSpringWithDamping:1, initialSpringVelocity: 0.1, options:UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            
            if self.Activate.tag == 1{
                self.toolBar.hidden = false
            }else{
                self.toolBar.hidden = true
            }
            
            }, completion: { (finished:Bool) -> Void in
                
        })
    
    }
    
    @IBAction func onEditButtonPressed(sender: AnyObject) {
        
        sfxEdit.play()
        let tag = Toggle()
        Activate.tag = tag
        print(Activate.tag)
        if Activate.tag == 1{
            self.trashButton.hidden = false
            animatedTrash(2)
            storeLabel.text = "Select Items"
        }
        else{
            animatedTrash(10)
            storeLabel.text = "Photo Store"
            collection.reloadData()
        }
        
    }
    func buttonChecker()->Bool{
        if Activate.tag == 1 {
            return true
        }
        return false
    }

  
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        
//        
//        return CGSize(width: 60, height: 60)
//    }
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
////        if let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout {
////            let itemWidth = view.bounds.width / 3.5
////            let itemHeight = layout.itemSize.height
////            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
////            layout.invalidateLayout()
////        }
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
//        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/2)
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
//    }
    func OnDelPressed(){
       animatedTrash(2)
        let selectedItem = self.collection.indexPathsForSelectedItems()
         print(selectedItem?.count)
        if selectedItem?.count >= 1{
          
            deleteItemsAtIndexPaths(selectedItem!)
            
            
        }else{
            view.makeToast(message: "0 item selected")}
    }
  
    func appendValue(getValue:[Int])->[Int]{
         saveValue = saveValue + getValue
        return saveValue
    }
  
    func deleteItemsAtIndexPaths(indexPaths: [NSIndexPath]){
        var indexRef:[Int]!
        var secondIndexRef:[Int]!
        if clearImageData > 0{
            saveValue.removeAll()
        }
        for indexpath in indexPaths{
              indexRef = [indexpath.row]
                secondIndexRef = appendValue(indexRef)
        }
        secondIndexRef = secondIndexRef.sort{$0 > $1}
        print(secondIndexRef)
        for values in secondIndexRef{
            let app = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = app.managedObjectContext
            print (values)
            let photo = photos[values]
            if importButton == true {
            let img = photo.getImage()
                UIImageWriteToSavedPhotosAlbum(
                    img,
                    self,
                    Selector("image:didFinishSavingWithError:contextInfo:"),
                    nil)
            }
            context.deleteObject(photo)
            
            do{
                
                photos.removeAtIndex(values)
                try context.save()
                clearImageData++
                if importButton == false{
                    view.makeToast(message: "\(secondIndexRef.count) Items Deleted ")
                }
                importButton = false
                
                
            }catch{
                let saveError = error as NSError
                print(saveError)
            }
            toolBar.hidden = true
            Activate.tag = 0
            storeLabel.text = "Photo Store"
            collection.reloadData()
            
        }
    }
    
    func image(
        image: UIImage!,
        didFinishSavingWithError error:NSError!,
        contextInfo:UnsafePointer<Void>)
    {
         view.makeToast(message: "Items imported to Gallery")
    }
    @IBAction func onAddPressed(sender: AnyObject) {
        self.sfxAdd.play()
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            SwiftSpinner.show("Importing Images ")
            print("This is Assets: \(assets.count)")
            
             self.imageCounter = 0
            dispatch_async(dispatch_get_global_queue(0, 0), {
                let options = PHImageRequestOptions()
                options.deliveryMode = .HighQualityFormat
                options.synchronous = true
                print("asset count \(assets.count)")
                for (_, asset) in assets.enumerate() {
                    asset.fetchImageWithSize(PHImageManagerMaximumSize, options: options) { image, info in
                        self.orignalImages.append(image!)
                    }
                    print("Appending Orignal images count = \(self.orignalImages.count)")
                     self.phasset =  asset.originalAsset!
                     self.delPhoto()
                }
                
              

                if assets.count == self.orignalImages.count{
                    self.savePhotos()
                    print("Image saved")
                    self.isImageSaved = true
                    
                    
                }
            })
        
        }
        self.orignalImages.removeAll()
        self.pickerController.defaultSelectedAssets = nil
        self.presentViewController(pickerController, animated: true) {}
    }
    func savePhotos(){
        for var photo = 0; photo < orignalImages.count ; ++photo{
            let app = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = app.managedObjectContext
            let entity = NSEntityDescription.entityForName("Photos", inManagedObjectContext: context)!
            let photos = Photos(entity:entity, insertIntoManagedObjectContext: context)
            photos.setPhotosImage(orignalImages[photo])
            context.insertObject(photos)
            do{
                try context.save()
               
            }catch {
                print("could not save Data\(error)")
            }
        }
        
        dispatch_async(dispatch_get_main_queue()){
            self.fetchAndSetResult()
            self.collection.reloadData()
            SwiftSpinner.hide()
        }
        
        
    }
    func delPhoto(){
        let arrayToDelete = NSArray(object: self.phasset)
        PHPhotoLibrary.sharedPhotoLibrary().performChanges( {
            PHAssetChangeRequest.deleteAssets(arrayToDelete)},
            completionHandler: {
                success, error in
                NSLog("Finished deleting asset. %@", (success ? "Success" : error!))
        })
    }
    
    
    @IBAction func onDelPressed(sender: AnyObject) {
        OnDelPressed()
        sfxTrash.play()
    }
    @IBAction func onExportClicked(sender: AnyObject) {
       if sfxTrash.playing == true {
            sfxTrash.stop()
        }
        sfxTrash.play()
        importButton = true
        OnDelPressed()
        

    }
    @IBAction func onSettingpressed(sender: AnyObject) {
        sfxSelect.play()
        Activate.tag = 0
        toolBar.hidden = true
        self.performSegueWithIdentifier("setting", sender: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailVC"{
            if let detailvc = segue.destinationViewController as? DetailVC{
                if let photos = sender as? Photos{
                    detailvc.photo = photos
                    detailvc.photoinarray = self.photos
                    detailvc.indexPathOfSelectedImage = self.indexPathOfSelectedImage
                }
            }
        }
     
    }
}
