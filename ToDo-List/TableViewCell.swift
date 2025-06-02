//
//  TableViewCell.swift
//  ToDo-List
//
//  Created by ipv6 on 23.05.2025.
//

import UIKit



class TableViewCell: UITableViewCell {
    
    var onDelete: (() -> Void)?
    
    var onEdit: (() -> Void)?
    
    var onToggleComplete: (() -> Void)?


    @IBOutlet weak var header: UILabel!
    
    @IBOutlet weak var detail: UILabel!
    
    @IBOutlet weak var createdAt: UILabel!
    
    @IBOutlet weak var checkmark: UIButton!
    
    @IBOutlet weak var delete: UIButton!
    
    @IBOutlet weak var edit: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK: - checkmark btn
    
    @IBAction func checkmark(_ sender: UIButton) {
        
            if sender.tintColor == UIColor.systemGreen {
                sender.tintColor = .lightGray
            } else {
                sender.tintColor = .systemGreen
            }
            
            onToggleComplete?()
    }
    
    //MARK: - delete btn

    @IBAction func deleteTapped(_ sender: UIButton) {
        onDelete?()
    }
    
    //MARK: - edit btn
    
    @IBAction func editTapped(_ sender: UIButton) {
        onEdit?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
