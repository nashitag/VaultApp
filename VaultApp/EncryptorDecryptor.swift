//
//  EncryptorDecryptor.swift
//  VaultApp
//
//  Created by Nashita Abd Guntaguli on 9/27/20.
//  Copyright © 2020 Nashita Abd Guntaguli. All rights reserved.
//

import Foundation
import Keys
import RNCryptor

class EncryptorDecryptor {
    
    var mode: String!
    let keys = VaultAppKeys()
    
    init(mode: String) {
        self.mode = mode
    }
    
    func encryptString(string: String) -> String {
        let data: Data = string.data(using: .utf8)!
        return encrypt(data: data)
    }
    
    func encrypt(data: Data) -> String {
        switch(self.mode ?? "") {
        case "AlbumPin":
            let encryptedData = RNCryptor.encrypt(data: data, withPassword: keys.encryptionKeyForAlbumPin)
            let encryptedString: String = encryptedData.base64EncodedString()
            return encryptedString
        case "AlbumPhoto":
            let encryptedData = RNCryptor.encrypt(data: data, withPassword: keys.encryptionKeyForPhotos)
            let encryptedString: String = encryptedData.base64EncodedString()
            return encryptedString
        default:
            fatalError("Unexpected Mode; \(self.mode ?? "wrong mode")")
        }
    }
    
    
    func decryptString(string: String) -> String {
        let data: Data = Data(base64Encoded: string)!
        return decrypt(data: data)
    }
    
    func decrypt(data: Data) -> String {
        do {
            switch(self.mode ?? "") {
            case "AlbumPin":
                let decryptedData = try RNCryptor.decrypt(data: data, withPassword: keys.encryptionKeyForAlbumPin)
                let decryptedString = String(data: decryptedData, encoding: .utf8)
                return decryptedString ?? " "
            case "AlbumPhoto":
                let decryptedData = try RNCryptor.decrypt(data: data, withPassword: keys.encryptionKeyForPhotos)
                let decryptedString = String(data: decryptedData, encoding: .utf8)
                return decryptedString ?? " "
            default:
                fatalError("Unexpected Mode; \(self.mode ?? "wrong mode")")
            }
        } catch{
            return "Decryption Failed"
        }
    }
    
}
