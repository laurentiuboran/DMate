//
//  MapView.swift
//  DMate
//
//  Created by Laurențiu Boran on 23/04/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
      @ObservedObject var viewModel = SessionStore()
    
      @State var selectionsLocation: [String] = []
  
      var locationManager = CLLocationManager()

      func setupManager() {
        
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
      }
      
      func makeUIView(context: Context) -> MKMapView {
        
            setupManager()
            let mapView = MKMapView(frame: UIScreen.main.bounds)
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
            return mapView
      }
    
    func pinDetails(lat: Double, long: Double, pinColor: String) -> MKPointAnnotation {
        
        let mylocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let coordinate = CLLocationCoordinate2D(
            latitude: lat, longitude: long)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: coordinate, span: span)

        let annotation = MKPointAnnotation()
        annotation.coordinate = mylocation
        
        if (pinColor == "Slabe") {
            annotation.title = "Șanse slabe de infecție"
        }
        if (pinColor == "Medii") {
            annotation.title = "Șanse medii de infecție"
        }
        if (pinColor == "Mari") {
            annotation.title = "Șanse mari de infecție"
        }
        
        return annotation
    }
      
      func updateUIView(_ view: MKMapView, context: Context) {
        
            view.mapType = MKMapType.standard
            
            self.viewModel.fetchDataLocation()
            
            for user in viewModel.loc {
                let coord = (user.location).components(separatedBy: ", ")
                let infectedTitle = user.infectedScore
                
                var lat = coord[0]
                var long = coord[1]
                
                guard var dLat = Double(lat) else { return }
                guard var dLong = Double(long) else { return }
                
                view.addAnnotation(pinDetails(lat: dLat ?? 0, long: dLong ?? 0, pinColor: infectedTitle))
            }
      }
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
