//
//  NoteBook+CoreDataProperties.swift
//  CoreDataTest
//
//  Created by martin chibwe on 7/30/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension NoteBook {

    @NSManaged var name: String?
    @NSManaged var creationData: NSDate?
    @NSManaged var notes: NSManagedObject?

}
