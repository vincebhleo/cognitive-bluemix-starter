//
//  LocationManager.swift
//  Natural Language Interface
//
//  Created by Minakshi Ghanekar on 21/11/16.
//  Copyright © 2016 Persistent. All rights reserved.
//

import UIKit
import CoreLocation

private let locManager = LocationManager()

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    
    class var sharedInstance: LocationManager {
        return locManager
    }
    
    func startUpdatingLocation()
    {
        locManager.locationManager.delegate = self
        locManager.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.locationManager.requestWhenInUseAuthorization()
        locManager.locationManager.startUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[0] as CLLocation
        
    }
    
}
