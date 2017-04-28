//
//  StopsTableViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 4/27/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import MapKit
import Firebase

struct cellData {
    let dateTime: String!
    let driver: String!
    let mapRegion: MKCoordinateRegion!
    let mapAnnotation: MKPointAnnotation!
}

class StopsTableViewController: UITableViewController {
    
    
    
    // Load From Firebase
    let cellId = "cellId"
    var arrayOfCellData = [cellData]()
    var arrayStopData = [Stop]()

    
    func observeStops(){
        let stop_id = "temp_stop_id"
        let uid = FIRAuth.auth()?.currentUser?.uid
        let stopsRef = FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("stops")

        stopsRef.observe(.childAdded, with: { (snapshot) in
            print ("Key: ", snapshot.key)
            let stopId = snapshot.key
            let stopRef = FIRDatabase.database().reference().child("stops").child(stopId)
            
            stopRef.observe(.value, with: { (snapshot) in
                print("Value: ", snapshot)
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let stop = Stop(dictionary: dictionary)
                // Potential of crashing if keys don't match
                stop.setValuesForKeys(dictionary)
                
                self.arrayStopData.append(stop)
                print(stop.lat ?? "Nao tem Content")
                
                // Load data on table
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
//                    let indexPath = IndexPath(item: self.arrayStopData.count - 1, section: 0)
//                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                })
            }, withCancel: nil)
            
        }, withCancel: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(36.969295, -122.036977)
        let location2: CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.730030, -122.442368)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        let region2:MKCoordinateRegion = MKCoordinateRegionMake(location2, span)
        
        let annotation = MKPointAnnotation()
        let annotation2 = MKPointAnnotation()

        annotation.coordinate = location
        annotation2.coordinate = location2

        
        arrayOfCellData = [cellData(dateTime: "10/30/16, 6:17 PM" ,driver: "Bernie Sanders", mapRegion: region, mapAnnotation: annotation),
                           cellData(dateTime: "09/29/15, 5:45 AM" ,driver: "Martha Stevenson", mapRegion: region2, mapAnnotation: annotation2),
                           cellData(dateTime: "07/09/14, 5:47 PM" ,driver: "Carlos Maltazan", mapRegion: region, mapAnnotation: annotation),
                           cellData(dateTime: "0/10/13, 8:45 AM" ,driver: "Andre Mineapolis", mapRegion: region, mapAnnotation: annotation),
                           cellData(dateTime: "05/05/12, 10:20 AM" ,driver: "Maria Cardozo", mapRegion: region, mapAnnotation: annotation)]
        
        observeStops()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayStopData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell
        
        // Data for map
        let lat = (arrayStopData[indexPath.row].lat! as NSString).doubleValue as CLLocationDegrees
        let long = (arrayStopData[indexPath.row].long! as NSString).doubleValue as CLLocationDegrees
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat,long)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        
        cell.mapView.setRegion(region, animated: true)
        cell.mapView.addAnnotation(annotation)
        cell.dataTimeLabel.text = arrayStopData[indexPath.row].date! + ", " + arrayStopData[indexPath.row].time!
        
        // Get citizen name 
        FIRDatabase.database().reference().child("citizen").child(arrayStopData[indexPath.row].citizenID!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let name = dictionary["first_name"] as? String
                cell.driverNameLabel.text = "Driver " + name!
            }
        })
        
        return cell
        
        // Configure the cell...
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 266
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showStop", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "showStop"){
//            var upcoming: NewViewController = segue.destinationViewController as! NewViewController
//            
            let indexPath = self.tableView.indexPathForSelectedRow!
//
//            let titleString = self.objects.objectAtIndexPath(indexPath.row) as? String
//            
//            upcoming.titleString = titleString
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
