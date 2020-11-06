//
//  ViewController.swift
//  Stock Eat
//
//  Created by Emmanuel LOUCHEZ on 10/10/2020.
//  Copyright © 2020 Emmanuel LOUCHEZ. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, ScannerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var clickButton: UIButton!
    private var scanner : Scanner?
    private var products : [Product] = []
    
    private let dataSource = [Int](1...100)
    private let categories = ["Fruits et légumes", "Produits frais", "Surgelés", "Epicerie salée", "Epicerie sucrée", "Boissons", "Produits d'entretien"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UpdateProducts()
    }
    
    private func UpdateProducts()
    {
        products = DataBase.db.SelectAllProduct()
        productTableView.reloadData()
    }
    
    @IBAction func AddProduct(_ sender: Any) {
        
        checkPermissions()
        self.scanner = Scanner(withDelegate: self, toRemove: false)
        
        guard let scanner = self.scanner else {
            return
        }
        
        scanner.requestCaptureSessionStartRunning()
    }
    
    @IBAction func RemoveProduct(_ sender: Any) {
        checkPermissions()
        self.scanner = Scanner(withDelegate: self, toRemove: true)
        
        guard let scanner = self.scanner else {
            return
        }
        
        scanner.requestCaptureSessionStartRunning()
    }
    
    func scanCompleted(withCode code: String, toRemove: Bool) {
        
        if toRemove
        {
            self.view.layer.sublayers?.removeLast()
            guard var product = products.filter({$0.codeBar == code}).first else {
                return
            }
            
            product.number -= 1
            if product.number < 0 { product.number = 0}
            
            if DataBase.db.UpdateNumberOfProduct(product: product) == false
            {
                ShowErrorAlert(title: "Error", message: "Impossible d'enlever le produit")
            }
            else
            {
                UpdateProducts()
            }
        }
        else
        {
            if !products.filter({$0.codeBar == code}).isEmpty
            {
                let toolBar = UIToolbar()
                let addButton = UIBarButtonItem(title: "Add", style: UIBarButtonItem.Style.done, target: self, action: nil)
                let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.done, target: self, action: nil)

                toolBar.setItems([addButton, backButton], animated: false)
                
                let UIPicker : UIPickerView = UIPickerView()
                UIPicker.delegate = self as UIPickerViewDelegate
                UIPicker.dataSource = self as UIPickerViewDataSource
                UIPicker.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        
                self.view.addSubview(UIPicker)
                self.view.addSubview(toolBar)
                //UIPicker.center = self.view.center
            }
            else
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let product = storyboard.instantiateViewController(withIdentifier: "AddProduct") as! AddProctuctViewController
                
                product.codeBar = code
                self.navigationController?.show(product, sender: self)
            }
        }
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection)
    {
        guard let scanner = self.scanner else {
            return
        }
        
        scanner.metadataOutput(output, didOutput: metadataObjects, from: connection)
    }
    
    func delegateViewController() -> UIViewController {
        return self
    }
    
    func cameraView() -> UIView {
        return self.view
    }
    
    private func checkPermissions() {
        let mediaType = AVMediaType.video
        let status = AVCaptureDevice.authorizationStatus(for: mediaType)
        
        switch status {
        case .denied, .restricted:
            displayNotAuthorizedUI()
        case.notDetermined:
            // Prompt the user for access.
            AVCaptureDevice.requestAccess(for: mediaType) { granted in
                guard granted != true else { return }
                
                // The UI must be updated on the main thread.
                DispatchQueue.main.async {
                    self.displayNotAuthorizedUI()
                }
            }
            
        default: break
        }
    }
    
    private func displayNotAuthorizedUI() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.8, height: 20))
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Please grant access to the camera for scanning barcodes."
        label.sizeToFit()
        
        let button = UIButton(frame: CGRect(x: 0, y: label.frame.height + 8, width: view.frame.width * 0.8, height: 35))
        button.layer.cornerRadius = 10
        button.setTitle("Grant Access", for: .normal)
        button.backgroundColor = UIColor(displayP3Red: 4.0/255.0, green: 92.0/255.0, blue: 198.0/255.0, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        //button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        
        let containerView = UIView(frame: CGRect(
            x: view.frame.width * 0.1,
            y: (view.frame.height - label.frame.height + 8 + button.frame.height) / 2,
            width: view.frame.width * 0.8,
            height: label.frame.height + 8 + button.frame.height
            )
        )
        containerView.addSubview(label)
        containerView.addSubview(button)
        view.addSubview(containerView)
    }
    
    func ShowErrorAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.filter({$0.categorie == categories[section]}).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if products.filter({$0.categorie == categories[section]}).count > 0
        {
            return categories[section]
        }
        
        return nil
    }
    
    private func tableView(tableView: UITableView, ViewForHeaderInSection section: Int) -> UIView?{
        tableView.backgroundColor = UIColor.red
        return tableView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell else
        {
            return UITableViewCell()
        }
        
        let product = products.filter({$0.categorie == categories[indexPath.section]})[indexPath.row]
        
        cell.configure(withProduct: product)
        
        return cell
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return dataSource.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (dataSource[row] as NSNumber).stringValue
    }
}

