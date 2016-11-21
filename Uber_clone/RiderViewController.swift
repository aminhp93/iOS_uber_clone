//
//  RiderViewController.swift
//  Uber_clone
//
//  Created by Minh Pham on 11/20/16.
//  Copyright © 2016 Minh Pham. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    
    var riderRequestActive = true
    
    var driverOnTheWay = false
    
    var userLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var callAnUber: UIButton!
    
    @IBAction func callAnUber(_ sender: Any) {
        
        if riderRequestActive {
            callAnUber.setTitle("Call An Uber", for: [])
            
            riderRequestActive = false
            
            let query = PFQuery(className: "riderRequest")
            
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            print(query)
            
            print((PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let objects = objects {
                    for i in objects{
                        print("Deleted Uber")
                        i.deleteInBackground()
                    }
                }
            })
            
            
        } else {
        
        if userLocation.latitude != 0 && userLocation.longitude != 0 {
            
            riderRequestActive = true
            
            let riderRequest = PFObject(className: "riderRequest")
        
            riderRequest["username"] = PFUser.current()?.username
        
            riderRequest["location"] = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
            
            riderRequest.saveInBackground(block: { (success, error) in
                if success {
                    print("Called an Uber")
                    self.callAnUber.setTitle("Cancel Uber", for: [])
                } else {
                    
                    self.callAnUber.setTitle("Call An Uber", for: [])
                    
                    self.riderRequestActive = false
                    
                    self.displayAlert(title: "Could not call Uber", message: "Please try again")
                    
                }
            })
            
        } else {
            displayAlert(title: "Could bot call Uber", message: "Cannot detect your location")
        }
        }
    }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate{
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            if driverOnTheWay == false {
            
                let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                self.mapView.setRegion(region, animated: true)
                
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = userLocation
                
                annotation.title = "Your location"
            
                self.mapView.addAnnotation(annotation)
            }
        
            
            let query = PFQuery(className: "RiderRequest")
            
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: { (objects, error) in
                if let riderRequests = objects {
                    for i in riderRequests{
                        print("Deleted Uber")
                        i["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                        i.saveInBackground()
                    }
                }
            })
        }
        
        if riderRequestActive == true{
            let query = PFQuery(className: "riderRequest")
            query.whereKey("username", equalTo: PFUser.current()?.username)
            
            query.findObjectsInBackground(block: { (objects, error) in
                if let riderRequests = objects {
                    for i in riderRequests {
                        if let driverUsername = i["driverResponsed"]{
                            let query = PFQuery(className: "driverLocation")
                            query.findObjectsInBackground(block: { (objects, error) in
                                if let driverLocations = objects {
                                    for j in driverLocations {
                                        if let driverLocation = i["location"] as? PFGeoPoint {
                                            
                                            self.driverOnTheWay = true
                                            
                                            let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                            
                                            let riderCLLocation = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                                            
                                            let distance = riderCLLocation.distance(from: driverCLLocation) / 1000
                                            
                                            let roundedDistance = round(distance*100)/100
                                            
                                            self.callAnUber.setTitle("Driver is \(roundedDistance)km away", for: [])
                                            
                                            let latDelta = abs(driverLocation.latitude - self.userLocation.latitude) * 2 + 0.005
                                            let lonDelta = abs(driverLocation.longitude - self.userLocation.longitude) * 2 + 0.005
                                            
                                            let region = MKCoordinateRegion(center: self.userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
                                            
                                            self.mapView.removeAnnotations(self.mapView.annotations)
                                            
                                            self.mapView.setRegion(region, animated: true)
                                            
                                            let userLocationAnnotation = MKPointAnnotation()
                                            
                                            userLocationAnnotation.coordinate = self.userLocation
                                            
                                            userLocationAnnotation.title = "Your location"
                                            
                                            self.mapView.addAnnotation(userLocationAnnotation)
                                            
                                            let driverLocationAnnotation = MKPointAnnotation()
                                            
                                            driverLocationAnnotation.coordinate = CLLocationCoordinate2D(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                            
                                            driverLocationAnnotation.title = "Your driver"
                                            
                                            self.mapView.addAnnotation(driverLocationAnnotation)
                                            
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            })
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logoutSegue"{
            
            locationManager.stopUpdatingLocation()
            PFUser.logOut()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        callAnUber.isHidden = true
        
        let query = PFQuery(className: "RiderRequest")
        
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground(block: { (objects, error) in
            
            if let riderRequests = objects {
                if riderRequests.count > 0 {
                    self.riderRequestActive = true
                    self.callAnUber.setTitle("Cancel Uber", for: [])
                }
            }
            self.callAnUber.isHidden = false
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func displayAlert(title:String, message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
