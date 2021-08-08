//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Muteb Alolayan on 29/07/2021.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapOutlet: MKMapView!
    var locations: [GeoLocation] = []
    var location: GeoLocation = GeoLocation()
    
//    let flickerApi = FlickerApi()
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<GeoLocation>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapOutlet.delegate = self
        self.setupFetchedResultsController()
        self.fetchLocations()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(userClickedOnMap))
        gestureRecognizer.delegate = self
        mapOutlet.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func userClickedOnMap(gestureReconizer: UIGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let location = gestureReconizer.location(in: mapOutlet)
            let coordinate = mapOutlet.convert(location,toCoordinateFrom: mapOutlet)

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapOutlet.addAnnotation(annotation)
            
            self.savePinLocation(lat: String(coordinate.latitude), lon: String(coordinate.longitude))
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let selected = view.annotation
        for location in locations {
            let lat = CLLocationDegrees(location.latitude!)
            let long = CLLocationDegrees(location.longitude!)
            if lat == selected?.coordinate.latitude && long == selected?.coordinate.longitude {
                let collectionView = storyboard?.instantiateViewController(identifier: "collectionView") as! ImagesCollectionView
                collectionView.location = location
                collectionView.dataController = dataController
                self.location = location
                performSegue(withIdentifier: "imgCollectionSegue", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! ImagesCollectionView
        controller.location = location
        controller.dataController = dataController
        
    }
    
    func savePinLocation(lat: String, lon: String) {
        let location = GeoLocation(context: dataController.viewContext)
        location.latitude = lat
        location.longitude = lon
        location.images = []
        try? dataController.viewContext.save()
        
        fetchLocations()
    }
    
    func fetchLocations() {
        let fetchRequest:NSFetchRequest<GeoLocation> = fetchedResultsController.fetchRequest
        var annotations = [MKPointAnnotation]()
        do {
            let savedLocation = try dataController.viewContext.fetch(fetchRequest)
            for location in savedLocation {
                let annotation = MKPointAnnotation()
                let lat = CLLocationDegrees(location.latitude!)
                let long = CLLocationDegrees(location.longitude!)
                let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                annotation.coordinate = coordinate
                annotations.append(annotation)
            }
            
            locations = savedLocation
            
            mapOutlet.addAnnotations(annotations)
            
        } catch {
            print("cannot fetch saved content")
        }
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<GeoLocation> = GeoLocation.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "locations")
        
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

}

