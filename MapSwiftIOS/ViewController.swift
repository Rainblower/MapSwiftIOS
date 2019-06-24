//
//  ViewController.swift
//  MapSwiftIOS
//
//  Created by WSR on 19/06/2019.
//  Copyright © 2019 WSR. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var userLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var mapItems: [MapItem] = []
        let mapItem = MapItem(title: "kek", coord: CLLocationCoordinate2D(latitude: 55, longitude: 37))
        let mapItem1 = MapItem(title: "lol", coord: CLLocationCoordinate2D(latitude: 55, longitude: 37.2))

        mapItems.append(mapItem)
        mapItems.append(mapItem1)
        
        mapView.delegate = self
        
        mapView.showsUserLocation = true
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        
        for item in mapItems {
            let annotation = MKAnnotationView()
            let anno = MKPointAnnotation()
            anno.coordinate = item.coord
            anno.title = item.title
            annotation.annotation = anno

            annotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotation.image = UIImage(named: "kek")
            mapView.addAnnotation(annotation.annotation!)
            
        }
        // Do any additional setup after loading the view.
    }


}

extension ViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        userLocation = locations.last
        
       
        let region = MKCoordinateRegion(center: userLocation!.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let request = MKDirections.Request()
        
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: view.annotation!.coordinate))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            guard let response = response else {
                let alert = UIAlertController(title: "Rout cant be build", message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            for rout in response.routes {
                self.mapView.addOverlay(rout.polyline)
                self.mapView.setVisibleMapRect(rout.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        render.strokeColor = .blue
        render.lineWidth = 2
        return render
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.title == "My Location" {
            return nil
        }
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
            
            let image = UIImage(named: "kek")
            UIGraphicsBeginImageContext(CGSize(width: 25, height: 25))
            imageView.image = image
            imageView.image?.draw(in: CGRect(x: 0, y: 0, width: 25, height: 25))
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
            view.titleVisibility = .hidden
            view.leftCalloutAccessoryView = imageView
            view.detailCalloutAccessoryView = imageView
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
   
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        let location = view.annotation
//
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MKAnnotation {
   
}
