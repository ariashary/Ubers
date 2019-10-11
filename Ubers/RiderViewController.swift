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
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            userLocation = center
            
            map.setRegion(region, animated: true)
            map.removeAnnotations(map.annotations)
            
            let anotation = MKPointAnnotation()
            anotation.coordinate = center
            anotation.title = "Your Location"
            map.addAnnotation(anotation)
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callUberButtonTapped(_ sender: Any) {
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
