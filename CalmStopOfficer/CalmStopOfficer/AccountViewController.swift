//
//  AccountViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 2/17/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var officerNameLabel: UILabel!
    @IBOutlet weak var officerBadgeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

//    @IBAction func logOut(_ sender: UIButton) {
//        do{
//            try FIRAuth.auth()?.signOut()
//        }catch let logoutError{
//            print (logoutError)
//        }
//        
//        backToInitialView()
//    }
    
    private func backToInitialView(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "initialScreenVC") as! UIViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        profileImage.image = #imageLiteral(resourceName: "officer_jones")
//        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
//        profileImage.clipsToBounds = true
//        downloadProfileImage()
        getOfficerInfo()
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getOfficerInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let titles = ["Profile", "Help", "About Us", "Settings", "Logout"]
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (titles.count)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AccountTableViewCell
        
        cell.title.text = titles[indexPath.row]
//        cell.arrow.image = #imageLiteral(resourceName: "ExpandArrow")
        
        return (cell)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == 0 {
            performSegue(withIdentifier: "profileSegue", sender: nil)
        }
        
        if indexPath.row == 1 {
            performSegue(withIdentifier: "helpSegue", sender: nil)
        }
        
        if indexPath.row == 2 {
            performSegue(withIdentifier: "aboutUsSegue", sender: nil)
        }
        
        if indexPath.row == 3 {
            performSegue(withIdentifier: "settingsSegue", sender: nil)
        }
        
        if indexPath.row == 4 {
            do{
                try FIRAuth.auth()?.signOut()
                
                var alert = UIAlertView()
                alert.delegate = self
                alert.title = "Logout"
                alert.message = "You've been Logged Out!"
                alert.addButton(withTitle: "OK")
                alert.show()
                
            }catch let logoutError{
                print (logoutError)
            }
            
            backToInitialView()
        }
     
        self.tableView.deselectRow(at: indexPath, animated: true)

    }
    
    func downloadProfileImage(path: String){
        let database = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference()
        let profile = storage.child(path)
        
        
        // Download Images
        profile.data(withMaxSize: 1*1000*10000) { (data, error) in
            if error == nil {
                self.profileImage.image = UIImage(data: data!)
                self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
                self.profileImage.clipsToBounds = true
            }
            else {
                print(error?.localizedDescription)
            }
        }
    }
    
    // Gets name and badge number
    func getOfficerInfo(){
        let uid = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let first_name = (dictionary["first_name"] as? String) ?? ""
                let last_name = (dictionary["last_name"] as? String) ?? ""
                let badge_number = (dictionary["badge_number"] as? String) ?? ""
                let profileImagePath = dictionary["photo"] as? String
                
                self.downloadProfileImage(path: profileImagePath!)


                self.officerNameLabel.text = "Officer " + first_name + " " + last_name
                self.officerBadgeLabel.text = "#" + badge_number
            }
            
        })

    }
    
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
//        
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
