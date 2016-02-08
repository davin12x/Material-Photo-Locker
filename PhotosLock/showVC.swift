//
//  showVC.swift
//  PhotosLock
//
//  Created by Lalit on 2016-02-08.
//  Copyright © 2016 Bagga. All rights reserved.
//

import UIKit
import CoreData

class showVC: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var collection : UICollectionView!
    
    var imagePicker = UIImagePickerController()
    var photos = [Photos]()
   // @IBOutlet weak var photoImage :UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(photos.count)
        return photos.count
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 105, height: 105)
    }
    @IBAction func onAddPressed(sender: AnyObject) {
       presentViewController(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        //self.photoImage.image = image
        let imagesss = image
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
        dismissViewControllerAnimated(true, completion: nil)
        
    }
}
