//
//  DriverViewController.swift
//  Uber_clone
//
//  Created by Minh Pham on 11/21/16.
//  Copyright © 2016 Minh Pham. All rights reserved.
//

import UIKit
import Parse

class DriverViewController: UITableViewController, CLLocationManagerDelegate {
    
    var requestUsername = [String]()
    var requestLocation = [CLLocationCoordinate2D]()
    var userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var locationManager = CLLocationManager()
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "driverLogoutSegue"{
            PFUser.logOut()
            self.navigationController?.navigationBar.isHidden = true
            locationManager.stopUpdatingLocation()
        } else if segue.identifier == "showRiderLocationViewController"{
            if let destination = segue.destination as? RiderLocationViewController{
                if let row = tableView.indexPathForSelectedRow?.row{
                    destination.requestLocation = requestLocation[row]
                    destination.requestUsername = requestUsername[row]
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location?.coordinate{
            let query = PFQuery(className: "riderRequest")
            
            userLocation = location
            
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
            
            query.limit = 10
            
            query.findObjectsInBackground(block: { (objects, error) in
                if let riderRequests = objects{
                    self.requestUsername.removeAll()
                    self.requestLocation.removeAll()
                    
                    for i in riderRequests{
                        if let username = i["username"] as? String{
                            
                            if i["driverResponsed"] == nil {
                                self.requestUsername.append(username)
                            
                                 self.requestLocation.append(CLLocationCoordinate2D(latitude: (i["location"] as! PFGeoPoint).latitude, longitude: (i["location"] as! PFGeoPoint).longitude))
                            }
                        }
                    }
                    self.tableView.reloadData()
                } else {
                    print("No result")
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return requestUsername.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        // Find distance between userLocation and requestLocation
        
        let driverCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        let riderCLLocation = CLLocation(latitude: requestLocation[indexPath.row].latitude, longitude: requestLocation[indexPath.row].longitude)
        
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        
        let roundedDistance = round(distance * 100)/100
        
        cell.textLabel?.text = requestUsername[indexPath.row] + " - \(roundedDistance)km away"
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
