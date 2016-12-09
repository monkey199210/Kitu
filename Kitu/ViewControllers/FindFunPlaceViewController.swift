//
//  FindFunPlaceViewController.swift
//  Kitu
//
//  Created by Rui Caneira on 12/2/16.
//  Copyright © 2016 Rui Caneira. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import MapKit
import MRProgress
import ZTDropDownTextField
import AddressBookUI
import GooglePlaces

class FindFunPlaceViewController: UIViewController, CLLocationManagerDelegate {
    var infoList:[KInfo] = []
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var fullAddressTextField: ZTDropDownTextField!
    @IBOutlet weak var mapView: GMSMapView!
    //parameters send upload parameters
    var selectedCoordinate:CLLocationCoordinate2D?
    var selectedLocationName:String?
    var selectedLocationAddress:String?
    
    let placesClient = GMSPlacesClient()
    var placeList: [GMSAutocompletePrediction] = []
    
    // MARK: Instance Variables
    
    var preMarker: GMSMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        // A minimum distance a device must move before update event generated
        locationManager.distanceFilter = 500
        // Request permission to use location service
        locationManager.requestWhenInUseAuthorization()
        // Request permission to use location service when the app is run
        locationManager.requestAlwaysAuthorization()
        // Start the update of user's location
        locationManager.startUpdatingLocation()
        self.mapView.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        //        configureTextField()
        //        handleTextFieldInterfaces()
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(FindFunPlaceViewController.handleTap))
        self.mapView.addGestureRecognizer(tapGesture);
        
        fullAddressTextField.delegate = self
        fullAddressTextField.dataSourceDelegate = self
        fullAddressTextField.animationStyle = .Slide
        fullAddressTextField.addTarget(self, action: #selector(FindFunPlaceViewController.placeAutocomplete(_:)), forControlEvents:.EditingChanged)
        
    }
    override func viewWillAppear(animated: Bool) {
            searchFunPlace()
        
    }
    func handleTap()
    {
        self.view.endEditing(true)
    }
    func setupPins()
    {
        if infoList.count == 0
        {
            return
        }
        self.mapView.clear()
        for i in 0 ..< infoList.count
        {
            if let latitude = Double(infoList[i].placeLatitude)
            {
                
                if let longitude = Double(infoList[i].placeLongitude)
                {
                    let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                    
                    setuplocationMarker(coordinate, index: i)
                }
            }
        }
        
    }
    
    func setuplocationMarker(coordinate: CLLocationCoordinate2D, index:Int) {
        let maker = GMSMarker(position: coordinate)
        maker.title = infoList[index].placeName
        maker.map = mapView
        maker.appearAnimation = kGMSMarkerAnimationPop
        maker.icon = UIImage(named: "marker")
        maker.flat = true
        maker.snippet = infoList[index].placeAddress
        maker.userData = index
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // CCLoactionManagerDelegare
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if (status == CLAuthorizationStatus.AuthorizedWhenInUse)
        {
            mapView.myLocationEnabled = true
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let newLocation = locations.last
         setAnotation((newLocation?.coordinate)!)
    }
    func setAnotation(coordinate: CLLocationCoordinate2D)
    {
        if let pMarker = preMarker
        {
            pMarker.map = nil
        }
        mapView.camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 15.0)
        mapView.settings.myLocationButton = true
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        marker.map = self.mapView
        preMarker = marker
    }
    
    //search fun places from server by coordinate
    func searchFunPlace()
    {
        let params = ["request": "2" as AnyObject]
        MRProgressOverlayView.overlayForView(self.view)
        Net.requestServer(EHNet.BASE_URL, params: params).onSuccess(callback: {(placeList) -> Void in
            self.infoList = placeList
            self.setupPins()
            MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
        }).onFailure(callback: { (error) -> Void in
            MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
        })
        
    }
    func placeAutocomplete(textField: UITextField) {
        let filter = GMSAutocompleteFilter()
        filter.type = .NoFilter
        
        placesClient.autocompleteQuery(textField.text!, bounds: nil, filter: filter, callback: {(results, error) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            if let results = results {
                self.placeList = results
                self.fullAddressTextField.dropDownTableView.reloadData()
            }
        })
    }
    // go to upload screen.
    @IBAction func nextAction(sender: AnyObject) {
        if selectedCoordinate == nil
        {
            showAlertMessage("", title: "Please Input location")
            return
        }
        if (selectedLocationName == nil)
        {
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let uploadViewController = storyboard.instantiateViewControllerWithIdentifier("RegisterDrawImageViewController") as? RegisterDrawImageViewController
        
        uploadViewController?.coordinate = selectedCoordinate
        uploadViewController?.locationName = selectedLocationName
        uploadViewController?.locationAddress = selectedLocationAddress
        
        self.navigationController?.pushViewController(uploadViewController!, animated: true)
        
    }
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //                if segue.identifier == "SegueRegister"
    //        {
    //            let uploadViewController = segue.destinationViewController as? RegisterDrawImageViewController
    //
    //            uploadViewController?.coordinate = selectedCoordinate
    //            uploadViewController?.locationName = selectedLocationName
    //        }
    //    }
    @IBAction func backAction(sender: AnyObject) {
        //        autocompleteTextfield = nil
        self.navigationController?.popViewControllerAnimated(true)
    }
    func showAlertMessage(message: String!, title: String!)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}
extension FindFunPlaceViewController: GMSMapViewDelegate
{
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        let index = marker.userData as? Int
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let placeListViewController = storyboard.instantiateViewControllerWithIdentifier("PlaceListViewController") as? PlaceListViewController
        placeListViewController?.selectedPlace = self.infoList[index!]
        placeListViewController?.editFlag = true
        self.navigationController?.pushViewController(placeListViewController!, animated: true)
    }
}
extension FindFunPlaceViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
extension FindFunPlaceViewController: ZTDropDownTextFieldDataSourceDelegate {
    func dropDownTextField(dropDownTextField: ZTDropDownTextField, numberOfRowsInSection section: Int) -> Int {
        return placeList.count
    }
    
    func dropDownTextField(dropDownTextField: ZTDropDownTextField, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = dropDownTextField.dropDownTableView.dequeueReusableCellWithIdentifier("addressCell")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "addressCell")
        }
        
        cell!.textLabel!.text = (placeList[indexPath.row].attributedFullText).string
        cell!.textLabel?.numberOfLines = 0
        
        return cell!
    }
    
    func dropDownTextField(dropdownTextField: ZTDropDownTextField, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //        mapView.removeAnnotations(mapView.annotations)
        //hide keyboared..
        self.view.endEditing(true)
        
        let placeId = placeList[indexPath.row].placeID
        
        fullAddressTextField.text = (self.placeList[indexPath.row].attributedFullText).string

        //        fullAddressTextField.text = formateedFullAddress(placeMark)
        MRProgressOverlayView.overlayForView(self.view)
        placesClient.lookUpPlaceID(placeId!, callback: { (place: GMSPlace?, error: NSError?) -> Void in
            MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                let location = CLLocationCoordinate2D(latitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude))
                
                self.setAnotation(location);
                self.selectedCoordinate = location
                self.selectedLocationAddress = (self.placeList[indexPath.row].attributedFullText).string
                self.selectedLocationName = place.name
            } else {
                //                print("No place details for \(placeID)")
            }
        });
    }
}

