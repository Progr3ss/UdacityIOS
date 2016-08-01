//
//  Pin.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 7/21/16.
//  Copyright © 2016 martin chibwe. All rights reserved.

import Foundation
import CoreData
import MapKit


class Pin: NSManagedObject, MKAnnotation {

    @NSManaged var latitude: NSNumber!
    @NSManaged var longitude: NSNumber!
    @NSManaged var photos: [Photo]
    @NSManaged var flickr: PinFlickr
    var coordinate: CLLocationCoordinate2D {
        set {
            latitude = NSNumber(double: newValue.latitude)
            longitude = NSNumber(double: newValue.longitude)
        }
        get {
            return CLLocationCoordinate2D(latitude: latitude as Double, longitude: longitude as Double)
        }
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)

        super.init(entity: entity!, insertIntoManagedObjectContext: context)

        self.latitude = NSNumber(double: latitude)
        self.longitude = NSNumber(double: longitude)
        self.flickr = PinFlickr(context: context)
    }


    func deletePhotos(context: NSManagedObjectContext, handler: (error: String?) -> Void) {
        let request = NSFetchRequest(entityName: "Photo")
        request.predicate = NSPredicate(format: "pin == %@", self)

        do {
            let photos = try context.executeFetchRequest(request) as! [Photo]
            for photo in photos {
                context.deleteObject(photo)
            }
        } catch { }

        handler(error: nil)
    }
}