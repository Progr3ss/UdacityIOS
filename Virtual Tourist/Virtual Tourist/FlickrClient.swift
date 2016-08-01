//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 7/23/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
import Foundation

/*
 * Flickr API client
 */
class FlickrClient: ApiClient {

    let apiUrl = "https://api.flickr.com/services/rest/"
    let apiKey = "d060b0817c13d941fb52add2e2bfef42"

	
    static let shared = FlickrClient()

  
    func searchPhotosByCoordinate(latitude: Double, longitude: Double, page: Int = 1, handler: (photos: [[String : AnyObject]]?, pages: Int, error: String?) -> Void) {

        let params = [
            "method": "flickr.photos.search",
            "api_key": apiKey,
            "bbox": createBoundingBoxString(latitude, longitude: longitude),
            "safe_search": "1",
            "extras": "url_m",
            "format": "json",
            "nojsoncallback": "1",
            "per_page": "30",
            "page": String(page),
        ]

        let request = prepareRequest("\(apiUrl)", params: params)

        processResuest(request) { (result, error) -> Void in
            guard error == nil else {
                handler(photos: nil, pages: 0, error: error)
                return
            }

            guard let photoData = result!["photos"] as? [String : AnyObject] else {
				
                handler(photos: nil, pages: 0, error: "Wrong response")
                return
            }

            guard let pages = photoData["pages"] as? Int else {
				
                handler(photos: nil, pages: 0, error: "Wrong response")
                return
            }

            guard let results = photoData["photo"] as? [[String : AnyObject]] else {
              
                handler(photos: nil, pages: 0, error: "Wrong response")
                return
            }

            handler(photos: results, pages: pages, error: nil)
        }
    }

    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {

        let BOUNDING_BOX_HALF_WIDTH = 1.0
        let BOUNDING_BOX_HALF_HEIGHT = 1.0
        let LAT_MIN = -90.0
        let LAT_MAX = 90.0
        let LON_MIN = -180.0
        let LON_MAX = 180.0


        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)

        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
}
