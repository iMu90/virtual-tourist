//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Muteb Alolayan on 29/07/2021.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapOutlet: MKMapView!
    var pins: [Any] = []
    
    let flickerApi = FlickerApi()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapOutlet.delegate = self
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(userClickedOnMap))
        gestureRecognizer.delegate = self
        mapOutlet.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func userClickedOnMap(gestureReconizer: UIGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let location = gestureReconizer.location(in: mapOutlet)
            let coordinate = mapOutlet.convert(location,toCoordinateFrom: mapOutlet)
            print("\(String(coordinate.latitude))")
            print("\(String(coordinate.longitude))")

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapOutlet.addAnnotation(annotation)
            
            flickerApi.getImages(lat: String(coordinate.latitude), lang: String(coordinate.longitude))
        }
    }

}

