//
//  StorageManager.swift
//  Foot court
//
//  Created by Admin on 08/11/2019.
//  Copyright © 2019 Anton Varenik. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
   
    static func saveObject(_ place: Place) {
        
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Place) {
        
        try! realm.write {
            realm.delete(place) 
        }
    }
    
}
