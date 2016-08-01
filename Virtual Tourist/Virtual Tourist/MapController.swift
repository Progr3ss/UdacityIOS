//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 7/23/16.
//  Copyright © 2016 martin chibwe. All rights reserved.

import UIKit
import MapKit
import CoreData

class MapController: ViewController, MKMapViewDelegate {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem()

        mapView.delegate = self
        mapView.addAnnotations(fetchAllPins())
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(MapController.createPin(_:))))

  
        if let region = Config.shared.mapRegion {
            mapView.setRegion(region, animated: true)
        }
    }

	
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: false)


        UIView.animateWithDuration(0.3, animations: {
            self.view.frame.origin.y += self.hintLabel.frame.height * (editing ? -1 : 1)
        })
    }

    func fetchAllPins() -> [Pin] {
        do {
	
            return try context.executeFetchRequest(NSFetchRequest(entityName: "Pin")) as! [Pin]
        } catch {
            print("Could not load pins")
            return []
        }
    }

	
    func createPin(sender: UIGestureRecognizer) {
        if sender.state == .Began {
            let point = sender.locationInView(mapView)
            let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)

            let pin = Pin(latitude: coordinate.latitude as Double, longitude: coordinate.longitude as Double, context: context)

            pin.flickr.loadNewPhotos(context, handler: { _ in self.context.saveData() })

            mapView.addAnnotation(pin)

            context.saveData()

			
        }
    }

    func viewPin(pin: Pin) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("CollectionController") as! CollectionController

        controller.pin = pin

        navigationController!.pushViewController(controller, animated: true)

		
    }

    func deletePin(pin: Pin) {
        mapView.removeAnnotation(pin)
        context.deleteObject(pin)
        context.saveData()


    }

	
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        Config.shared.mapRegion = mapView.region
        Config.shared.save()


    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pin"
        let pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)

        pinView.animatesDrop = true
        pinView.draggable = true

        pinView.selected = true

        return pinView
    }


    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if editing == false && oldState == .Ending {
            let pin = view.annotation as! Pin

  
            pin.deletePhotos(context, handler: { _ in self.context.saveData() })
            pin.flickr.loadNewPhotos(context, handler: { _ in self.context.saveData() })


        }
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let pin = view.annotation as! Pin


        mapView.deselectAnnotation(pin, animated: false)

        editing ? deletePin(pin) : viewPin(pin)
    }

  
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        view.selected = true
    }
}
