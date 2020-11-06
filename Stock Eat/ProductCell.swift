//
//  ProductCell.swift
//  Stock Eat
//
//  Created by Emmanuel LOUCHEZ on 19/10/2020.
//  Copyright © 2020 Emmanuel LOUCHEZ. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(withProduct product: Product) {
        nameLabel.text = product.name
        numberLabel.text = "Stock : " + String(product.number)
        imageLabel.image = LoadImage(fileName: product.imagePath)
    }
    
    private func LoadImage(fileName: String) -> UIImage?
    {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileURL = documentURL.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        
        return nil
    }

}
