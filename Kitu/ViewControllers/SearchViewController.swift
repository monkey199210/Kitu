//
//  SearchViewController.swift
//  Kitu
//
//  Created by Rui Caneira on 11/22/16.
//  Copyright © 2016 Rui Caneira. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import ZTDropDownTextField
import GooglePlaces
import MRProgress
class SearchViewController: UIViewController, CLLocationManagerDelegate {
    var infoList:[KInfo] = []
    var infoDic:Dictionary<String, Int> = [:]
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var fullAddressTextField: ZTDropDownTextField!
    
    var preMarker: GMSMarker?
    
    let placesClient = GMSPlacesClient()
    var placeList: [GMSAutocompletePrediction] = []
    
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
        
        fullAddressTextField.delegate = self
        fullAddressTextField.dataSourceDelegate = self
        fullAddressTextField.animationStyle = .Slide
        fullAddressTextField.addTarget(self, action: #selector(FindFunPlaceViewController.placeAutocomplete(_:)), forControlEvents:.EditingChanged)
        
    }
    override func viewWillAppear(animated: Bool) {
        self.searchFunPlace()
    }
    
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
    //    var locationMarker: GMSMarker!
    func setupPins()
    {
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
        maker.snippet = infoList[index].placeAddress
        maker.flat = true
        maker.userData = index
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
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
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
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
    
}
extension SearchViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
extension SearchViewController: GMSMapViewDelegate
{
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        let index = marker.userData as? Int
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let placeListViewController = storyboard.instantiateViewControllerWithIdentifier("PlaceListViewController") as? PlaceListViewController
        placeListViewController?.selectedPlace = self.infoList[index!]
        self.navigationController?.pushViewController(placeListViewController!, animated: true)
        
    }
}
extension SearchViewController: ZTDropDownTextFieldDataSourceDelegate {
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
            } else {
                //                print("No place details for \(placeID)")
            }
        });
    }
}

