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
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var alrRegisteredButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.delegate = self
        pwdTextField.delegate = self
        confirmPwdTextField.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))

        
        // EMAIL TEXT FIELD BORDER
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: emailTextField.frame.size.height, width: emailTextField.frame.size.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        emailTextField.borderStyle = UITextField.BorderStyle.none
        emailTextField.layer.addSublayer(bottomLine)
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        emailTextField.textColor = UIColor.white
        
        
        // PWD TEXT FIELD BORDER
        let bottomLine2 = CALayer()
        bottomLine2.frame = CGRect(x: 0.0, y: pwdTextField.frame.size.height, width: pwdTextField.frame.size.width, height: 1.0)
        bottomLine2.backgroundColor = UIColor.white.cgColor
        pwdTextField.borderStyle = UITextField.BorderStyle.none
        pwdTextField.layer.addSublayer(bottomLine2)
        pwdTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        pwdTextField.textColor = UIColor.white
        
        // EMAIL TEXT FIELD BORDER
        let bottomLine3 = CALayer()
        bottomLine3.frame = CGRect(x: 0.0, y: confirmPwdTextField.frame.size.height, width: confirmPwdTextField.frame.size.width, height: 1.0)
        bottomLine3.backgroundColor = UIColor.white.cgColor
        confirmPwdTextField.borderStyle = UITextField.BorderStyle.none
        confirmPwdTextField.layer.addSublayer(bottomLine3)
        confirmPwdTextField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        confirmPwdTextField.textColor = UIColor.white
        
        signUpButton.layer.borderWidth = 0.5
        signUpButton.layer.borderColor = UIColor.white.cgColor
        
        alrRegisteredButton.layer.borderWidth = 0.5
        alrRegisteredButton.layer.borderColor = UIColor.white.cgColor
        
        
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
                self.createDatabaseRef(userEmail: userEmail)
                Auth.auth().currentUser!.sendEmailVerification(completion: { (error) in})
                
                // Display Alert Message with Confirmation, similar alert, but we need to implement the handler
                self.displayAlertMessage(title: "Account Created", userMessage: "Please verify your email by confirming the sent link.", handler: self.goBackToLogIn)
                print("User created")
                
            }
        }
    }
    
    func createDatabaseRef(userEmail: String){
        // store decoy Pwd
        var email = userEmail
        let toremove: Set<Character> = [".", "#", "$", "[", "]", "@"]
        email.removeAll(where: { toremove.contains($0) })
        let ref = Database.database().reference()
        ref.child("users").child(email).setValue(["decoy": "no"])
        
    }
    
    func goBackToLogIn (action : UIAlertAction) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        controller.modalPresentationStyle = .fullScreen
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
