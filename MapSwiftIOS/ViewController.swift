//
//  ViewController.swift
//  MapSwiftIOS
//
//  Created by WSR on 19/06/2019.
//  Copyright © 2019 WSR. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import RealmSwift
import SwiftyJSON
import Contacts

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    var userLocation: CLLocation!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        mapView.showsUserLocation = true
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        fetchData()
    }
    
    func fetchData() {
        guard let url = URL(string: "http://cars.areas.su/arts") else { return }
        
        Alamofire.request(url, method: .get).validate().responseJSON{ (response) in
            switch response.result {
            case .success(_):
                guard let data = response.data else { return }

                do {
                    let arts = try JSONDecoder().decode([Art].self, from: data)
                    
                    let realm = try! Realm()
                    
                    try realm.write {
                        realm.add(arts,update: .modified)
                    }
                    
                    self.addAnntotation(arts: realm.objects(Art.self))
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addAnntotation(arts: Results<Art>) {
        for art in arts {
            let annotation = CustomMKPointAnnotation()

            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(art.lat)!), longitude: CLLocationDegrees(Double(art.long)!))
            annotation.title = art.title
            annotation.subtitle  = art.subTitle
            annotation.image = art.image
            
            self.mapView.addAnnotation(annotation)
        }
    }
}

extension ViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        userLocation = locations.last
        
        
        let region = MKCoordinateRegion(center: userLocation!.coordinate, latitudinalMeters: 50000, longitudinalMeters: 50000)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        mapView.removeOverlays(mapView.overlays)
        
        let request = MKDirections.Request()
        
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: view.annotation!.coordinate))
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
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
        guard let anno = annotation as? CustomMKPointAnnotation else { return nil}
        
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier){
            dequeuedView.annotation = annotation
            view = dequeuedView as! MKMarkerAnnotationView
        } else {
            
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)

            let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 200, height: 200)))
            
            if let url = URL(string: anno.image) {
                  do {
                let data = try Data(contentsOf: url)
                
                let image = UIImage(data: data)
                    view.leftCalloutAccessoryView = imageView
                imageView.image = image
                  } catch {
                    print(error)
                }
            }
            
          
                
                
                
                
//
                
                let detailLabel = UILabel()
                detailLabel.numberOfLines = 0
                detailLabel.font = detailLabel.font.withSize(12)
                detailLabel.text = anno.subtitle
                view.detailCalloutAccessoryView = detailLabel

//                let vw = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 400))
//                vw.backgroundColor = .black
//                vw.addSubview(textView)
//                view.detailCalloutAccessoryView = imageView
                
            
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

extension MKPointAnnotation {
   
}
