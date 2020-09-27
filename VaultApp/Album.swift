//
//  Album.swift
//  
//
//  Created by Nashita Abd Guntaguli on 9/25/20.
//

import UIKit
import RNCryptor


class Album {
    
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var password: String
    var createdOn: String = ""
//    var isLocked: Bool
    
    
    //MARK: Initialization
     
    //Failable initializers always start with either init? or init!. These initializers return optional values or implicitly unwrapped optional values, respectively. Optionals can either contain a valid value or nil. You must check to see if the optional has a value, and then safely unwrap the value before you can use it. Implicitly unwrapped optionals are optionals, but the system implicitly unwraps them for you.
    init?(name: String, photo: UIImage? = nil, password: String, createdOn: String = "") {
        if name.isEmpty || password.isEmpty  {
            return nil
        } //In this case, your initializer returns an optional Meal? object.
        
        self.name = name
        self.photo = photo
        self.password = password
        
        //created on param not passed
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
