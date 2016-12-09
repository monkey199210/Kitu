//
//  PlaceListViewController.swift
//  Kitu
//
//  Created by Rui Caneira on 12/4/16.
//  Copyright © 2016 Rui Caneira. All rights reserved.
//

import UIKit
import MRProgress
import Alamofire
import Haneke
import SESlideTableViewCell
class PlaceTableViewCell: SESlideTableViewCell
{
    @IBOutlet weak var placeImg: UIImageView!
    @IBOutlet weak var rating: HCSStarRatingView!
    @IBOutlet weak var ratingCount: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
}
class PlaceListViewController: UIViewController {
    //place info from previous screen.
    var selectedPlace:KInfo?
    var editFlag:Bool?
    var infoList:[KInfo] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var numberTableLoad = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    override func viewWillAppear(animated: Bool) {
        searchFunPlace()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func initView()
    {
        longitudeLabel.text = selectedPlace?.placeLongitude
        latitudeLabel.text = selectedPlace?.placeLatitude
        adressLabel.text = selectedPlace?.placeAddress
        titleLabel.text = selectedPlace?.placeName
        
    }
    //search fun places from server by coordinate
    func searchFunPlace()
    {
        let params = ["request": "4" as AnyObject,
                      EHNet.PLACELONGITUDE: selectedPlace?.placeLongitude as! AnyObject,
                      EHNet.PLACELATITUDE: selectedPlace?.placeLatitude as! AnyObject]
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        Net.requestServer(EHNet.BASE_URL, params: params).onSuccess(callback: {(placeList) -> Void in
            self.infoList = placeList
            
            self.tableView.reloadData()
            MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
        }).onFailure(callback: { (error) -> Void in
            MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
        })
        
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
extension PlaceListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaceCell") as? PlaceTableViewCell
        cell!.delegate = self
        if((editFlag) != nil)
        {
            if numberTableLoad == 0
            {
                cell!.addRightButtonWithText("  Edit  ", textColor: UIColor.whiteColor(), backgroundColor: UIColor(hue: 180.0/360.0, saturation: 0.8, brightness: 0.9, alpha: 1.0))
                cell!.addRightButtonWithText("Delete", textColor: UIColor.whiteColor(), backgroundColor: UIColor(hue: 0.0/360.0, saturation: 0.8, brightness: 0.9, alpha: 1.0))
            }
        }
        cell!.date.text = infoList[indexPath.row].placeDate
        cell!.descriptionLabel.text = infoList[indexPath.row].placeDescription
        if let rating = Float(infoList[indexPath.row].placeRating)
        {
            cell!.rating.value = CGFloat(rating)
        }
        cell!.ratingCount.text = infoList[indexPath.row].placeRatingCount
        if let url = NSURL(string: (infoList[indexPath.row].placeImage)) {
            cell!.placeImg.hnk_setImageFromURL(url)
        }
        if indexPath.row == infoList.count-1
        {
            numberTableLoad = 1
        }
        return cell!
    }
}
extension PlaceListViewController: UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let ratingViewController = storyboard.instantiateViewControllerWithIdentifier("RatingViewController") as? RatingViewController
        ratingViewController?.selectedPlace = self.infoList[indexPath.row]
        self.navigationController?.pushViewController(ratingViewController!, animated: true)
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            //            yourArray.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
        }
    }
}
extension PlaceListViewController: SESlideTableViewCellDelegate
{
    func slideTableViewCell(cell: SESlideTableViewCell!, didTriggerRightButton buttonIndex: NSInteger) {
        let indexPath = tableView.indexPathForCell(cell)
        print("right button \(buttonIndex) tapped in cell \(indexPath!.section) - \(indexPath!.row)")
        if buttonIndex == 0
        {
            //edit action
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let uploadViewController = storyboard.instantiateViewControllerWithIdentifier("RegisterDrawImageViewController") as? RegisterDrawImageViewController
            uploadViewController?.editItem = infoList[(indexPath?.row)!]
            self.navigationController?.pushViewController(uploadViewController!, animated: true)
            
        }else if buttonIndex == 1
        {
            //delete action
            let params = ["request": "6" as AnyObject,
                          "placeID": infoList[(indexPath?.row)!].placeID as! AnyObject]
            MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
            Net.requestGetServer(EHNet.BASE_URL, params: params).onSuccess(callback: {(_) -> Void in
                self.searchFunPlace()
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            }).onFailure(callback: { (error) -> Void in
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            })
            
        }
    }
}

