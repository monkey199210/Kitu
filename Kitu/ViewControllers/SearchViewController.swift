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
class SearchViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    @IBOutlet weak var mapView: GMSMapView!
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
        mapView.camera = GMSCameraPosition.cameraWithTarget(newLocation!.coordinate, zoom: 15.0)
        mapView.settings.myLocationButton = true
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(newLocation!.coordinate.latitude, newLocation!.coordinate.longitude)
        marker.map = self.mapView
    }

}
