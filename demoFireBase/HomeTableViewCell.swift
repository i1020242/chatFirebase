//
//  HomeTableViewCell.swift
//  demoFireBase
//
//  Created by Nguyễn Minh Trí on 4/6/17.
//  Copyright © 2017 Nguyễn Minh Trí. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtText: UILabel!
    @IBOutlet weak var imgAvata: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
