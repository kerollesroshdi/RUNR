//
//  BeginRunVC.swift
//  RUNR
//
//  Created by Kerolles Roshdi on 11/21/18.
//  Copyright © 2018 Kerolles Roshdi. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class BeginRunVC: LocationVC {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var lastRunView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        manager?.delegate = self
        manager?.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupMapView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        manager?.stopUpdatingLocation()
    }
    
    func setupMapView() {
        if let overlay = addLastRunToMap() {
            if mapView.overlays.count > 0 {
                mapView.removeOverlays(mapView.overlays)
            }
            mapView.addOverlay(overlay)
            lastRunView.isHidden = false
        } else {
            lastRunView.isHidden = true
            centerMapOnUserLocation()
        }
    }
    
    func addLastRunToMap() -> MKPolyline? {
        guard let lastRun = Run.getAllRuns()?.first else { return nil }
        paceLbl.text = lastRun.pace.formatTimeDurationToString()
        distanceLbl.text = "\(lastRun.distance.meterToMiles(places: 2)) mi"
        durationLbl.text = lastRun.duration.formatTimeDurationToString()
        
        var coordinate = [CLLocationCoordinate2D]()
        for location in lastRun.locations {
            coordinate.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
        mapView.userTrackingMode = .none
        mapView.setRegion(centerMapOnPreviousRoute(locations: lastRun.locations), animated: true)
        
        return MKPolyline(coordinates: coordinate, count: lastRun.locations.count)
    }
    
    func centerMapOnUserLocation() {
        mapView.userTrackingMode = .follow
        let coordinateRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func centerMapOnPreviousRoute(locations: List<Location>) -> MKCoordinateRegion {
        guard let initialLocation = locations.first else { return MKCoordinateRegion() }
        var minlat = initialLocation.latitude
        var minlng = initialLocation.longitude
        var maxlat = minlat
        var maxlng = minlng
        
        for location in locations {
            minlat = min(minlat, location.latitude)
            minlng = min(minlng, location.longitude)
            maxlat = max(maxlat, location.latitude)
            maxlng = max(maxlng, location.longitude)
        }
        
        return MKCoordinateRegion(center: CLLocationCoordinate2DMake((minlat + maxlat) / 2, (minlng + maxlng) / 2), span: MKCoordinateSpan(latitudeDelta: (maxlat - minlat) * 1.4, longitudeDelta: (maxlng - minlng) * 1.4))
    }
    
    @IBAction func locationCenterBtnPressed(_ sender: Any) {
        centerMapOnUserLocation()
    }
    
    
    @IBAction func lastRunCloseBtnPressed(_ sender: Any) {
        lastRunView.isHidden = true
        centerMapOnUserLocation()
    }
    
}

extension BeginRunVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkLocationAuthStatus()
            mapView.showsUserLocation = true
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        let render = MKPolylineRenderer(polyline: polyline)
        render.strokeColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        render.lineWidth = 4
        return render
    }
}
