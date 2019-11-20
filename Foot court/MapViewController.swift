//
//  MapViewController.swift
//  Foot court
//
//  Created by Admin on 14/11/2019.
//  Copyright © 2019 Anton Varenik. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}


class MapViewController: UIViewController {

    var mapViewControllerDelegate: MapViewControllerDelegate?
    let annotationIdentifier = "annotationIdentifier"
    var place = Place()
    let locationManager = CLLocationManager()
    let regionInMeters = 10_000.00
    var incomeSegueIndentifier = ""
    var placeCoordinate: CLLocationCoordinate2D?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var addressLable: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addressLable.text = ""
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
    }
    
    @IBAction func centerViewInUserLocation() {
        
        showUserLocation()
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLable.text)
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
        getDirections()
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        
        if incomeSegueIndentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLable.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
    private func setupPlacemark() {
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            if error != nil {
                print("error with map")
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are disabled",
                               message: "To enable it go: Settings -> Privacu -> Location Services and turn On")
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func showUserLocation() {
        
        if let location = locationManager.location?.coordinate {
                 let region = MKCoordinateRegion(center: location,
                                                 latitudinalMeters: regionInMeters,
                                                 longitudinalMeters: regionInMeters)
                 mapView.setRegion(region, animated: true)
             }
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIndentifier == "getAddress" { showUserLocation() }
            break
        case .denied:
            // alert
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }
    
    private func getDirections() {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        guard let request = createDitectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
            
        }
        
        let diractions = MKDirections(request: request)
        
        diractions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "diraction is not available")
                return
            }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1.f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime / 60
                
                print("Растояние до места \(distance) км.")
                print("Время в пути составит: \(timeInterval) мин.")
            }
        }
    }
    
    private func createDitectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate =  placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
           
           let latitude = mapView.centerCoordinate.latitude
           let longitude = mapView.centerCoordinate.longitude
           
           return CLLocation(latitude: latitude, longitude: longitude )
       }
    
    private func showAlert(title: String, message: String) {
           
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let okAction = UIAlertAction(title: "OK", style: .default)
           
           alert.addAction(okAction)
           present(alert, animated: true)
       }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
         
        guard !(annotation is MKUserLocation) else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLable.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLable.text = "\(streetName!)"
                } else {
                    self.addressLable.text = ""
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
    
}

extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
