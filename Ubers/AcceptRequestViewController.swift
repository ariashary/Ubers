//
//  AcceptRequestViewController.swift
//  Ubers
//
//  Created by Muhammad Ashary on 11/10/19.
//  Copyright © 2019 M. Ashary. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class AcceptRequestViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    
    var requestLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        map.addAnnotation(annotation)
    }
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        // Update the ride request
        Database.database().reference().child("rideRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat": self.driverLocation.latitude, "driverLon": self.driverLocation.longitude])
            Database.database().reference().child("rideRequests").removeAllObservers()
        }
        
        // Give Direction
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let mPlaceMark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: mPlaceMark)
                    mapItem.name = self.requestEmail
                    let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
    }
    
}
