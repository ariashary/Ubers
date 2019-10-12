//
//  RiderViewController.swift
//  Ubers
//
//  Created by Muhammad Ashary on 11/10/19.
//  Copyright © 2019 M. Ashary. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callAnUberButton: UIButton!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var ubersHasBeenCalled = false
    var driverOnTheWay = false
    var driverLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("rideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                self.ubersHasBeenCalled = true
                self.callAnUberButton.setTitle("Cancel Ubers", for: .normal)
                Database.database().reference().child("rideRequests").removeAllObservers()
                
                if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
                    if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                        if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            self.driverOnTheWay = true
                            self.displayDriverAndRider()
                            
                            if let email = Auth.auth().currentUser?.email {
                                Database.database().reference().child("RideRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged) { (snapshot) in
                                    if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
                                        if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                                            if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                                                self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                                self.driverOnTheWay = true
                                                self.displayDriverAndRider()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func displayDriverAndRider() {
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let rounderDistance = round(distance * 100) / 100
        callAnUberButton.setTitle("Your driver is \(rounderDistance)km away!", for: .normal)
        map.removeAnnotations(map.annotations)
        
        let latDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let lonDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.005
        
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        map.setRegion(region, animated: true)
        
        let riderAnno = MKPointAnnotation()
        riderAnno.coordinate = userLocation
        riderAnno.title = "Your Location"
        map.addAnnotation(riderAnno)
        
        let driverAnno = MKPointAnnotation()
        driverAnno.coordinate = driverLocation
        driverAnno.title = "Driver Location"
        map.addAnnotation(driverAnno)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            userLocation = center
            
            if ubersHasBeenCalled {
                displayDriverAndRider()
                
            } else {
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                map.setRegion(region, animated: true)
                map.removeAnnotations(map.annotations)
                
                let anotation = MKPointAnnotation()
                anotation.coordinate = center
                anotation.title = "Your Location"
                map.addAnnotation(anotation)
            }
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callUberButtonTapped(_ sender: Any) {
        if !driverOnTheWay {
            if let email = Auth.auth().currentUser?.email {
                if ubersHasBeenCalled {
                    ubersHasBeenCalled = false
                    callAnUberButton.setTitle("Call an Ubers", for: .normal)
                    Database.database().reference().child("rideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                        snapshot.ref.removeValue()
                        Database.database().reference().child("rideRequests").removeAllObservers()
                    }
                } else {
                    let rideRequestDictionary: [String: Any] = ["email": email, "lat": userLocation.latitude, "lon": userLocation.longitude]
                    Database.database().reference().child("rideRequests").childByAutoId().setValue(rideRequestDictionary)
                    ubersHasBeenCalled = true
                    callAnUberButton.setTitle("Cancel Ubers", for: .normal)
                }
            }
        }
    }
    

}
