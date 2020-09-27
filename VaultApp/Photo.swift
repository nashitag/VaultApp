//
//  Photo.swift
//  VaultApp
//
//  Created by Nashita Abd Guntaguli on 9/26/20.
//  Copyright © 2020 Nashita Abd Guntaguli. All rights reserved.
//

import UIKit

class Photo {
    
    // MARK: Properties
    
    var fileName: String
    var addedOn: String = ""
    var data: Data?
    var inAlbum: String
    
    //MARK: Initialization
    init?(fileName: String, addedOn: String = "", data: Data?, inAlbum: String) {
        if fileName.isEmpty || inAlbum.isEmpty {
            return nil
        }
        
        self.fileName = fileName
        self.data = data
        self.inAlbum = inAlbum
        
        //created on param not passed
        if(addedOn==""){
            self.addedOn = getDate()
        }else{
            self.addedOn = addedOn
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
