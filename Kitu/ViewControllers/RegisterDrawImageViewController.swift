//
//  RegisterDrawImageViewController.swift
//  Kitu
//
//  Created by Rui Caneira on 12/3/16.
//  Copyright © 2016 Rui Caneira. All rights reserved.
//

import UIKit
import MapKit
import MRProgress
class RegisterDrawImageViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var upLoadBtn: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var drawImage: UIImageView!
    @IBOutlet weak var btn_AddImage: UIButton!
    @IBOutlet weak var txtDescription: UITextView!
    var showKeyboard = false
    var selectedImage:UIImage?
    //location params from previous screen...
    var coordinate:CLLocationCoordinate2D?
    var locationName: String?
    var locationAddress: String?
    
    //edit action case
    var editItem: KInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let infoItem = editItem
        {
            hintLabel.hidden = true
            titleLabel.text = infoItem.placeName
            upLoadBtn.setTitle("Update Fun Place", forState: UIControlState.Normal)
            txtDescription.text = infoItem.placeDescription
            if let url = NSURL(string: (infoItem.placeImage)) {
                drawImage.nk_cancelLoading()
                drawImage.nk_setImageWith(url)
            }
            
        }else {
            titleLabel.text = locationName
        }
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(FindFunPlaceViewController.handleTap))
        self.view.addGestureRecognizer(tapGesture);
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWasShown), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown()
    {
        if(!showKeyboard)
        {
            showKeyboard = true
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width, scrollView.frame.size.height + 216)
        }
    }
    func keyboardHide()
    {
        if showKeyboard
        {
            self.view.endEditing(true)
            scrollView.contentSize = CGSizeMake(0, 0);
            showKeyboard = false
        }
    }
    
    @IBAction func addImageAction(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "", message:
            "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        
        let photoAction = UIAlertAction(title: "Camera Roll", style: .Default) { (action) in
            // ...
            self.takePhoto()
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .Default) { (action) in
            self.gallery()
        }
        
        alertController.addAction(photoAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = sender.frame
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    @IBAction func uploadAction(sender: AnyObject) {
        
        let currentDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy, HH:mm"
        let convertedDate = dateFormatter.stringFromDate(currentDate)
        if let infoItem = editItem
        {
            // edit upload..
            
            let params: [String: AnyObject] = ["request": "8" as AnyObject,
                                               "placeID": infoItem.placeID!,
                                               EHNet.PLACENAME: infoItem.placeName as! AnyObject,
                                               EHNet.PLACEADDRESS: infoItem.placeAddress as! AnyObject,
                                               EHNet.PLACEDESCRIPTION: txtDescription.text as AnyObject,
                                               EHNet.PLACEDATE: convertedDate as AnyObject,
                                               EHNet.PLACERATING: "0" as AnyObject,
                                               "pImgName": "image" as AnyObject,
                                               EHNet.PLACELATITUDE: infoItem.placeLatitude as AnyObject,
                                               EHNet.PLACELONGITUDE: infoItem.placeLongitude as AnyObject,
                                               EHNet.PLACEWEBSITE: "" as AnyObject,
                                               EHNet.PLACERATINGCOUNT: "0" as AnyObject,
                                               EHNet.PLACEPHONE: "" as AnyObject
            ]
            
            if let image = drawImage.image
            {
                MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
                Net.uploadData(image, params: params).onSuccess(callback: { (_) -> Void in
                    print("success")
                    MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
                    self.showAlertMessage("", title: "Success")
                    self.navigationController?.popViewControllerAnimated(true)
                }).onFailure { (error) -> Void in
                    //                self.loadingView.completeLoading(false)
                    //                self.loadingView.hidden = true
                    //            UIAlertView(title: "ERROR", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                    print("error")
                    MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
                }
            }

            
        }else{
            let latitude = String(format: "%f", (coordinate!.latitude))
            let longitude = String(format: "%f", (coordinate!.longitude))
            
            let params: [String: AnyObject] = ["request": "5" as AnyObject,
                                               EHNet.PLACENAME: locationName as! AnyObject,
                                               EHNet.PLACEADDRESS: locationAddress as! AnyObject,
                                               EHNet.PLACEDESCRIPTION: txtDescription.text as AnyObject,
                                               EHNet.PLACEDATE: convertedDate as AnyObject,
                                               EHNet.PLACERATING: "0" as AnyObject,
                                               "pImgName": "image" as AnyObject,
                                               EHNet.PLACELATITUDE: latitude as AnyObject,
                                               EHNet.PLACELONGITUDE: longitude as AnyObject,
                                               EHNet.PLACEWEBSITE: "" as AnyObject,
                                               EHNet.PLACERATINGCOUNT: "0" as AnyObject,
                                               EHNet.PLACEPHONE: "" as AnyObject
            ]
            
            if let image = selectedImage
            {
                MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
                Net.uploadData(image, params: params).onSuccess(callback: { (_) -> Void in
                    print("success")
                    MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
                    self.showAlertMessage("", title: "Success")
                    self.navigationController?.popViewControllerAnimated(true)
                }).onFailure { (error) -> Void in
                    //                self.loadingView.completeLoading(false)
                    //                self.loadingView.hidden = true
                    //            UIAlertView(title: "ERROR", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                    print("error")
                    MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
                }
            }
        }
    }
    func takePhoto()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    func gallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func handleTap()
    {
        self.view.endEditing(true)
    }
    func showAlertMessage(message: String!, title: String!)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}
extension RegisterDrawImageViewController: UIImagePickerControllerDelegate
{
//    func imagePickerController(picker: UIImagePickerController, did) {
//        selectedImage = image
//        drawImage.image = image
//        self.dismissViewControllerAnimated(true, completion: nil);
//    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("cancel")
    dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = pickedImage
            drawImage.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}
extension RegisterDrawImageViewController: UITextViewDelegate
{
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        txtDescription.needsUpdateConstraints()
        scrollView.contentOffset = CGPointMake(0, txtDescription.bounds.height)
        return true
    }
    func textViewDidChange(textView: UITextView) {
        if textView.text.isEmpty
        {
            hintLabel.hidden = false
        }else{
            hintLabel.hidden = true
        }
    }
}