//
//  RatingsViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 2/21/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import Firebase

class RatingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var stars: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func slider(_ sender: UISlider) {
        
        let sliderRating = (5 * sender.value)
        print (sender.value)
        let ratingValue = sliderRating
        rating.text = String(format: "%.2f", ratingValue)
        let widthValue = (170 * ratingValue + 4)/5
  
        stars.frame = CGRect(x: 99 , y: 119 , width: Int(widthValue) , height: 40);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkIfUserIsLoggedIn()
        print(comments.count)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140


    }
    
    //TODO: comments array is being updated but updated array isn't being loaded into table
    var comments = ["“Officer Jones was really respectfull and let me go with just a warning.”","“He was really nice!”", "“Officer Jones was really polite and helped me fixing my car.”", "“Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.”"]
    
    
    func checkIfUserIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("Not logged in!")
        } else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            // TODO: uid hardcoded b/c login is not real
//<<<<<<< HEAD
            FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("ratings").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let ratings = dictionary["average_rating"] as? Float
//=======
//            FIRDatabase.database().reference().child("officer").child("14567").child("Tl4pCcIjlxTXQgCcoLp4IB4Hzti2").child("ratings").observeSingleEvent(of: .value, with: { (snapshot) in
//                
//                if let dictionary = snapshot.value as? [String: AnyObject]{
//                    let ratings = dictionary["avg_rating"] as? Float
//>>>>>>> bf3f81a4c5bf4f516806ed258f35c905141e32eb
                    self.setRatings(ratings_average: ratings!)
                }
                
            })
            
//<<<<<<< HEAD
            FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("coments").observeSingleEvent(of: .value, with: {(snap) in
//=======
//            FIRDatabase.database().reference().child("officer").child("14567").child("Tl4pCcIjlxTXQgCcoLp4IB4Hzti2").child("comments").observeSingleEvent(of: .value, with: {(snap) in
//>>>>>>> bf3f81a4c5bf4f516806ed258f35c905141e32eb
                
                if let snapDict = snap.value as? [String:AnyObject]{
                    
                    for each in snapDict as [String:AnyObject]{
                        
                        var newComment = each.value["text"] as! String
                        newComment = "\"\(newComment)\""
                        self.comments.append(newComment)
//<<<<<<< HEAD
                        self.tableView.reloadData()
//=======
//>>>>>>> bf3f81a4c5bf4f516806ed258f35c905141e32eb
                    }
                }
                
            })
            

        }
    }
    
    func setRatings(ratings_average: Float){
        
        rating.text = String(format: "%.1f", ratings_average)
        let widthValue = (176 * ratings_average)/5
        
        stars.frame = CGRect(x: 99 , y: 119 , width: Int(widthValue) , height: 40);
        
    }
    


    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (comments.count)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(comments.count)
        
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
