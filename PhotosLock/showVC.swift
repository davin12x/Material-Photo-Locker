//
//  showVC.swift
//  PhotosLock
//
//  Created by Lalit on 2016-02-08.
//  Copyright © 2016 Bagga. All rights reserved.
//

import UIKit
import CoreData
import BSImagePicker
import Photos
import DKImagePickerController


class showVC: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var collection : UICollectionView!
    let pickerController = DKImagePickerController()
    internal var selectedAssets = [DKAsset]()
    
    @IBOutlet weak var Activate: UIButton!
    var imagePicker = UIImagePickerController()
    var photos = [Photos]()
    var saveValue = [Int]()
    var clearImageData = 0
    var imageCounter = 0
    var delPhotos = [UIImage]()
   //@IBOutlet weak var photoImage :UIImageView!
    @IBOutlet weak var trashButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.allowsMultipleSelection = true
        collection.delegate = self
        collection.dataSource = self
        imagePicker.delegate = self
        trashButton.hidden = true
        trashButton.center.x = self.view.frame.width + 30
        pickerController.assetGroupTypes = [.SmartAlbumScreenshots]
    
        
    }
    override func viewDidAppear(animated: Bool) {
        fetchAndSetResult()
        collection.reloadData()
        
    
        
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
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collection.dequeueReusableCellWithReuseIdentifier("photos", forIndexPath: indexPath) as? showCell{
            let photo = photos[indexPath.row]
            cell.configureCell(photo)
            cell.layer.borderColor = UIColor.clearColor().CGColor
            return cell
        }else{
            return showCell()
        }
    }
    func cellCount()->Int{
         let cellCount =  self.collection.indexPathsForSelectedItems()!.count
        return cellCount
    }
        func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            let photo = photos[indexPath.row]
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            if buttonChecker() == true{
                
                if cell?.selected == true{
                  
                    
                    cell?.layer.borderWidth = 2.0
                    cell?.layer.borderColor = UIColor.blueColor().CGColor
                    view.makeToast(message: "\(cellCount()) Item selected")
                   
                }

            }else{
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options:UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
                    cell?.frame = collectionView.bounds
                    }, completion: { (finished:Bool) -> Void in
                        collectionView.reloadItemsAtIndexPaths([indexPath])
                        self.performSegueWithIdentifier("DetailVC", sender:photo)
                })
                
            }
        
        
        
        }
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
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
        UIView.animateWithDuration(5.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options:UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
            
            self.trashButton.center.x = self.view.frame.width / position
            }, completion: { (finished:Bool) -> Void in
                
        })
    
    }
    
    @IBAction func onEditButtonPressed(sender: AnyObject) {
        
       
        let tag = Toggle()
        Activate.tag = tag
        print(Activate.tag)
        if Activate.tag == 1{
            self.trashButton.hidden = false
            animatedTrash(2)
        }
        else{
            animatedTrash(10)
            trashButton.hidden = true
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
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 113, height: 113)
    }
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
            let img = photo.getImage()
            
         
            
            
        
           
//                UIImageWriteToSavedPhotosAlbum(
//                    img,
//                    self,
//                    Selector("image:didFinishSavingWithError:contextInfo:"),
//                    nil)
            
           
          
            context.deleteObject(photo)
            do{
                
                photos.removeAtIndex(values)
                try context.save()
                clearImageData++
                
            }catch{
                let saveError = error as NSError
                print(saveError)
            }
            collection.reloadData()
            
        }
    }
    
    func image(
        image: UIImage!,
        didFinishSavingWithError error:NSError!,
        contextInfo:UnsafePointer<Void>)
    {
        print("Success Saving image")
    }
    @IBAction func onAddPressed(sender: AnyObject) {
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            self.imageCounter = 0
            self.pickerController.allowMultipleTypes = false
            self.pickerController.allowsLandscape = false
            self.pickerController.sourceType = .Camera
            var orignalImages :[UIImage] = []
            for asset in assets{
                asset.fetchFullScreenImageWithCompleteBlock({ (image, info) -> Void in
                    orignalImages.append(image!)
                    print(orignalImages.count)
                    let imagesss = orignalImages[self.imageCounter]
                                    let app = UIApplication.sharedApplication().delegate as! AppDelegate
                                    let context = app.managedObjectContext
                                    let entity = NSEntityDescription.entityForName("Photos", inManagedObjectContext: context)!
                                    let photos = Photos(entity:entity, insertIntoManagedObjectContext: context)
                                    photos.setPhotosImage(imagesss)
                                    context.insertObject(photos)
                                    do{
                                        try context.save()
                                        self.imageCounter++
                                        self.pickerController.defaultSelectedAssets = nil
                                    }catch {
                                        print("could not save Data\(error)")
                                    }
                    
                    
                })
            }
        }
        self.presentViewController(pickerController, animated: true) {}
    }
   
    
    
    
    @IBAction func onDelPressed(sender: AnyObject) {
        OnDelPressed()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailVC"{
            if let detailvc = segue.destinationViewController as? DetailVC{
                if let photos = sender as? Photos{
                    detailvc.photo = photos
                }
            }
        }
    }
}
