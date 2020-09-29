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
    var ref: DatabaseReference!
    var currentUser = Auth.auth().currentUser
    let encryptorDecryptor = EncryptorDecryptor(mode: "AlbumPhoto")
    let firebaseAuth = Auth.auth()
    @IBOutlet weak var usernameTextField: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField.text = firebaseAuth.currentUser?.email
    }
    

    // MARK: Actions
    
    @IBAction func decoyPasswordSetUp(_ sender: Any) {
        let alert = UIAlertController(title: "Decoy Password", message: "Enter decoy password.", preferredStyle: .alert)
        alert.addTextField{ (textfield:UITextField) in
            textfield.placeholder = "decoy password"
            
        }
        
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [self] (action:UIAlertAction) in
            //extract values
            let decoyPwd =  alert.textFields![0]
            
            var email = currentUser!.email!
            let toremove: Set<Character> = [".", "#", "$", "[", "]", "@"]
            email.removeAll(where: { toremove.contains($0) })
            
            //check for empty fields
            if(decoyPwd.text!.isEmpty){
                self.displayAlertMessage(userMessage: "All fields are required.")
                return
            }
            else{
                // ENCRYPT PWD
                let encryptedDecoyPwd = encryptorDecryptor.encryptString(string: decoyPwd.text!)
                
                // store decoy Pwd
                self.ref = Database.database().reference()
                let childUpdates = ["decoyPwd": encryptedDecoyPwd, "decoy": "yes"]
                self.ref.child("users").child(email).updateChildValues(childUpdates)
            }
        }))
        self.present(alert, animated:true)
        
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
    
    // DISPLAY ALERTS
    func displayAlertMessage(userMessage: String){
        let myAlert = UIAlertController(title: "Error", message: userMessage, preferredStyle: UIAlertController.Style.alert);
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil);
        
        myAlert.addAction(okAction);
        
        self.present(myAlert, animated:true, completion:nil);
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
