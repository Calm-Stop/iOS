//
//  RatingsViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 2/21/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit

class RatingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var stars: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func slider(_ sender: UISlider) {
        
        let sliderRating = (5 * sender.value)
        print (sender.value)
        let ratingValue = sliderRating
        rating.text = String(format: "%.2f", ratingValue)
        let widthValue = (176 * ratingValue)/5
  
        stars.frame = CGRect(x: 99 , y: 119 , width: Int(widthValue) , height: 40);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140

        

    }
    
    let comments = ["“Officer Jones was really respectfull and let me go with just a warning.”","“He was really nice!”", "“Officer Jones was really polite and helped me fixing my car.”", "“Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.”"]
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (comments.count)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RatingsTableViewCell
        
        cell.commentsLabel.text = comments[indexPath.row]
        
        return (cell)
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
