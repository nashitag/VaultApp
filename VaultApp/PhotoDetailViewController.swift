//
//  PhotoDetailViewController.swift
//  VaultApp
//
//  Created by Nashita Abd Guntaguli on 9/26/20.
//  Copyright © 2020 Nashita Abd Guntaguli. All rights reserved.
//

import UIKit
import Firebase

class PhotoDetailViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!
    
    var photo: Photo!
    
    @IBOutlet weak var addedOnLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let displayImage = UIImage(data: photo.data!)
        imageView.image = displayImage
        navigationItem.title = "Photo"
        
        addedOnLabel.text = photo.addedOn
        print(photo.addedOn)
        
    }
    

    // MARK: - Actions
    
    @IBAction func deletePhotoButton(_ sender: UIBarButtonItem) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete Photo", style: .default){
            (_) in
            self.deletePhoto()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            (_) in
            return
        }
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }
    
    func deletePhoto(){
        let currentID = Auth.auth().currentUser?.uid
                        
                // Create a reference to the file you want to upload
                let child_path = "/users/"+currentID!+"/albums/"+photo.inAlbum+"/"+photo.fileName
                
                let storageRef = Storage.storage(url: "gs://vaultapp-5c3c8.appspot.com").reference().child(child_path)
                
                storageRef.delete { error in
                  if let error = error {
                    // Uh-oh, an error occurred!
                    print("DELETE ERROR", error)
                  } else {
                    // File deleted successfully
                    self.displaySuccessAlert()
                    
                  }
                }
    }
    
    func displaySuccessAlert(){
        let alert_verification = UIAlertController(title: "Success", message: "Your image has been successfully deleted.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default){
            (_) in
            _ = self.navigationController?.popViewController(animated: true)
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
