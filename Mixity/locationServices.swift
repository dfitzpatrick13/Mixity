//
//  locationSerivces .swift
//  Mixity
//
//  Created by Daniel Fitzpatrick on 3/29/23.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit


struct Pin: Identifiable{
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
/// All Map Data Goes Here....


class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate  {
    let locationManager: CLLocationManager
    @Published var mapView = MKMapView()
    
    ///region...
    @Published var region : MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020), span: MKCoordinateSpan())
    // Based On Location It Will Set Up....
    
    // Alert...
    
    @Published var permissionDenied = false
    
    // Map Type...
    @Published var mapType : MKMapType = .standard
    
    // SearchText...
    @Published var searchTxt = ""
    // Searched Places...
    @Published var places : [Place] = []
    
    
    // Updating Map Type...
    
    func updateMapType(){
        if mapType == .standard{
            mapType = .hybrid
            mapView.mapType = mapType
        }
        else{
            mapType = .standard
            mapView.mapType = mapType
        }
    }
    
    // Focus Location...
    
    func focusLocation(){
//        guard let region = region else{return}
        
        mapView.setRegion(region, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    // Search Places...
    
    func searchQuery() async {
        
        places.removeAll()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTxt
        
        //Fetch...
        
        guard let result = try? await MKLocalSearch(request: request).start() else {
            return
        }
        
        
        self.places = result.mapItems.compactMap {
            Place(place: $0.placemark)
        }
    }
    // Pick Search Result...
    func selectPlace(place: Place) {
        // Showing Pin On Map....
        
        searchTxt = ""
        
        guard let coordinate = place.place.location?.coordinate else{return}
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        pointAnnotation.title = place.place.name ?? "No Names"
        
        // Removing all Old Ones...
        mapView.removeAnnotations(mapView.annotations)
        
        mapView.addAnnotation(pointAnnotation)
        
        // Moving Map to That Location...
        
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000 )
        
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
        // Moving Map To That Location...
        
        //        MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
       // let MKcoordinateRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan())
        
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
        
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Checking Permissions...
        
        switch manager.authorizationStatus {
        case .notDetermined:
            // requesting....
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            /// If Permission Given...
            manager.requestLocation()
        default:
            ()
 
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        //error...
        print(error.localizedDescription)
    }
    
    // Getting user Region....
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{return}
        
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        // Updating Map....
        self.mapView.setRegion(self.region, animated: true)
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
        
    }
    
    
    private func checkLocationAuthorization() {
        switch self.locationManager.authorizationStatus{
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location is restricted")
        case .denied:
            print("Location is denied")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            guard let userLocation = locationManager.location else {
                print("could not determine user location")
                return
            }
            region = MKCoordinateRegion(center: userLocation.coordinate,
                                         span: MKCoordinateSpan(latitudeDelta:0.05 , longitudeDelta: 0.05))
        }
    }
    
    override init () {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        self.checkLocationAuthorization()
    }
}
struct Place: Identifiable {
    
    var id = UUID().uuidString
    var place: CLPlacemark
}


