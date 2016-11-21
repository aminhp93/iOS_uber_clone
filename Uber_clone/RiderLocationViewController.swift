//
//  RiderLocationViewController.swift
//  Uber_clone
//
//  Created by Minh Pham on 11/21/16.
//  Copyright © 2016 Minh Pham. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderLocationViewController: UIViewController, MKMapViewDelegate {
    
    var requestLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var requestUsername = ""
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var acceptButton: UIButton!
    
    @IBAction func acceptRequestButton(_ sender: Any) {
    
        let query = PFQuery(className: "riderRequest")
        
        query.whereKey("username", equalTo: requestUsername)
        
        query.findObjectsInBackground { (objects, error) in
            if let riderRequests = objects{
                for i in riderRequests{
                    
                    i["driverResponsed"] = PFUser.current()?.username
                    i.saveInBackground()
                    
                    let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                    
                    CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
                        if let placemarks = placemarks {
                            if placemarks.count > 0 {
                                let mKPlacemark = MKPlacemark(placemark: placemarks[0])
                                let mapItem = MKMapItem(placemark: mKPlacemark)
                                mapItem.name = self.requestUsername
                                let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                                
                                mapItem.openInMaps(launchOptions: launchOptions)
                            }
                        }
                    })
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(requestLocation)
        // Do any additional setup after loading the view.
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = requestLocation
        
        annotation.title = requestUsername
        
        mapView.addAnnotation(annotation)
        
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

}
