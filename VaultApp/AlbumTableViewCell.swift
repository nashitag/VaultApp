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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
