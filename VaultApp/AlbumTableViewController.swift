//
//  AlbumTableViewController.swift
//  VaultApp
//
//  Created by Nashita Abd Guntaguli on 9/25/20.
//  Copyright © 2020 Nashita Abd Guntaguli. All rights reserved.
// To display dynamic data, a table view needs two important helpers: a data source and a delegate. A table view data source, as implied by its name, supplies the table view with the data it needs to display. A table view delegate helps the table view manage cell selection, row heights, and other aspects related to displaying the data. By default, UITableViewController and its subclasses adopt the necessary protocols to make the table view controller both a data source (UITableViewDataSource protocol) and a delegate (UITableViewDelegate protocol) for its associated table view.

import UIKit
import Firebase
import os.log



class AlbumTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    //MARK: Properties
     
    var albums = [Album]()
    let encryptorDecryptorPin = EncryptorDecryptor(mode: "AlbumPin")
    let currentID = Auth.auth().currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        // Load the sample data. or initial data
        updateAlbumsListServer()
        
        // Refress table on pull down
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        // UI DESIGN ELEMENTS
        // NAVIGATION BAR UI
        let logo = UIImage(named: "banner1.jpg")
        navigationController?.navigationBar.setBackgroundImage(logo, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50.0)
        
    }
    
    // refresh tableDataList and tableView
    @objc func refresh(sender:AnyObject)
    {
        // Updating your data here...
        updateAlbumsListServer()

        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return albums.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "AlbumTableViewCell"
        // guard let expression safely unwraps the optional.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AlbumTableViewCell  else {
            fatalError("The dequeued cell is not an instance of AlbumTableViewCell.")
        }
        
        // Configure the cell
        let album = albums[indexPath.row]
        cell.albumNameLabel.text = album.name
        cell.albumDateLabel.text = album.createdOn
        
        return cell
    }
    
    
    
    // MARK: Actions
    
    // ADD ALBUM BUTTON
    @IBAction func addAlbumButtonClicked(_ sender: UIBarButtonItem) {
        askIfCreatAlbumWITHpin()
    }
    
    // Ask if album should be created with PIN CODE
    func askIfCreatAlbumWITHpin(){
        
        let alert = UIAlertController(title: "Pin Code", message: "Would you like to create the album with a Pin Code?", preferredStyle: .alert)
        
        let actionYES = UIAlertAction(title: "Yes", style: .default, handler: { (action:UIAlertAction) in
            //display alert WITH pin code text field
            self.showAlbumInputDialogWITHpin(title: "Create Album", subtitle: "Input Album Details", withPassword: true)
        })
        let actionNO = UIAlertAction(title: "No", style: .cancel, handler: { (action:UIAlertAction) in
            //display alert WITHOUT pin code text field
            self.showAlbumInputDialogWITHpin(title: "Create Album", subtitle: "Input Album Details", withPassword: false)
        })
        alert.addAction(actionYES)
        alert.addAction(actionNO)
        self.present(alert, animated: true, completion: nil)
    }
        
    // Ask for Album name and Pin Code
    func showAlbumInputDialogWITHpin(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         withPassword:Bool?,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil) {

        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
                
        // ALBUM NAME
        alert.addTextField { (albumNameTextField:UITextField) in
            albumNameTextField.placeholder = "Album Name"
            albumNameTextField.keyboardType = UIKeyboardType.default
            albumNameTextField.accessibilityIdentifier = "albumNameTextField"
        }
        
        // ALBUM PWD
        if(withPassword!){
            alert.addTextField { (albumPwdTextField:UITextField) in
                albumPwdTextField.placeholder = "Enter 4 digit pin to access Album"
                albumPwdTextField.keyboardType = UIKeyboardType.asciiCapableNumberPad
                albumPwdTextField.accessibilityIdentifier = "albumPwdTextField"
            }
            
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
                //extract values
                let albumNameText =  alert.textFields![0]
                let albumPwdText =  alert.textFields![1]
                
                //check for empty fields
                if(albumNameText.text!.isEmpty || albumPwdText.text!.isEmpty){
                    self.displayAlertMessage(userMessage: "All fields are required.")
                    return
                }
                else{
                    // create album with password
                    self.createAndStoreAlbumWithEncryptedPin(name: albumNameText.text!,  pin: albumPwdText.text!, withPin: true)
                    
                }
            }))
        }else{
            
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
                //extract values
                let albumNameText =  alert.textFields![0]
                
                //check for empty fields
                if(albumNameText.text!.isEmpty){
                    self.displayAlertMessage(userMessage: "Album name is required.")
                    return
                }
                else{
                    // create album without password
                    self.createAndStoreAlbumWithEncryptedPin(name: albumNameText.text!, withPin: false)
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        self.present(alert, animated: true, completion: nil)
    }
    
    // ENCRYPT PIN, CREATE ALBUM AND STORE
    func createAndStoreAlbumWithEncryptedPin(name: String,  pin: String = " ", withPin: Bool){
            
        // WITH PIN
        if(withPin){
            print("creating album with password")
            // encrypt pin
            let encryptedPin = encryptorDecryptorPin.encryptString(string: pin)
            
            // create album
            let albumCreated = Album(name: name,  password: encryptedPin)
            
            // store album
            self.addAlbumToStorage(album: albumCreated!)
        }
            // WITHOUT PIN
            else{
                print("creating album without password")
                // pin = " "
                
                // create album
                let albumCreated = Album(name: name,  password: pin)
                
                // store album
                self.addAlbumToStorage(album: albumCreated!)
            }
    }
    
    // DISPLAY ALERTS
    func displayAlertMessage(userMessage: String){
        let myAlert = UIAlertController(title: "Error", message: userMessage, preferredStyle: UIAlertController.Style.alert);
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil);
        
        myAlert.addAction(okAction);
        
        self.present(myAlert, animated:true, completion:nil);
    }
    
    
    // MARK: BACKEND FUNCTIONS
    func addAlbumToStorage(album: Album){
        
        // STORAGE REF CHECK
        
                
        // Create a reference to the file you want to upload
        let child_path = "/users/"+currentID!+"/albums/all_album_details/"+album.name
        let storageRef = Storage.storage(url: "gs://vaultapp-5c3c8.appspot.com").reference().child(child_path)

        //create album metadata
        let metadata = StorageMetadata()
        metadata.customMetadata = ["name":album.name, "password": album.password, "createdOn":album.createdOn]

        let data = album.name.data(using: .utf8)
        storageRef.putData(data!, metadata: metadata)
        
        updateAlbumsListServer()
        
    }
    
    func updateAlbumsListServer(){
        
        // STORAGE REF CHECK
        
        // Create a reference to the file you want to upload
        print(currentID!)
        let child_path = "/users/"+currentID!+"/albums/all_album_details/"
        let storageRef = Storage.storage(url: "gs://vaultapp-5c3c8.appspot.com").reference().child(child_path)

        
        storageRef.listAll { (result, error) in
          if let error = error {
            // ...
            print("ERROR")
          }
          for item in result.items {
            // The items under storageReference.
            
            item.getMetadata() { metadata, error in
              if let error = error {
                // Uh-oh, an error occurred!
              } else {
                let albumMetadata = metadata?.customMetadata
                let albumNew = Album(name: albumMetadata!["name"]!, password: albumMetadata!["password"]!, createdOn: albumMetadata!["createdOn"]!)
                
                DispatchQueue.main.async {
                    if(!self.albums.contains(where: { $0.name == albumNew!.name })){
                        self.albums.append(albumNew!)
                        self.tableView.reloadData()
                    }
                }
                
              }
            }
          }
        }
    }
        


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            albums.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//
//            let selectedAlbumTODELETE = albums[indexPath.row]
////            deleteAlbumPathFirebase(selectedAlbumTODELETE: selectedAlbumTODELETE)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
    
    
    // CHECK FUNCTION TO DELETE
//    func deleteAlbumPathFirebase(selectedAlbumTODELETE: Album){
////        let child_path = "/users/"+currentID!+"/albums/"+selectedAlbumTODELETE.name
//
//        let child_path = "/users/"+currentID!+"/albums/all_album_details/"+selectedAlbumTODELETE.name
//        let storageRef = Storage.storage(url: "gs://vaultapp-5c3c8.appspot.com").reference().child(child_path)
//
//        storageRef.delete { error in
//          if let error = error {
//            // Uh-oh, an error occurred!
//            print("album deletion error", error)
//          } else {
//            // File deleted successfully
//            print("album deleted")
//          }
//        }
//        albums.removeAll()
//        updateAlbumsListServer()
//
//
//    }
    
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    

    
    // MARK: - Navigation
    
    var selectedAlbum: Album!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedAlbum = albums[indexPath.row]
        print("selectedAlbum.password", selectedAlbum.password)
        // NO PIN
        if selectedAlbum.password == " "{
            performSegue(withIdentifier: "ShowAlbum", sender: nil)
        }
        // ASK FOR PIN
        else{
            askForAlbumPin(encryptedPin: selectedAlbum.password)
        
        }}
    
    
    func askForAlbumPin(encryptedPin: String){
        let alert = UIAlertController(title: "Enter 4 digit Pin", message: nil, preferredStyle: .alert)

        alert.addTextField{ (albumPin:UITextField) in
            albumPin.placeholder = "Album Pin Code"
            albumPin.keyboardType = UIKeyboardType.asciiCapableNumberPad
            albumPin.isSecureTextEntry = true
            }
        
        let okAction = UIAlertAction(title: "Done", style: .default, handler: { (action:UIAlertAction) in
            
            //extract values
            let albumPin =  alert.textFields![0]
            
            //check for empty fields
            if(albumPin.text!.isEmpty){
                self.displayAlertMessage(userMessage: "Please enter the Album Pin.")
            }
            
            // DECRYPT AND CHECK IF CORRECT
            if(self.decryptPin(encryptedPin: encryptedPin, userPin: albumPin.text!)){
                // CORRECT CODE
                self.performSegue(withIdentifier: "ShowAlbum", sender: nil)
            }else{
                // WRONG PIN
                self.displayAlertMessage(userMessage: "Wrong Album Pin.")
            }

        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                        return
        })
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    func decryptPin(encryptedPin: String, userPin: String) -> Bool{
        
        let decryptedPin = encryptorDecryptorPin.decryptString(string: encryptedPin)
        
        print(userPin, decryptedPin)
        if(userPin==decryptedPin){
            return true
        }else{
            return false
        }
        
        
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            case "ShowAlbum":
                guard let albumCollectionViewController = segue.destination as? AlbumCollectionViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                
//                guard let selectedAlbumCell = sender as? AlbumTableViewCell else {
//                    fatalError("Unexpected sender: \(sender)")
//                }
                
//                guard let indexPath = tableView.indexPath(for: selectedAlbumCell) else {
//                    fatalError("The selected cell is not being displayed by the table")
//                }
                
                
                albumCollectionViewController.album = selectedAlbum
                
            case "showUserProfile1":
                guard segue.destination is UserProfileViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
            default:
                fatalError("Unexpected Segue Identifier; \(segue.identifier)")
            
            
        }
        
        
    }

}
