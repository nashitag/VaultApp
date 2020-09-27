//
//  RegistrationViewController.swift
//  VaultApp
//
//  Created by Nashita Abd Guntaguli on 9/24/20.
//  Copyright © 2020 Nashita Abd Guntaguli. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate   {

    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var confirmPwdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.delegate = self
        pwdTextField.delegate = self
        confirmPwdTextField.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func signUpClicked(_ sender: UIButton) {
        
        let userEmail = emailTextField.text!;
        let userPwd = pwdTextField.text!;
        let userRepeatPwd = confirmPwdTextField.text!;
        
        
        //Check for empty fields
        if(userEmail.isEmpty || userPwd.isEmpty || userRepeatPwd.isEmpty){
            displayAlertMessage(title: "Error", userMessage: "All fields are required.");
            return; //we do not want user to continue
        }
        
        //Check for pwd match
        if(userPwd != userRepeatPwd){
            displayAlertMessage(title: "Error", userMessage: "Passwords do not match.");
            return; //we do not want user to continue
        }
        
        // check is pwd is at least 6 characters
        if(userPwd.count<6){
            displayAlertMessage(title: "Error", userMessage: "Passwords should be at least 6 characters.");
            return; //we do not want user to continue
        }
        
        // create user and store data
        Auth.auth().createUser(withEmail: userEmail, password: userPwd) { (user, error) in
//            let err = error
//            print(err)
            if error != nil{
                // user exists
                print("Email has been used, try a different one")
                self.displayAlertMessage(title: "Error", userMessage: "User exists.Please use another email or sign in.")
            }else{
                
                Auth.auth().currentUser!.sendEmailVerification(completion: { (error) in})
                
                // Display Alert Message with Confirmation, similar alert, but we need to implement the handler
                self.displayAlertMessage(title: "Account Created", userMessage: "Please verify your email by confirming the sent link.", handler: self.goBackToLogIn)
                print("User created")
                
            }
        }
    }
    
    func goBackToLogIn (action : UIAlertAction) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(controller, animated: true, completion: nil)
    }
    
    func displayAlertMessage(title: String, userMessage: String, handler: ((UIAlertAction) -> Void)? = nil){
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertController.Style.alert);
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: handler);
        myAlert.addAction(okAction);
        
        self.present(myAlert, animated:true, completion:nil);
    }
    
    
    // BACKEND FUNCTION - CREATE STORAGE Reference
    func createStorage(){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("images")
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
