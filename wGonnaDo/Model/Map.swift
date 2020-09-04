//
//  map.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 10.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import GoogleMaps

struct Map {
    var mapView: GMSMapView?
    private let defaultLocation: CLLocation = CLLocation(latitude: 20.01, longitude: 30.97)
    
    public mutating func initMap (toView: UIViewController) {
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude, zoom: 15.00)
        
        self.mapView = GMSMapView.map(withFrame: toView.view.bounds, camera: camera)
        self.mapView?.isHidden = true
        self.mapView?.settings.myLocationButton = true
        self.mapView?.settings.compassButton = true
        self.mapView?.isMyLocationEnabled = true
        // If enabled, users may double tap, two-finger tap, or pinch to zoom the camer
        self.mapView?.settings.zoomGestures = true
        // If enabled, users may use a two-finger vertical down or up swipe to tilt the camera.
        self.mapView?.settings.tiltGestures = true
        
        //mapView.setMinZoom(10, maxZoom: 15) -> you can set max and min value for zooming
        
        // Animate the camera moving to a new location.
        self.mapView?.animate(toViewingAngle: 45)
        self.mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        toView.view.addSubview(self.mapView!)
    }
}


/*
 Finally, the GMSCameraUpdate object allows you to specify a new view for the camera, and choose whether to snap-to or animate-to that view. You can update the view by passing a new GMSCameraUpdate object to GMSMapView's moveCamera method. This can be useful when you want to modify the camera to fit predefined bounds
 
 let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
 mapView.moveCamera(update)

 */
