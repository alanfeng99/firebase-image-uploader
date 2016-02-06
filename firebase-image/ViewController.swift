//
//  ViewController.swift
//  firebase-image
//
//  Created by Alan Feng on 2/6/16.
//  Copyright © 2016 Alan Feng. All rights reserved.
//

import UIKit

/*  firebase basics:

    - http://www.raywenderlich.com/109706/firebase-tutorial-getting-started
    - https://www.firebase.com/blog/2014-04-28-best-practices-arrays-in-firebase.html

*/

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Please change the url to your firebase location
    var myRootRef = Firebase(url:"https://fire-image.firebaseio.com/images")
    
    let sectionInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    
    var imageArray = [String]();
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        myRootRef.observeEventType(.Value, withBlock: { snapshot in
            
            if (self.imageArray.count > 0) {
                self.imageArray.removeAll()
            }
            
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
                let base64String = rest.value as! String
                self.imageArray.append(base64String)
            }
            
            self.collectionView.reloadData()
        })
    }
    
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        //Resize the image and convert to NSData format, the imge would be too large if you don't resize it.
        let imageData = UIImagePNGRepresentation(self.resizeImage(image, newWidth: 2000))
        
        //Convert NSData to Base64String
        let base64String = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        
        //Save the image under Root using an autoID
        myRootRef.childByAutoId().setValue(base64String)
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

/*
    for collectionView tutorial : http://www.raywenderlich.com/78550/beginning-ios-collection-views-swift-part-1
*/

extension ViewController : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.blackColor()
        // Configure the cell
        
        let base64 = imageArray[indexPath.row];
        
        //Convert base64String back to NSData
        let decodedData = NSData(base64EncodedString: base64, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)

        if decodedData != nil {
            //Tag = 100 is what we defined in CollectionView for imageView
            let imageView = cell.contentView.viewWithTag(100) as! UIImageView
            //Get UIImage form NSData
            imageView.image =  UIImage(data: decodedData!)
        }
        return cell
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        //We want 3 images in a row
        let imageWidth = (screenSize.width - 20) / 3 - 10
            
        return CGSize(width: imageWidth, height: imageWidth)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
}

