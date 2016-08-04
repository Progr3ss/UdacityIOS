//
//  PinFlickr.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 7/21/16.
//  Copyright © 2016 martin chibwe. All rights reserved.

import Foundation
import CoreData

class PinFlickr: NSManagedObject {

    @NSManaged var nextPage: Int32
    @NSManaged var totalPages: Int32
    @NSManaged var pin: Pin


    var loading = false

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(nextPage: Int32 = 1, totalPages: Int32 = 1, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("PinFlickr", inManagedObjectContext: context)

        super.init(entity: entity!, insertIntoManagedObjectContext: context)

        self.nextPage = nextPage
        self.totalPages = totalPages
    }


    func loadNewPhotos(context: NSManagedObjectContext, handler: (error: String?) -> Void) {
        if loading {
            return handler(error: "Loading in progress")
        }

        loading = true



        FlickrClient.shared.searchPhotosByCoordinate(pin.latitude as Double, longitude: pin.longitude as Double, page: Int(nextPage)) { (photos, pages, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                guard error == nil else {
                    return handler(error: error)
                }

                for photo in photos! where photo["url_m"] != nil {
                    _ = Photo(flickrDictionary: photo, pin: self.pin, context: context)
                }

                self.loading = false

				
                self.totalPages = Int32(min(10, pages))
                self.nextPage = Int32(self.totalPages >= (self.nextPage + 1) ? self.nextPage + 1 : 1)
          

                return handler(error: nil)
            })
        }
    }
}
