//
//  UserProfileViewController.swift
//  VaultApp
//
//  Created by Nashita Abd Guntaguli on 9/28/20.
//  Copyright © 2020 Nashita Abd Guntaguli. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController {
    
    // MARK: Properties
    let firebaseAuth = Auth.auth()
    @IBOutlet weak var usernameTextField: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameTextField.text = firebaseAuth.currentUser?.email
    }
    

    
    @IBAction func signOutButtonClicked(_ sender: Any) {
        do {
            try firebaseAuth.signOut()
            let alert = UIAlertController(title: "Success", message: "You have been signed out.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default){(_) in
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "SplashScreen")
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
                
            }
            alert.addAction(okAction)
            self.present(alert, animated:true)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
          
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
