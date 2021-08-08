//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Muteb Alolayan on 06/08/2021.
//

import Foundation
import CoreData

class DataController {
    let container:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return container.viewContext
    }
    let backgroundContext:NSManagedObjectContext!
    
    init(modalName: String) {
        container = NSPersistentContainer(name: modalName)
        backgroundContext = container.newBackgroundContext()
    }
    
    func load(completion: (() -> Void)? = nil) {
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
}

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        print("autosaving")
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
