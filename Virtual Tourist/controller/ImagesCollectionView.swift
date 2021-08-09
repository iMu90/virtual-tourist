//
//  ImagesCollectionView.swift
//  Virtual Tourist
//
//  Created by Muteb Alolayan on 29/07/2021.
//
import Foundation
import UIKit
import MapKit
import CoreData

class ImagesCollectionView: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapOutlet: MKMapView!
    @IBOutlet weak var newCollectionBtnOutlet: UIButton!
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var numberOfImages = 10
    let flickerApi = FlickerApi()
    var pageNumber = 0
        
    var location: GeoLocation = GeoLocation()
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<Images>!
    
    var dataLocation: GeoLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        activityIndicator.startAnimating()
        collectionView.delegate = self
        collectionView.dataSource = self
        mapOutlet.delegate = self
        let annotation = MKPointAnnotation()
        let lat = CLLocationDegrees(location.latitude!)
        let long = CLLocationDegrees(location.longitude!)
        let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        annotation.coordinate = coordinate
        mapOutlet.addAnnotation(annotation)
        mapOutlet.centerCoordinate = coordinate
        setupFetchedResultsController()
        self.fetchLocations()
        collectionView.reloadData()
    }
    
    func loadImagesFromFlicker() {
        pageNumber += 1
//        activityIndicator.startAnimating()
        flickerApi.getImages(location: location, pageNumber: pageNumber) { success, data, error in
            if error != nil || !success {
                self.generateAlert(title: "ERROR", message: "OPS! could not load Images", actionTitle: "OK")
            } else {
                if (data?.photos.photo.count)! > 0 {
                    print("image count: \(String(describing: data?.photos.photo.count))")
                    if let images = data?.photos.photo {
                        for photo in images {
                            let imgUrl = "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_w.jpg"
                            let img = Images(context: self.dataController.viewContext)
                            img.url = imgUrl
                            img.name = photo.title
                            img.location = self.location
                            self.location.addToImages(img)
                            DispatchQueue.main.async {
                                self.newCollectionBtnOutlet.isEnabled = true
//                                self.activityIndicator.stopAnimating()
                            }
                            
                        }
                    }
                    
                    self.reloadImages()
                    
                    
                    
                } else {
                    print("no returned image: \(String(describing: data?.photos.photo.count))")
                }
            }
        }
        
        try? self.dataController.viewContext.save()
        
    }
    
    
    // TAKING FROM UDACITY MENTOR/REVIEWER 
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }


        return pinView
    }
    
    func fetchLocations() {
        let fetchRequest:NSFetchRequest<Images> = fetchedResultsController.fetchRequest
        do {
            let savedImage = try dataController.viewContext.fetch(fetchRequest)
            if savedImage.count == 0 {
                print("no images, fetching api")
                loadImagesFromFlicker()
                
            }
        } catch {
            print("cannot fetch saved content")
        }
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Images> = Images.fetchRequest()
        let predicate = NSPredicate(format: "location == %@", location)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(String(describing: location.latitude))-\(String(describing: location.latitude))-images")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    @IBAction func newCollectionBtn(_ sender: Any) {
//        activityIndicator.startAnimating()
        newCollectionBtnOutlet.isEnabled = false
        if let imgs = location.images {
            location.removeFromImages(imgs)
            fetchLocations()
//            reloadImages()
        }
        
    }
    
    
    func reloadImages() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }

    }
}

extension ImagesCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = location.images?.count {
            if count == 0 {
                return numberOfImages
            } else {
                return count
            }
        }
        
        return numberOfImages
//        return location.images?.count == 0 ? 10 : location.images?.count!
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgCollectionCell", for: indexPath) as! CollectionViewCell
        
        cell.image.image = UIImage(systemName: "photo")?.withRenderingMode(.alwaysOriginal)
        cell.activity.startAnimating()
        
        if let images = location.images {
            if images.count > 0 && images.count > indexPath.row{
                let index = images.allObjects[indexPath.row] as! Images
                if let url = index.url {
                    self.flickerApi.downloadImg(url: url) { data, error in
                        guard error == nil else {
                            self.generateAlert(title: "ERROR", message: "something went wrong", actionTitle: "OK")
                            return
                        }
                        
                        if let data = data {
                            let img = Images(context: self.dataController.viewContext)
                            img.data = data
                            let image: UIImage = UIImage(data: data)!
                            index.data = data
                            DispatchQueue.main.async {
                                cell.image.image = image
                                cell.activity.stopAnimating()
//                                self.activityIndicator.stopAnimating()
                            }
                            
                            
                        } else {
                            print("data not saved")
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let data = location.images {
            let array = data.allObjects
            
            let selected = array[indexPath.row] as! Images
            location.removeFromImages(selected)
            self.dataController.viewContext.delete(selected)
            numberOfImages -= 1
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let space:CGFloat = 5.0
        var dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        if view.frame.width > view.frame.height {
            dimension /= 2.0
        }
        return CGSize(width: dimension, height: dimension)
    }
}
