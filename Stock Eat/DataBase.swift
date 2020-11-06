//
//  DataBase.swift
//  Stock Eat
//
//  Created by Emmanuel LOUCHEZ on 17/10/2020.
//  Copyright © 2020 Emmanuel LOUCHEZ. All rights reserved.
//

import Foundation
import SQLite3

struct Product {
    var codeBar : String
    var name : String
    var number : Int
    var imagePath: String
    var categorie: String
}

class DataBase
{
    
    static let db = DataBase()
    private var dataBase : OpaquePointer?
    
    private init() {
        openDatabase()
        createProductTable()
    }
    
    private func openDatabase() {
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("ProductDB.sqlite")
      
        if sqlite3_open(fileURL.path, &dataBase) != SQLITE_OK
        {
            print("Error : opening dataBase")
        }
    }
    
    private func createProductTable()
    {
        
        let request = "CREATE TABLE IF NOT EXISTS Product (codeBar TEXT PRIMARY KEY , name TEXT, number INTEGER, imagePath TEXT, categorie TEXT)"
        
        if sqlite3_exec(dataBase, request, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    public func UpdateNumberOfProduct(product: Product) -> Bool
    {
        let request = "UPDATE Product SET number = ? WHERE codeBar = ?"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(dataBase, request, -1, &stmt, nil) != SQLITE_OK {
            return false
        }
        
        if sqlite3_bind_int(stmt, 1, Int32(product.number)) != SQLITE_OK{
            return false
        }
        
        if sqlite3_bind_text(stmt, 2, (product.codeBar as NSString).utf8String, -1, nil) != SQLITE_OK{
            return false
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            return false
        }
        
        return true
    }
    
    public func InsertProduct(product : Product) -> Bool
    {
        let request = "INSERT INTO Product (codeBar, name, number, imagePath, categorie) VALUES (?,?,?,?,?);"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(dataBase, request, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
            print("error creating table: \(errmsg)")
        }
        
        if sqlite3_bind_text(stmt, 1, (product.codeBar as NSString).utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
            print("failure binding name: \(errmsg)")
            return false
        }
        
        if sqlite3_bind_text(stmt, 2,(product.name as NSString).utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
            print("failure binding name: \(errmsg)")
            return false
        }
        
        if sqlite3_bind_int(stmt, 3, Int32(product.number)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
            print("failure binding name: \(errmsg)")
            return false
        }
        
        if sqlite3_bind_text(stmt, 4, (product.imagePath as NSString).utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
            print("failure binding name: \(errmsg)")
            return false
        }
        
        if sqlite3_bind_text(stmt, 5, (product.categorie as NSString).utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
            print("failure binding name: \(errmsg)")
            return false
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
            print("failure inserting hero: \(errmsg)")
            return false
        }
        
        return true
    }
    
    public func SelectAllProduct() -> [Product]
    {
        let request = "SELECT * FROM Product;"
        var stmt: OpaquePointer?
        var products : [Product] = []
        
        if sqlite3_prepare(dataBase, request, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
            print("error creating table: \(errmsg)")
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            
            guard let codeBarProductCString = sqlite3_column_text(stmt, 0) else {
                continue
            }
            
            guard let nameProductCString = sqlite3_column_text(stmt, 1) else {
                continue
            }
            
            guard let imagePathCString = sqlite3_column_text(stmt, 3) else {
                continue
            }
            
            guard let categorieCString = sqlite3_column_text(stmt, 4) else {
                continue
            }
            
            let codeBarProduct = String(cString: codeBarProductCString)
            let nameProduct = String(cString: nameProductCString)
            let numberProduct = Int(sqlite3_column_int(stmt, 2))
            let imagePathProduct = String(cString: imagePathCString)
            let categorieProduct = String(cString: categorieCString)
            
            let productToAdd = Product(
                codeBar: codeBarProduct,
                name: nameProduct,
                number: numberProduct,
                imagePath: imagePathProduct,
                categorie: categorieProduct)
            
            products.append(productToAdd)
        }
        
        return products
    }
    
    public func SelectProduct(withCodeBar codeBar : String) -> Product?
    {
        let request = "SELECT * FROM Product WHERE codeBar = ?;"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(dataBase, request, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
            print("error creating table: \(errmsg)")
        }
        
        if sqlite3_bind_text(stmt, 1, codeBar, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
            print("failure binding name: \(errmsg)")
            return nil
        }
        
        if sqlite3_step(stmt) == SQLITE_ROW {
            
            guard let codeBarProductCString = sqlite3_column_text(stmt, 0) else {
                return nil
            }
            
            guard let nameProductCString = sqlite3_column_text(stmt, 1) else {
                return nil
            }
            
            guard let imagePathCString = sqlite3_column_text(stmt, 3) else {
                return nil
            }
            
            guard let categorieCString = sqlite3_column_text(stmt, 4) else {
                return nil
            }
            
            let codeBarProduct = String(cString: codeBarProductCString)
            let nameProduct = String(cString: nameProductCString)
            let numberProduct : Int = Int(sqlite3_column_int(stmt, 2))
            let imagePathProduct = String(cString: imagePathCString)
            let categorieProduct = String(cString: categorieCString)
            
            let product = Product(
                codeBar: codeBarProduct,
                name: nameProduct,
                number: numberProduct,
                imagePath: imagePathProduct,
                categorie: categorieProduct)
            
            return product
        }
        
        return nil
    }
}
