//
//  TableViewCell.swift
//  ArmQuickShare
//
//  Created by Aswin R on 27/12/24.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
