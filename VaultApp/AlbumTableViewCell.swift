//
//  AlbumTableViewCell.swift
//  VaultApp
//
//  Created by Nashita Abd Guntaguli on 9/24/20.
//  Copyright © 2020 Nashita Abd Guntaguli. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumDateLabel: UILabel!
    
    var bckImages = [UIImage(named: "lck1"), UIImage(named: "lck2"), UIImage(named: "lck3")] //ADD MORE IMAGES


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.albumImage.layer.cornerRadius = 10.0;
        self.albumImage.layer.masksToBounds = true;
        self.albumImage.image = bckImages.randomElement() as? UIImage
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        //set the values for top,left,bottom,right margins
        
        let margins = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        self.contentView.frame = self.contentView.frame.inset(by: margins)
        
        
//        self.contentView.layer.borderWidth = 0.5
//        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.backgroundColor = .white
        
//        self.backgroundView = UIImageView(image: bckImages.randomElement() as? UIImage)
        
        self.contentView.layer.shadowColor = UIColor.black.cgColor
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: -3.0)
        self.contentView.layer.shadowRadius = 3.0
        self.contentView.layer.shadowOpacity = 0.2
        self.contentView.layer.masksToBounds = false
        self.contentView.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath

    }
    
}
