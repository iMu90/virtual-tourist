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

class ImagesCollectionView: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapOutlet: MKMapView!
    @IBOutlet weak var newCollectionBtnOutlet: UIButton!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    let flickerApi = FlickerApi()
    var pageNumber = 0
        
    var location: GeoLocation = GeoLocation()
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<Images>!
    
    var dataLocation: GeoLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
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
        flickerApi.getImages(location: location, pageNumber: pageNumber) { success, data, error in
            if error != nil || !success {
                self.generateAlert(title: "ERROR", message: "OPS! could not load Images", actionTitle: "OK")
            } else {
                if (data?.photos.photo.count)! > 0 {
                    print("image count: \(String(describing: data?.photos.photo.count))")
                    if let images = data?.photos.photo {
                        for photo in images {
                            let imgUrl = "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_w.jpg"
                            self.flickerApi.downloadImg(url: imgUrl) { data, error in
                                guard error == nil else {
                                    self.generateAlert(title: "ERROR", message: "something went wrong", actionTitle: "OK")
                                    return
                                }
                                if let data = data {
                                    let img = Images(context: self.dataController.viewContext)
                                    img.data = data
                                    img.name = photo.title
                                    img.url = imgUrl
                                    img.location = self.location
                                    self.location.addToImages(img)
                                } else {
                                    print("data not saved")
                                }
                            }
                            
                            try? self.dataController.viewContext.save()
            
                        }
                    }
                    
                } else {
                    print("no returned image: \(String(describing: data?.photos.photo.count))")
                }
            }
        }
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
        
        reloadImages()
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
        location.images = []
        fetchLocations()
        
    }
    
    
    func reloadImages() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }

    }
}

extension ImagesCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return location.images?.count ?? 0
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgCollectionCell", for: indexPath) as! CollectionViewCell
        
        if let data = location.images {
            let array = data.allObjects
            let photo = array[indexPath.row] as! Images
            let image: UIImage = UIImage(data: photo.data!)!
            cell.image.image = image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let data = location.images {
            let array = data.allObjects
            
            let selected = array[indexPath.row] as! Images
            location.removeFromImages(selected)
            reloadImages()
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

