//
//  FileTableViewCell.swift
//  VaultApp
//
//  Created by Nashita Abd Guntaguli on 9/29/20.
//  Copyright © 2020 Nashita Abd Guntaguli. All rights reserved.
//

import UIKit

class FileTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet weak var fileNameTextField: UILabel!
    @IBOutlet weak var addedOnTextField: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
