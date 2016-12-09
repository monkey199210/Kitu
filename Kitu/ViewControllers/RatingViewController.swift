//
//  RatingViewController.swift
//  Kitu
//
//  Created by Rui Caneira on 12/4/16.
//  Copyright © 2016 Rui Caneira. All rights reserved.
//

import UIKit
import MRProgress
class RatingViewController: UIViewController, UINavigationControllerDelegate
{
    var selectedPlace: KInfo?
    @IBOutlet weak var rating: HCSStarRatingView!
    @IBOutlet weak var reviewTxt: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeImg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = NSURL(string: (selectedPlace?.placeImage)!) {
            placeImg.nk_cancelLoading()
            placeImg.nk_setImageWith(url)
        }
        if let placeName = selectedPlace!.placeName
        {
            
            titleLabel.text = placeName
            reviewTxt.text = selectedPlace?.placeDescription
        }
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func setRatingAction(sender: AnyObject) {
        if(rating.value == 0)
        {
            showAlertMessage("", title: "Please Set stars")
        }
        var newRate:Float = 0
        var newRatingCount:Int = 0
        newRatingCount = Int((selectedPlace?.placeRatingCount)!)!
        if let rating = Float((selectedPlace?.placeRating)!)
        {
            newRate = (rating * Float(newRatingCount) + Float(self.rating.value)) / (Float(newRatingCount + 1))
        }
        let params: [String: AnyObject] = ["request": "3" as AnyObject,
                                           EHNet.PLACERATING: "\(newRate)" as AnyObject,
                                           EHNet.PLACERATINGCOUNT: "\(newRatingCount + 1)" as AnyObject,
                                           "placeID": selectedPlace?.placeID as! AnyObject
        ]
        
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        Net.requestGetServer(EHNet.BASE_URL, params: params).onSuccess(callback: { (_) -> Void in
            print("success")
            MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            self.navigationController?.popViewControllerAnimated(true)
        }).onFailure { (error) -> Void in
            //                self.loadingView.completeLoading(false)
            //                self.loadingView.hidden = true
            //            UIAlertView(title: "ERROR", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
            print("error")
            MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
        }
    }
    func showAlertMessage(message: String!, title: String!)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}


