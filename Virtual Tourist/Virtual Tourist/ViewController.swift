//
//  UIViewControllerExtension.swift
//  OnTheMap
//
//  Created by martin chibwe on 7/24/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {


    lazy var context: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
}
