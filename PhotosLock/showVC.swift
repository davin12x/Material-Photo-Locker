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
    let vc = BSImagePickerViewController()
    let pickerController = DKImagePickerController()
    public var fullScreenImage: UIImage?
    internal var selectedAssets = [DKAsset]()
    
    var imagePicker = UIImagePickerController()
    var photos = [Photos]()
    var saveValue = [Int]()
    var clearImageData = 0
    var imageCounter = 0
   //@IBOutlet weak var photoImage :UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.allowsMultipleSelection = true
        collection.delegate = self
        collection.dataSource = self
        imagePicker.delegate = self
        
        
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
            return cell
        }else{
            return showCell()
        }
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        let photo = photos[indexPath.row]
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        if cell?.selected == true{
            cell?.layer.borderWidth = 4.0
             cell?.layer.borderColor = UIColor.greenColor().CGColor
        }
        else{
            cell?.layer.borderColor = UIColor.clearColor().CGColor
        }
        
       // collectionView.reloadItemsAtIndexPaths([indexPath])
       // performSegueWithIdentifier("DetailVC", sender:photo)
        
    }
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        if cell?.selected == false{
                cell?.layer.borderColor = UIColor.clearColor().CGColor
        }
        
    }


  
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 104, height: 97)
    }
    func OnDelPressed(){
       
        let selectedItem = self.collection.indexPathsForSelectedItems()
        print(selectedItem?.count)
        deleteItemsAtIndexPaths(selectedItem!)
        
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
            let photo = photos[values] as NSManagedObject
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
    
   
    @IBAction func onAddPressed(sender: AnyObject) {
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            self.imageCounter = 0
            self.pickerController.allowMultipleTypes = false
            self.pickerController.allowsLandscape = false
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
                                        
                                    }catch { let err = error as? NSError
                                        print("could not save Data\(error)")
                                    }
                    
                })
            }
        }
        
        self.presentViewController(pickerController, animated: true) {}
//       //presentViewController(imagePicker, animated: true, completion: nil)
//        bs_presentImagePickerController(vc, animated: true,
//            select: { (asset: PHAsset) -> Void in
//               
//                let manager = PHImageManager.defaultManager()
//                let option = PHImageRequestOptions()
//                var thumbnail = UIImage()
//                option.synchronous = true
//                manager.requestImageForAsset(asset, targetSize: CGSize(width: 600.0, height: 600.0), contentMode: .AspectFit, options: option, resultHandler: {(result, info)->Void in
//                    thumbnail = result!
//                    print(thumbnail)
//                })
//                let imagesss = thumbnail
//                let app = UIApplication.sharedApplication().delegate as! AppDelegate
//                let context = app.managedObjectContext
//                let entity = NSEntityDescription.entityForName("Photos", inManagedObjectContext: context)!
//                let photos = Photos(entity:entity, insertIntoManagedObjectContext: context)
//                photos.setPhotosImage(imagesss)
//                context.insertObject(photos)
//                do{
//                    try context.save()
//                    
//                }catch { let err = error as? NSError
//                    print("could not save Data\(error)")
//                }
//            }, deselect: { (asset: PHAsset) -> Void in
//                // User deselected an assets.
//                // Do something, cancel upload?
//            }, cancel: { (assets: [PHAsset]) -> Void in
//                // User cancelled. And this where the assets currently selected.
//            }, finish: { (var assets: [PHAsset]) -> Void in
//                assets.removeAll()
//            }, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        //self.photoImage.image = image
        let imagesss = image
        print(image)
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext
        let entity = NSEntityDescription.entityForName("Photos", inManagedObjectContext: context)!
        let photos = Photos(entity:entity, insertIntoManagedObjectContext: context)
        photos.setPhotosImage(imagesss)
        
        context.insertObject(photos)
        do{
            try context.save()
           
        }catch{
            print("could not save recepie")
        }
         collection.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
        
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
