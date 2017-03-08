//
//  HistoryViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 2/27/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let dateAndTime = ["10/30/16, 6:17 PM", "09/29/15, 5:45 AM", "07/09/14, 5:47 PM", "10/10/13, 8:45 AM", "05/05/12, 10:20 AM"]
    let driversName = ["Bernie Sanders", "Martha Stevenson", "Carlos Maltazan", "Andre Mineapolis", "Maria Cardozo"]

    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dateAndTime.count)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mapCell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! HistoryTableViewCell
        
        mapCell.mapImage.image = #imageLiteral(resourceName: "MapSample")
        mapCell.driversNameLabel.text = "Driver " + driversName[indexPath.row]
        mapCell.dateAndTimeLabel.text = dateAndTime[indexPath.row]
        mapCell.separatorImage.image = #imageLiteral(resourceName: "Separator")
        
        return (mapCell)
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
