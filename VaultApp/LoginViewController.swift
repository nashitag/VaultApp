//
//  LoginViewController.swift
//  VaultApp
//
//  Created by Nashita Abd Guntaguli on 9/24/20.
//  Copyright © 2020 Nashita Abd Guntaguli. All rights reserved.
//

import UIKit
import Firebase
import Keys

class LoginViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate  {
    
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        let keys = VaultAppKeys()
        let key1 = (keys.encryptionKeyForAlbumPin)
        let key2 = (keys.encryptionKeyForPhotos)
        print("CHECKING KEYS", key1, key2)
    }
    
    // MARK: Actions
    @IBAction func signInClicked(_ sender: UIButton) {
        
        let email = emailTextField.text!
        let password = pwdTextField.text!
        
        //check empty fields
        if(email.isEmpty || password.isEmpty){
            print("All fields are required.")
//             displayAlertMessage(userMessage: "All fields are required.")
            
            //COMMENT OUT
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MainGallery")
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
            
            
        }
        else{
            Auth.auth().signIn(withEmail: email, password: password){ (user, error) in
//                let err = error
//                print(err)
                if let user = Auth.auth().currentUser {
                    if !user.isEmailVerified{
                        // ask to verify
                        print("ask to verify")
                        self.displayAlertEmailVerification(user: user, email: email)
                        
                    } else if error == nil {
                        // verified, TO DO: Notify signing in
                        print ("Email verified. Signing in...")
                        
                        // GO TO GALLERY
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "MainGallery")
                        controller.modalPresentationStyle = .fullScreen
                        self.present(controller, animated: true, completion: nil)
                    } else {
                        // wrong email or password
                         print("wrong email or password")
                        self.displayAlertMessage(userMessage: "Log In Failed. Please enter your email or password correctly.")
                    }
                }else{
                    self.displayAlertMessage(userMessage: "Please sign up first.")
                }
                
            }
        }
    }
    
    func displayAlertMessage(userMessage: String){
        let myAlert = UIAlertController(title: "Error", message: userMessage, preferredStyle: UIAlertController.Style.alert);
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil);
        
        myAlert.addAction(okAction);
        
        self.present(myAlert, animated:true, completion:nil);
    }
    
    func displayAlertEmailVerification(user: User, email: String){
        let alert_verification = UIAlertController(title: "Error", message: "Sorry. Your email address has not yet been verified. Do you want us to send another verification email to " + email + "?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) {
            (_) in
            user.sendEmailVerification(completion: { (error) in
            })
        }
        
        alert_verification.addAction(okAction)
        self.present(alert_verification, animated: true, completion: nil)
        
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
