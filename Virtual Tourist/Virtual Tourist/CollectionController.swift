//
//  CollectionController.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 7/24/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionController: ViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    var pin: Pin? = nil


    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!

	
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!);

        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = self.editButtonItem()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "OK", style: .Plain, target: self, action: #selector(CollectionController.goBackToMap))

        newCollectionButton.addTarget(self, action: #selector(CollectionController.loadNewPhotos), forControlEvents: .TouchUpInside)

        mapView.addAnnotation(pin!)
        mapView.setRegion(MKCoordinateRegion(center: pin!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        mapView.userInteractionEnabled = false

        collectionView.delegate = self
        collectionView.dataSource = self

        fetchedResultsController.delegate = self

        setupCollectionFlowLayout()
    }

    override func viewWillAppear(animated: Bool) {
        do {
            try fetchedResultsController.performFetch()
         
        } catch { }

		
        if fetchedResultsController.fetchedObjects!.count == 0 {
            loadNewPhotos()
        }
    }

	
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: false)

		
        UIView.animateWithDuration(0.3, animations: {
            self.view.constraints.filter({ $0.identifier == "HintLabelToBottom" }).first!.constant = editing ? 0 : -self.hintLabel.frame.height
            self.newCollectionButton.enabled = !editing
            self.view.layoutIfNeeded()
        })
    }

	
    func loadNewPhotos() {
        newCollectionButton.enabled = false

		
        pin!.deletePhotos(context) { _ in }

		
        pin!.flickr.loadNewPhotos(context, handler: { _ in
            self.context.saveData()
            self.newCollectionButton.enabled = true
        })
    }

    func goBackToMap() {
        navigationController?.popViewControllerAnimated(true)
		
    }


    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }

 
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell

        cell.photo = photo

        return cell
    }


    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if editing {
            context.deleteObject(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
            context.saveData()

         
        }
    }

    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        setupCollectionFlowLayout()
    }


    func setupCollectionFlowLayout() {
        let items: CGFloat = view.frame.size.width > view.frame.size.height ? 5.0 : 3.0
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - ((items + 1) * space)) / items

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 8.0 - items
        layout.minimumInteritemSpacing = space
        layout.itemSize = CGSizeMake(dimension, dimension)

        collectionView.collectionViewLayout = layout
    }
}

extension CollectionController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = []
        deletedIndexPaths = []
    }

 
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        default: ()
        }
    }


    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }

            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            }, completion: nil)
    }
}
