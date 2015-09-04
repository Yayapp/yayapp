//
//  ChooseEventPictureViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class ChooseEventPictureViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChooseCategoryPhotoDelegate {

    let picker = UIImagePickerController()
    var delegate:ChooseEventPictureDelegate!
    var categories:[Category]! = []
    
    @IBOutlet weak var photos: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        photos.delegate = self
        photos.dataSource = self
        
        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = UIColor(red:CGFloat(3/255.0), green:CGFloat(118/255.0), blue:CGFloat(114/255.0), alpha: 1)
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        
        ParseHelper.getCategories({
            (categories:[Category]?, error:NSError?) in
            if(error == nil) {
                self.categories = categories!
                self.photos.reloadData()
            }
        })
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = photos.dequeueReusableCellWithIdentifier("Cell") as! EventPhotoTableViewCell
        let category:Category! = categories[indexPath.row]
        
        cell.name.text = category.name
        category.photo.getDataInBackgroundWithBlock({
            (data:NSData?, error:NSError?) in
            if(error == nil) {
                var image = self.toCobalt(UIImage(data:data!)!)
                cell.photo.image = image
            }
        })
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("PhotosTableViewController") as! PhotosTableViewController
        vc.delegate = self
        let category = categories[indexPath.row]
        vc.category = category
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.height/2
    }

    func madeCategoryPhotoChoice(eventPhoto: EventPhoto) {
        delegate.madeEventPictureChoice(eventPhoto.photo, pickedPhoto: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func library(sender: AnyObject) {
        picker.allowsEditing = true //2
        picker.sourceType = .PhotoLibrary //3
        picker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let pickedImage:UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        let imageData = UIImagePNGRepresentation(pickedImage)
        let imageFile:PFFile = PFFile(data: imageData)
        delegate.madeEventPictureChoice(imageFile, pickedPhoto: pickedImage)
        dismissViewControllerAnimated(true, completion: {
            self.navigationController?.popViewControllerAnimated(true)
        }) //5
        
    }
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    func toCobalt(image:UIImage) -> UIImage{
        let inputImage:CIImage = CIImage(CGImage: image.CGImage)
        
        // Make the filter
        let colorMatrixFilter:CIFilter = CIFilter(name: "CIColorMatrix")
        colorMatrixFilter.setDefaults()
        colorMatrixFilter.setValue(inputImage, forKey:kCIInputImageKey)
        colorMatrixFilter.setValue(CIVector(x:1, y:0, z:0, w:0), forKey:"inputRVector")
        colorMatrixFilter.setValue(CIVector(x:0, y:1, z:0, w:0), forKey:"inputGVector")
        colorMatrixFilter.setValue(CIVector(x:0, y:0, z:1, w:0), forKey:"inputBVector")
        colorMatrixFilter.setValue(CIVector(x:1, y:0, z:0, w:1), forKey:"inputAVector")
        
        // Get the output image recipe
        let outputImage:CIImage = colorMatrixFilter.outputImage
        
        // Create the context and instruct CoreImage to draw the output image recipe into a CGImage
        let context:CIContext = CIContext(options:nil)
        let cgimg:CGImageRef = context.createCGImage(outputImage, fromRect:outputImage.extent()) // 10
        
        return UIImage(CGImage:cgimg)!
    }
    
}
protocol ChooseEventPictureDelegate : NSObjectProtocol {
    func madeEventPictureChoice(photo: PFFile, pickedPhoto: UIImage?)
}
