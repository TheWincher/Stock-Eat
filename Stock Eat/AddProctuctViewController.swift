//
//  AddProctuctViewController.swift
//  Stock Eat
//
//  Created by Emmanuel LOUCHEZ on 18/10/2020.
//  Copyright © 2020 Emmanuel LOUCHEZ. All rights reserved.
//

import UIKit

class CellCategorie: UITableViewCell {
    
}

class AddProctuctViewController : UIViewController
{
    var codeBar : String!
    var numberProduct = 1
    var product :Product?
    let categories = ["Fruits et légumes", "Produits frais", "Surgelés", "Epicerie salée", "Epicerie sucrée", "Boissons", "Produits d'entretien"]
    var selectedCategorie: String?
    let transparentView = UIView()
    let tableView = UITableView()
    var selectedButton = UIButton()
    var imagePickerController : UIImagePickerController!
    
    @IBOutlet weak var photoBtn: UIButton!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var categorieSelectBtn: UIButton!
    @IBOutlet weak var nameProduct: UITextField!
    @IBOutlet weak var AddProductButton: UIButton!
    @IBOutlet weak var numberStepper: UIStepper!
    @IBOutlet weak var numberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellCategorie.self, forCellReuseIdentifier: "CellCategorie")
        
        product = DataBase.db.SelectProduct(withCodeBar: codeBar)
        if product != nil
        {
            nameProduct.text = product?.name
        }
        
        numberStepper.value = Double(numberProduct)
        numberLabel.text = String(numberProduct)
    }
    
    func AddTransparentView(frames: CGRect)
    {
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 5
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RemoveTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.categories.count * 50))
        }, completion: nil)
    }
    
    @objc func RemoveTransparentView()
    {
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    @IBAction func NumberUpdateValue(_ sender: Any) {
        numberProduct = Int(numberStepper.value)
        numberLabel.text = String(numberProduct)
    }
    
    @IBAction func OnPhotoButton(_ sender: Any) {
       imagePickerController = UIImagePickerController()
       imagePickerController.delegate = self
       imagePickerController.sourceType = .camera
       present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func AddProductInDB(_ sender: Any)
    {
        
        var categorie: String?
        var imagePath: String?
        if categories.contains(selectedButton.title(for: .normal)!)
        {
            categorie = selectedButton.title(for: .normal)
        }
        
        if productImage.image != nil
        {
            imagePath = saveImage(imageName: nameProduct.text!)
        }
        
        var res = true
        if product == nil
        {
            product = Product(
                codeBar: codeBar,
                name: nameProduct.text!,
                number: numberProduct,
                imagePath: imagePath!,
                categorie: categorie!)
            
            res = InsertProduct(product: product!)
        }
        else
        {
            res = self.UpdateProduct(product: product!, numberToAdd: numberProduct)
        }
        
        
        if res == false
        {
            let alert = UIAlertController(title: "Error", message: "Erreur lors de l'ajout du produit", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func SelectCategorie(_ sender: Any)
    {
        selectedButton = categorieSelectBtn
        AddTransparentView(frames: categorieSelectBtn.frame)
    }
    
    private func UpdateProduct(product: Product, numberToAdd: Int) -> Bool
    {
        var productToUpdate = product
        productToUpdate.number += numberToAdd
        return DataBase.db.UpdateNumberOfProduct(product: productToUpdate)
    }
    
    private func InsertProduct(product: Product) -> Bool
    {
        return DataBase.db.InsertProduct(product: product)
    }
}

extension AddProctuctViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellCategorie", for: indexPath) as? CellCategorie else
        {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = categories[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedButton.setTitle(categories[indexPath.row], for: .normal)
        RemoveTransparentView()
    }
}

extension AddProctuctViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        imagePickerController.dismiss(animated: true, completion: nil)
        productImage.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    }
    
    func saveImage(imageName: String) -> String?
    {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileName = imageName + ".png"
        let fileURL = documentURL.appendingPathComponent(fileName)
        if let imageData = productImage.image!.pngData() {
            try? imageData.write(to: fileURL, options: .atomic)
            return fileName
        }
       
        print("Error saving image")
        return nil
    }
}
