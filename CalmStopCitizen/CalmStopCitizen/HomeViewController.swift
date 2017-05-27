//
//  HomeViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 5/27/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        }
    @IBAction func menuButtonTapped(_ sender: Any) {
        self.mm_drawerController.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
}
