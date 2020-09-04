//
//  UMapViewController.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 6.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//
import UIKit
import MapKit
import GoogleMaps
import GooglePlaces
import Firebase
class PMainViewController: UIViewController{
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    //Map which is going to display on main screen
    private var map:Map!
    
    private let db = Firestore.firestore()
    private let currentUser = Auth.auth().currentUser
    //Array of current events
    private var events: [Event] = []
    // Array for whole events id which appears in map
    private var docID: [String] = []
    // Index for doc id array, whenever marker created dictionary will have item of docID[indexForId]
    private var indexForId = -1
    // Dictionary for
    private var dictEvents: [GMSMarker:String] = [:]
    // Id which is going to pass segue
    private var idToPass: String?
    // Event which is going to pass segue
    private var eventToPass: Event?
    // deneme amaclı yapıyorum işe yararsa düzelticem
    private let green = GMSMarker.markerImage(with: .green)
    private let lightText = GMSMarker.markerImage(with: .lightText)
    
    @IBOutlet weak var searchBar: UISearchBar!
    //    private var coder: GMSGeocoder? -> REVERT COORDINATE TO HUMAN READABLE STREET ADRESS
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        // map will be initiliazed
        map = Map()
        // to be aware of events, we set viewController as a delegate
        
        map?.initMap(toView: self)
        map?.mapView?.delegate = self
//        self.view.addSubview(searchBar)
//        searchBar.isHidden = false
        getAllEvents()
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//
//    }
    
    
    private func getAllEvents() {
        db.collection(K.CollectionType.events).whereField(K.Events.status, isEqualTo: true).addSnapshotListener { (snapshot, error) in
            if error != nil {
                print(error)
            }else {
                // With this mapview.clear function whenever something happened in our database it will update itself.
                self.map.mapView?.clear()
                if let snapshotDocuments = snapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        self.docID.append(doc.documentID)
                        //                        self.indexForId += 1
                        if let name = data[K.Events.name] as? String, let owner = data[K.Events.owner] as? String, let startDate = data[K.Events.startDate] as? String, let endDate = data[K.Events.endDate] as? String, let point = data[K.Events.point] as? Int, let description = data[K.Events.description] as? String, let address = data[K.Events.address] as? String, let participants = data[K.Events.participants] as? Array<Any>, let location = data[K.Events.location] as? GeoPoint, let status = data[K.Events.status] as? Bool, let creationDate = data[K.Events.creationDate] as? TimeInterval, let photoUrl = data[K.Events.photoUrl] as? String{
                            let event = Event(name: name, owner: owner, address: address, startDate: startDate, endDate: endDate, status: status, location: location, description: description, point: point, creationDate: creationDate, participants: participants,photoUrl: photoUrl)
                            self.events.append(event)
                            DispatchQueue.main.async {
                                self.createEventMarkers(to: event)
                            }
                            
                            
                        }
                    }
                }
            }
        }
    }
    
    private func createEventMarkers(to: Event) {
        self.indexForId += 1
        let position = CLLocationCoordinate2D(latitude: to.location.latitude, longitude: to.location.longitude)
        let eventMarker = GMSMarker(position: position)
        eventMarker.title = to.name
        eventMarker.snippet = to.description
        if let participants = to.participants as? [String]{
            if participants.contains(currentUser!.email!){
                eventMarker.icon = self.green
            }else{
                eventMarker.icon = self.lightText
            }
        }
        // now we have our dictionary with event markes, doc id pair well done !
        self.dictEvents[eventMarker] = self.docID[indexForId]
        eventMarker.map = self.map.mapView
        
        
    }
    
    
}

//MARK: CLLocation Manager Delegates
extension PMainViewController: CLLocationManagerDelegate {
    // Camera position will adjust according to user's current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude, zoom: 10.00)
        
        if map?.mapView != nil && map!.mapView!.isHidden {
            map?.mapView?.isHidden = false
            map?.mapView?.camera = camera
        }else{
            map?.mapView?.animate(to: camera)
        }
    }
    
    // If there is any change on authorization, delegate method detects and print which error accur
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location accsess was restriced.")
        case .denied:
            print("Location permission was denied.")
            // in the case of denied display mapView at the default location
            map?.mapView?.isHidden=false
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
}

//MARK: GMSMapviewDelegate
extension PMainViewController: GMSMapViewDelegate {
    // In this session we are trying to get eventID from tapping marker
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // get event which is match with current marker
        print(marker.icon!)
        print(dictEvents[marker]!)
                if(marker.icon == self.green) {
                    let alert = UIAlertController(title: "Already enrolled", message: "You already enrolled to the \(marker.title)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(ok)
                    present(alert,animated: true,completion: nil)
                }else if marker.icon == self.lightText{
                    for e in events{
                               if e.name == marker.title && e.description == marker.snippet {
                                   self.eventToPass = e
                                   self.idToPass = dictEvents[marker]
                                self.performSegue(withIdentifier: "joinEvent", sender: Any?.self)
                                break
                               }
                           }
                }
        
        
        return true
        
    }
    // Before perform segue we are trying to pass our eventID and event to JoinEventController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let idToPass = self.idToPass , segue.identifier == K.Segues.joinEvent{
            let VC = segue.destination as! PJoinEventViewController
            VC.passedEventID = idToPass
            VC.passedEvent = eventToPass
            VC.delegate = self
        }
    }
    
}


//MARK: delegate pattern

extension PMainViewController: JoinViewDelegate{
    func didTriggerViewDidLoad() {
        viewDidLoad()
    }
    
    
}
