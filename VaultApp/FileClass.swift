//
//  FileClass.swift
//  VaultApp
//
//  Created by Nashita Abd Guntaguli on 9/29/20.
//  Copyright © 2020 Nashita Abd Guntaguli. All rights reserved.
//

import Foundation

class File{
    
    // MARK: Properties
    
    var fileName: String
    var addedOn: String = ""
    var data: Data?
    
    
    init?(fileName: String, addedOn: String = "", data: Data?) {
        if fileName.isEmpty {
            return nil
        }
        
        self.fileName = fileName
        self.data = data
        
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
