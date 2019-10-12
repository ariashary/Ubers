//
//  DriverTableViewController.swift
//  Ubers
//
//  Created by Muhammad Ashary on 11/10/19.
//  Copyright © 2019 M. Ashary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var rideRequest: [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Database.database().reference().child("rideRequests").observe(.childAdded) { (snapshot) in
            if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
                if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                    
                } else {
                    self.rideRequest.append(snapshot)
                    self.tableView.reloadData()
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = manager.location?.coordinate {
            driverLocation = coordinate
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideRequest.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RideRequestCell", for: indexPath)

        let snapshot = rideRequest[indexPath.row]
        
        if let rideRequestDictionary = snapshot.value as? [String: AnyObject],
            let email = rideRequestDictionary["email"] as? String,
            let lat = rideRequestDictionary["lat"] as? Double,
            let lon = rideRequestDictionary["lon"] as? Double {
                let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                let riderCLLocation = CLLocation(latitude: lat, longitude: lon)
                let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
                let rounderDistance = round(distance * 100) / 100
            
                cell.textLabel?.text = "\(email) - \(rounderDistance)km away"
            }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = rideRequest[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptViewController = segue.destination as? AcceptRequestViewController {
            if let snapshot = sender as? DataSnapshot {
                if let rideRequestDictionary = snapshot.value as? [String: AnyObject],
                    let email = rideRequestDictionary["email"] as? String,
                    let lat = rideRequestDictionary["lat"] as? Double,
                    let lon = rideRequestDictionary["lon"] as? Double {
                    acceptViewController.requestEmail = email
                    let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    acceptViewController.requestLocation = location
                    acceptViewController.driverLocation = driverLocation
                }
            }
        }
    }
}
