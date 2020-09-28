//
//  PhotoCollectionViewCell.swift
//  VaultApp
//
//  Created by Nashita Abd Guntaguli on 9/26/20.
//  Copyright © 2020 Nashita Abd Guntaguli. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var photoCellImageView: UIImageView!
    
    var photo: Photo! {
        didSet{
            photoCellImageView.image = UIImage(data: photo.data!)
            
        }
    }
    
}
