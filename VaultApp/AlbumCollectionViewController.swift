//
//  AlbumCollectionViewController.swift
//  VaultApp
//
//  Created by Nashita Abd Guntaguli on 9/26/20.
//  Copyright © 2020 Nashita Abd Guntaguli. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import Firebase

private let reuseIdentifier = "photoCell"





class AlbumCollectionViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate,  UICollectionViewDelegateFlowLayout {
    

    // MARK: Properties
    var album: Album?
    
    var photos = [Photo]()
    
    var selectedPhoto: Photo!
    
    private let spacing:CGFloat = 4.0
    

    
    // MARK: UIViewController / Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        if let album = album {
            navigationItem.title = album.name
        }
        
        downloadImageData()
        

    }
    
    // load when back from
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let numberOfItemsPerRow:CGFloat = 3
            let spacingBetweenCells:CGFloat = 10
            
            let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
            
            if let collection = self.collectionView{
                let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
                return CGSize(width: width, height: width)
            }else{
                return CGSize(width: 0, height: 0)
            }
        }
    
    // MARK: - Actions
    
    
    @IBAction func addImageButtonClicked(_ sender: UIBarButtonItem) {
        
        let photo_camera_alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "Photo Gallery", style: .default){ [self] (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                let image = UIImagePickerController()
                image.delegate = self
                image.sourceType = .photoLibrary
                image.allowsEditing = true
                self.present(image, animated: true)
                
            }
            
        }
            
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default){ [self] (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                
            }else{
                print("Camera is Not Available")
            }
            
        }
        let albumCoverAction = UIAlertAction(title: "Add Album Cover Photo", style: .default){ (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                let image = UIImagePickerController()
                image.delegate = self
                image.sourceType = .photoLibrary
                image.allowsEditing = true
                self.present(image, animated: true)
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            (_) in
            return
        }
        
        photo_camera_alert.addAction(photoAction)
        photo_camera_alert.addAction(cameraAction)
        photo_camera_alert.addAction(albumCoverAction)
        photo_camera_alert.addAction(cancelAction)
        self.present(photo_camera_alert, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            let pickedImage = image
            uploadImage(image: pickedImage)
            
        } else{
            print("ERROR: Image was not imported")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // BACKEND FUNCTIONS
    
    func uploadImage(image: UIImage){
        
        let uuid = UUID().uuidString
        
        guard let data: Data = image.jpegData(compressionQuality: 0.2) else {
               return
           }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
//        metaData.customMetadata = ["fileName":uuid,  "addedOn":photo.]
        
        
        
        // STORAGE REF CHECK
        let currentID = Auth.auth().currentUser?.uid
        
        if let album = album {
            let child_path = "/users/"+currentID!+"/albums/"+album.name+"/"+uuid+".jpg"
            
            let storageRef = Storage.storage(url: "gs://vaultapp-5c3c8.appspot.com").reference().child(child_path)
            
            storageRef.putData(data as Data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }else{
                    //store downloadURL
//                    let downloadURL = metaData!.downloadURL()!.absoluteString
                    self.downloadImageData()

                }
            }
        }
        
    }
    
    
    
    func downloadImageData(){
//        var newPhotos = [Data]()
        print("downloadImageData")
        
        let currentID = Auth.auth().currentUser?.uid
        if let album = album {
            let child_path = "/users/"+currentID!+"/albums/"+album.name+"/"
            
            let storageRef = Storage.storage(url: "gs://vaultapp-5c3c8.appspot.com").reference().child(child_path)
            
            
            
            storageRef.listAll { (result, error) in
                if let error = error {
                  // ...
                  print(error)
                  print("FETCHING IMAGES ERROR")
                }
                for item in result.items {
                  // The items under storageReference.
                    print(item.name)
                                    
                    var addedOn: String = ""
                    
                    item.getMetadata(){ metadata, error in
                        if let error = error {
                            
                        }else{
                            let date: Date = (metadata?.timeCreated)!
                            addedOn = self.getDate(date: date)
//                            print(addedOn)
                            
                        }
                    }
                    
                    item.getData(maxSize: (1 * 1024 * 1024)){ (data, error) in
                        if let _error = error{
                            print(error)
                            print("GET IMAGE DATA ERROR")
                        } else {
                            let photo = Photo(fileName: item.name, addedOn: addedOn, data: data, inAlbum: album.name)
                            
//                            print(photo!.data)
                            DispatchQueue.main.async {
                                if(!self.photos.contains(where: { $0.fileName == photo!.fileName })){
                                    self.photos.append(photo!)
                                    self.collectionView.reloadData()
                                    print("photos", self.photos)
                                }
                            }
                        }
                    }
                    
                    
                }
                }
            
        }}
    
    func getDate(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let createdDate = dateFormatter.string(from: date)
        return createdDate
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
    
//        let imageName =
        // Configure the cell
        cell.photo = photos[indexPath.item]
//        cell.imageData = photosDataList[indexPath.item]
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       
        selectedPhoto = photos[indexPath.item]
        performSegue(withIdentifier: "ShowImageDetail", sender: nil)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowImageDetail" {
            guard let detailVC = segue.destination as? PhotoDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            detailVC.photo = selectedPhoto
        }
    }
    
    
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
