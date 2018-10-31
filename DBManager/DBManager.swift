//
//  DBManager.swift
//  SqlDemo
//
//  Created by SOTSYS026 on 14/08/18.
//  Copyright © 2018 SOTSYS026. All rights reserved.
//

import UIKit

struct TableFields {
    static let field_userId = "userId"
    static let field_password = "password"
}


class DBManager: NSObject {

    static let shared:DBManager = DBManager()
    let dbFileName = "database.sqlite"
    var pathToDatabase:NSString!
    var database:FMDatabase!
   
    
    override init() {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as? NSString
        pathToDatabase = (documentDirectory?.appending("/\(dbFileName)"))! as NSString
        print("pathToDatabase \(pathToDatabase)")
    }
    
    func createDatabase()-> Bool{
        var isCreated = false
        
        if !FileManager.default.fileExists(atPath: pathToDatabase as String){
            database = FMDatabase (path: pathToDatabase as String?)
            
            if database != nil{
                
                if database.open(){
                     let createUserTableQuery = "create table user(\(TableFields.field_userId) text primary key not null,\(TableFields.field_password) text not null)"
                    do{
                     try database.executeUpdate(createUserTableQuery, values: [])
                    isCreated = true
                    }catch{
                        print("can't create table")
                    }
                    database.close()
                    
                }else{
                    print("can't open Database")
                }
                
            }
        }
        
        return isCreated
    
    }
    
    func openDatabase() -> Bool{
        
        if database == nil{
            if FileManager.default.fileExists(atPath: pathToDatabase as String){
                database = FMDatabase (path: pathToDatabase! as String)
            }
        }
        if database != nil{
            if database.open(){
                return true
            }
        }
        
        return false
    }
    
    func insertData(userName:String,password:String){
        let query = "insert into user (\(TableFields.field_userId),\(TableFields.field_password)) values('\(userName)','\(password)')"
        print(query)
        if openDatabase(){
            if !database.executeStatements(query){
                print("Unable to insert data")
            }
            database.close()
        }
    }
    
    func isValidForSignIn(email:String,password:String) -> Bool{
        let query = "select * from user where \(TableFields.field_userId) == ? AND \(TableFields.field_password) == ?"
        //
        print(query)
        if openDatabase(){
            do{

                let results = try database.executeQuery(query, values: [email,password])
               if results.next(){
                    print(results)
                    database.close()
                    return true
                }
                    database.close()
                     return false
            }catch{
                print(error.localizedDescription)
                database.close()
                return false
            }
    }
        database.close()
        return false
    }
    

}
