//
//  CoreData.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 7/24/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//

import Foundation
import CoreData


private let SQLITE_FILE_NAME = "Model.sqlite"

class CoreDataStackManager {


    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }

        return Static.instance
    }


    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count - 1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
//        let mapKitBundle = NSBundle(identifier: "com.martin.virtual")
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "mom")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()



    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {

        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)

        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
 
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
}

extension NSManagedObjectContext {
	
    func saveData() {
        if self.hasChanges {
            do {
                try self.save()
            } catch {
				
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}