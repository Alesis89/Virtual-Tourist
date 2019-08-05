//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Bill Clark on 7/16/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataController{
    
    
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil){
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
