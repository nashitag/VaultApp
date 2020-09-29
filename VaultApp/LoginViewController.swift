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
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    let encryptorDecryptor = EncryptorDecryptor(mode: "AlbumPhoto")

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        let keys = VaultAppKeys()
        let key1 = (keys.encryptionKeyForAlbumPin)
        let key2 = (keys.encryptionKeyForPhotos)
        print("CHECKING KEYS", key1, key2)
        
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))

        
        
        // EMAIL TEXT FIELD BORDER
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: emailTextField.frame.height - 1, width: emailTextField.frame.size.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        emailTextField.borderStyle = UITextField.BorderStyle.none
        emailTextField.layer.addSublayer(bottomLine)
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        emailTextField.textColor = UIColor.white
        
        
        // PWD TEXT FIELD BORDER
        let bottomLineP = CALayer()
        bottomLineP.frame = CGRect(x: 0.0, y: pwdTextField.frame.height - 1, width: pwdTextField.frame.size.width, height: 1.0)
        bottomLineP.backgroundColor = UIColor.white.cgColor
        pwdTextField.borderStyle = UITextField.BorderStyle.none
        pwdTextField.layer.addSublayer(bottomLineP)
        pwdTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        pwdTextField.textColor = UIColor.white

        signInButton.layer.borderWidth = 0.5
        signInButton.layer.borderColor = UIColor.white.cgColor
        
        forgotPasswordButton.layer.borderWidth = 0.5
        forgotPasswordButton.layer.borderColor = UIColor.white.cgColor
        
        registerButton.layer.borderWidth = 0.5
        registerButton.layer.borderColor = UIColor.white.cgColor
        
    }
    
    // MARK: Actions
    @IBAction func signInClicked(_ sender: UIButton) {
        
        let email = emailTextField.text!
        let password = pwdTextField.text!
        
        //check empty fields
        if(email.isEmpty || password.isEmpty){
            print("All fields are required.")
             displayAlertMessage(userMessage: "All fields are required.")
            
            //COMMENT OUT
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let controller = storyboard.instantiateViewController(withIdentifier: "MainGallery")
//            controller.modalPresentationStyle = .fullScreen
//            self.present(controller, animated: true, completion: nil)
//
            
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
                        
                         print("wrong email or password")
                        
                        // CHECK IF USER IS ENTERING DECOY
                        self.displayAlertMessage(userMessage: "Log In Failed. Please enter your email or password correctly.")
                        
                    }
                }else{
                    let err = error as NSError?
                    if(err?.userInfo["FIRAuthErrorUserInfoNameKey"] as! String=="ERROR_WRONG_PASSWORD"){
                        self.checkIfUserWantsDecoy(userEmail: email, pwdEntered: password)
                    }
                    else{
                        self.displayAlertMessage(userMessage: "Please sign up first.")
                    }
                }
                
            }
        }
    }
    
    func checkIfUserWantsDecoy(userEmail: String, pwdEntered: String) {
        
        // store decoy Pwd
        let ref = Database.database().reference()
        
//        var decryptedDecoyPwd = ""
        print(userEmail, pwdEntered)
        
        var email = userEmail
        let toremove: Set<Character> = [".", "#", "$", "[", "]", "@"]
        email.removeAll(where: { toremove.contains($0) })
        
        
        ref.child("users").child(email).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let ifDecoy = value?["decoy"] as? String ?? ""
            if(ifDecoy=="yes"){
                let decoyPwd = value?["decoyPwd"] as? String ?? ""
                let decryptedDecoyPwd = self.encryptorDecryptor.decryptString(string: decoyPwd)
                print("DECRYPTED PWD", decryptedDecoyPwd)
                if(decryptedDecoyPwd==pwdEntered){
                    print("true, going to decoy gallery")
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "DecoyGallery")
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }else{
                    self.displayAlertMessage(userMessage: "Log In Failed. Please enter your email or password correctly.")
                }
            }else{
                self.displayAlertMessage(userMessage: "Log In Failed. Please enter your email or password correctly.")
            }
          }) { (error) in
            print(error.localizedDescription)
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
    
    @IBAction func forgotPwdButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Coming Soon", message: "This functionality will be enabled later.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
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
