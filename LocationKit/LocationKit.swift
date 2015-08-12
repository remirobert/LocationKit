//
//  LocationKit.swift
//  LocationKit
//
//  Created by Remi Robert on 29/06/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

import UIKit
import CoreLocation

typealias geocodeResultBlock = (placemarks: [CLPlacemark]?, error: NSError?) -> Void
typealias updateLocationResultblock = (location: CLLocation?, error: NSError?) -> Void

public class LocationKit: NSObject, CLLocationManagerDelegate {
    var geoCoder: CLGeocoder!
    var locationManager: CLLocationManager!
    var currentAddress: String!
    var _currentLocation: CLLocation!
    var isUpdatingLocation: Bool
    var isUpdatingLocationOnce: Bool
    var blockUpdateLocation: updateLocationResultblock!
    
    public class var sharedInstance: LocationKit {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: LocationKit? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LocationKit()
        }
        return Static.instance!
    }
    
    private func defaultInit() {
        accuracy = kCLLocationAccuracyKilometer
        locationManager.desiredAccuracy = accuracy
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.delegate = self
    }
    
    override init() {
        isUpdatingLocationOnce = false
        isUpdatingLocation = false
        super.init()
        geoCoder = CLGeocoder()
        locationManager = CLLocationManager()
        defaultInit()
    }
    
    public class func requestAuthorization(backgroundAuthotization: Bool = false) {
        sharedInstance.locationManager.requestWhenInUseAuthorization()
        if backgroundAuthotization {
            sharedInstance.locationManager.requestAlwaysAuthorization()
        }
    }    
}

public extension LocationKit {
    
    public var accuracy: CLLocationAccuracy {
        get {
            return locationManager.desiredAccuracy
        }
        set {
            locationManager.desiredAccuracy = newValue
        }
    }
    
    public var currentLocation: CLLocation {
        get {
            return _currentLocation
        }
        set {
            LocationKit.stopUpdatingLocation()
            _currentLocation = newValue
        }
    }
    
    public class func currentLocationWithCoordinates(coord: CLLocationCoordinate2D) {
        stopUpdatingLocation()
        sharedInstance.currentLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
    }
    
    public class func currentLocationWithLatitude(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let coord = CLLocationCoordinate2DMake(latitude, longitude)
        currentLocationWithCoordinates(coord)
    }
    
    internal class func setCurrentLocationByAddress(address: String, block: geocodeResultBlock) {
        sharedInstance.geoCoder.geocodeAddressString(address, completionHandler: { (placeMarks:[AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                block(placemarks: nil, error: error)
            }
            else {
                if let currentPlaceMark = placeMarks?.first as? CLPlacemark {
                    self.sharedInstance.currentLocation = currentPlaceMark.location
                    self.sharedInstance.currentAddress = address
                }
                block(placemarks: placeMarks as? [CLPlacemark], error: error)
            }
        })
    }
}

public extension LocationKit {
    
    internal class func geocodeAddressString(address: String, block: geocodeResultBlock) {
        sharedInstance.geoCoder.geocodeAddressString(address, completionHandler: { (placemarks: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                block(placemarks: nil, error: error)
            }
            else {
                block(placemarks: placemarks as? [CLPlacemark], error: error)
            }
        })
    }
    
    internal class func reverseGeocodeLocation(location: CLLocation, block: geocodeResultBlock) {
        sharedInstance.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                block(placemarks: nil, error: error)
            }
            else {
                block(placemarks: placemarks as? [CLPlacemark], error: error)
            }
        })
    }
    
    internal class func reverseGeocodeCurrentLocation(block: geocodeResultBlock) {
        reverseGeocodeLocation(sharedInstance.currentLocation, block: block)
    }
    
    internal class func reverseGeocodeCoordinates(coord: CLLocationCoordinate2D, block: geocodeResultBlock) {
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        reverseGeocodeLocation(location, block: block)
    }
    
    internal class func reverseGeocodeLatitude(latitude: CLLocationDegrees, longitude: CLLocationDegrees, block: geocodeResultBlock) {
        let coord = CLLocationCoordinate2DMake(latitude, longitude)
        reverseGeocodeCoordinates(coord, block: block)
    }
    
    internal class func cancelGeocode() {
        sharedInstance.geoCoder.cancelGeocode()
    }
}

public extension LocationKit {
    
    internal class func startUpdatingLocation(block: updateLocationResultblock) {
        let instance = sharedInstance
        if !instance.isUpdatingLocation {
            instance.isUpdatingLocation = true
            instance.locationManager.startUpdatingLocation()
            instance.blockUpdateLocation = block
        }
    }
    
    internal class func updateLocationOnce(block: updateLocationResultblock) {
        sharedInstance.isUpdatingLocationOnce = true
        startUpdatingLocation(block)
    }
    
    internal class func stopUpdatingLocation() {
        let instance = sharedInstance
        instance.isUpdatingLocationOnce = false
        instance.isUpdatingLocation = false
        instance.locationManager.stopUpdatingLocation()
    }
    
    internal class func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        updateCurrentLocationAndNotify(locations as! [CLLocation])
    }
    
    internal class func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let locations = [oldLocation, newLocation]
        updateCurrentLocationAndNotify(locations)
    }
    
    internal class func updateCurrentLocationAndNotify(locations: [CLLocation]) {
        let instance = sharedInstance
        if !instance.isUpdatingLocation {
            return
        }
        if instance.isUpdatingLocationOnce {
            stopUpdatingLocation()
        }
        instance.currentLocation = locations.last!
        instance.blockUpdateLocation(location: instance.currentLocation, error: nil)
    }
    
    internal class func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let instance = sharedInstance
        if instance.isUpdatingLocationOnce {
            stopUpdatingLocation()
        }
        instance.blockUpdateLocation(location: nil, error: error)
    }
}

public extension LocationKit {
    
    internal class func distanceFromLocation(from: CLLocation, toLocation to:CLLocation) -> CLLocationDistance {
        return to.distanceFromLocation(from)
    }
    
    internal class func distanceFromCurrentLocationToLocation(to: CLLocation) -> CLLocationDistance {
        return distanceFromLocation(sharedInstance.currentLocation, toLocation: to)
    }
}
