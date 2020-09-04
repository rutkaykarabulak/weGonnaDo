//
//  EMainViewController.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 7.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
class EMainViewController: UIViewController {
    
    @IBOutlet weak var createEventButton: UIButton!
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    private var addressOfEvent: String?
    private var eventLocation: CLLocationCoordinate2D?
    private var eventMarker: GMSMarker?
    private var geocoder:GMSGeocoder?
    
    // Database components
    private let db = Firestore.firestore()
    private let currentUser = Auth.auth().currentUser!
    
    // Map which goes to initiliaze
    private var map: Map?
    
    private var deneme: Any = 0
    // array of event's locations
    private var events: [Event] = [Event(name: "", owner: "", address: "", startDate: "", endDate: "", status: true, location: GeoPoint(latitude: 0, longitude: 0), description: "")]
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        map = Map()
        // Location object has initiliazed
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = 50
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //map will be created
        map?.initMap(toView: self)
        map?.mapView?.delegate = self
        //button creation
        createEventButton.layer.cornerRadius = 15.00
        createEventButton.isEnabled = true
        self.view.addSubview(createEventButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getEventLocations()
        
    }
    
    // öncelikle eventlerin location özelliklerini getirelim.
    
    func getEventLocations() {
        events = []
        db.collection(K.CollectionType.events).whereField(K.Events.status, isEqualTo: true).whereField(K.Events.owner, isEqualTo: currentUser.email).addSnapshotListener { (snapshot, error) in
            if error != nil {
                print("can't read data from firebase \(error)")
            } else {
                // ekleme bu
                self.events = []
                self.map?.mapView?.clear()
                if let snapshotDocument = snapshot?.documents {
                    for doc in snapshotDocument{
                        let data = doc.data()
                        if let name = data[K.Events.name] as? String, let owner = data[K.Events.owner] as? String, let address = data[K.Events.address] as? String, let endDate = data[K.Events.endDate] as? String, let startDate = data[K.Events.startDate] as? String , let location = data[K.Events.location] as? GeoPoint, let description = data[K.Events.description] as? String, let status = data[K.Events.status] as? Bool, let point = data[K.Events.point] as? Int, let creationDate = data[K.Events.creationDate] as? TimeInterval, let participants = data["participants"] as? Array<Any>, let photoUrl = data[K.Events.photoUrl] as? String{
                            let event = Event(name: name, owner: owner, address: address, startDate: startDate, endDate: endDate, status: status, location: location, description: description, point: point, creationDate: creationDate,participants: participants,photoUrl: photoUrl)
                            self.events.append(event)
                            DispatchQueue.main.async {
                                self.createMarker(event: event)
                            }
                        }
                        
                    }
                }
            }
        }
        
    }
    
    func createMarker(event : Event) {
        //When user taps spesific location, this function will trigger and marker will created.
        let position = CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude)
        let markerOfEvent = GMSMarker(position: position)
        markerOfEvent.title = event.name
        markerOfEvent.snippet = event.description
        markerOfEvent.icon = GMSMarker.markerImage(with: .black)
        markerOfEvent.map = map?.mapView
    }
    
    @IBAction func createEventPressed(_ sender: UIButton) {
        if self.eventMarker == nil {
            let alert = UIAlertController(title: "None existing location", message: "Please select your location before you create an event", preferredStyle: .alert)
            let gotIt = UIAlertAction(title: "I got it", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(gotIt)
            present(alert, animated: true, completion: nil)
            return
        }
        // if marker == nil -> massage alert must be given
        
        let alert = UIAlertController(title: "Event Creation", message: "Do you want to create an event with selected location?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.performSegue(withIdentifier: K.Segues.createEventSegue, sender: self)
            self.eventMarker?.map = nil
        }
        
        let no = UIAlertAction(title: "No", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.createEventSegue {
            let VC = segue.destination as! EEventCreateViewController
            VC.address = self.addressOfEvent
            VC.eventLocation = self.eventLocation
        }
    }
}




//MARK: CLLocationDelegate Methods

extension EMainViewController: CLLocationManagerDelegate {
    // If authorization changed, error message will occur.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location accsess was restriced.")
        case .denied:
            print("Location permission was denied.")
            // in the case of denied display mapView at the default location
            map?.mapView?.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude, zoom: 10.00)
        
        if map?.mapView != nil && map!.mapView!.isHidden {
            map?.mapView?.isHidden = false
            map?.mapView?.camera = camera
        } else {
            map?.mapView?.animate(to: camera)
        }
        
    }
    
}

//MARK: GMSMapViewDelegate Methods

extension EMainViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.eventMarker?.map = nil
        self.eventLocation = coordinate
        self.geocoder = GMSGeocoder()
        geocoder?.reverseGeocodeCoordinate(coordinate, completionHandler: { (response, error) in
            if error != nil {
                print(error)
            }else{
                if let response = response?.firstResult() {
                    self.eventMarker = GMSMarker(position: coordinate)
                    self.eventMarker?.title = response.thoroughfare
                    self.eventMarker?.snippet = response.subLocality
                    self.eventMarker?.map = self.map?.mapView
                    self.addressOfEvent = response.lines![0]
                    print(self.addressOfEvent)
                    
                }
            }
        })
        
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
//        getEventLocations()
    }

}
