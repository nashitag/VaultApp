//
//  Album.swift
//  
//
//  Created by Nashita Abd Guntaguli on 9/25/20.
//

import UIKit
import RNCryptor


// Album object
class Album {
    
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var password: String
    var createdOn: String = ""
//    var isLocked: Bool
    
    
    //MARK: Initialization
     
    init?(name: String, photo: UIImage? = nil, password: String, createdOn: String = "") {
        if name.isEmpty || password.isEmpty  {
            return nil
        } 
        
        self.name = name
        self.photo = photo
        self.password = password
        
        //created if param not passed
        if(createdOn==""){
            self.createdOn = getDate()
        }else{
            self.createdOn = createdOn
        }
    
    }
    
    func getDate() -> String{
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let createdDate = dateFormatter.string(from: date)
        return createdDate
    }
    
}
