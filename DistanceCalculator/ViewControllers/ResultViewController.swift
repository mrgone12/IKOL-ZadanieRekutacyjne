//
//  ResultViewController.swift
//  IKOL-ZadanieRekutacyjne
//
//  Created by Piotr on 13/05/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ResultViewController: UIViewController, MKMapViewDelegate{
    
    let mapView: MKMapView = MKMapView()
    
    let distanceView: UIView =
    
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var distanceKilometersLabel: UILabel!
    
    
    var firstPoint: CLLocationCoordinate2D!
    var seconPoint: CLLocationCoordinate2D!
    var timer: Timer?
    var labelTimer: Timer?
    var polylineSource: MGLShapeSource?
    var currentIndex = 1
    var allCoordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    var distance: Int?
    var labelCounter:Double = 0.0
    
    override func viewWillAppear(_ animated: Bool) {
        distanceView.isHidden = true
        distanceView.layer.cornerRadius = 20
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCustomNavigationButton()
        
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        // Zoom to bounds
        mapView.setVisibleCoordinateBounds(MGLCoordinateBounds(sw: firstPoint, ne: seconPoint), animated: false)
        
        mapView.zoomLevel -= 1
        
        mapView.delegate = self
        
        let yourTotalCoordinates = Double(40)
        let latitudeDiff = firstPoint.latitude - seconPoint.latitude
        let longitudeDiff = firstPoint.longitude - seconPoint.longitude
        let latMultiplier = latitudeDiff / (yourTotalCoordinates)
        let longMultiplier = longitudeDiff / (yourTotalCoordinates)
        
        for index in 0...Int(yourTotalCoordinates) {
            let lat  = firstPoint.latitude - (latMultiplier * Double(index))
            let long = firstPoint.longitude - (longMultiplier * Double(index))
            let point = CLLocationCoordinate2D(latitude: lat, longitude: long)
            allCoordinates.append(point)
        }
    }
    
    // Wait until the map is loaded before adding to the map.
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        
        
        addPolyline(to: mapView.style!)
        animatePolyline()
        
        let firstMarker: MGLPointAnnotation = {
            let annotation = MGLPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: firstPoint.latitude, longitude: firstPoint.longitude)
            return annotation
        }()
        
        
        mapView.addAnnotation(firstMarker)
        
        let secondMarker: MGLPointAnnotation = {
            let annotation = MGLPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: seconPoint.latitude, longitude: seconPoint.longitude)
            return annotation
        }()
        
        mapView.addAnnotation(secondMarker)
        
        distanceView.isHidden = false
    }
    
    func addPolyline(to style: MGLStyle) {
        // Add an empty MGLShapeSource, we’ll keep a reference to this and add points to this later.
        let source = MGLShapeSource(identifier: "polyline", shape: nil, options: nil)
        style.addSource(source)
        polylineSource = source
        
        // Add a layer to style our polyline.
        let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")
        layer.lineColor = NSExpression(forConstantValue: UIColor.init(named: K.customBlueColor))
        
        // The line width should gradually increase based on the zoom level.
        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                       [15: 5, 18: 5])
        style.addLayer(layer)
    }
    
    func animatePolyline() {
        currentIndex = 1
        // Start a timer that will simulate adding points to our polyline. This could also represent coordinates being added to our polyline from another source, such as a CLLocationManagerDelegate.
        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc func tick() {
        if currentIndex > allCoordinates.count {
            timer?.invalidate()
            timer = nil
            distanceLabel.text = String(format: "%d m", distance!)
            distanceKilometersLabel.text = String(format: "≈%.2f km", Double(distance!)/1000.0)
            return
        }
        
        // Create a subarray of locations up to the current index.
        let coordinates = Array(allCoordinates[0..<currentIndex])
        
        // Update our MGLShapeSource with the current locations.
        updatePolylineWithCoordinates(coordinates: coordinates)
        
        // Update labels with distance values
        distanceLabel.text = String(format: "%.f m", labelCounter)
        distanceKilometersLabel.text = String(format: "≈%.2f km", labelCounter/1000)
        
        labelCounter += Double(distance!/allCoordinates.count)
        currentIndex += 1
    }
    
    func updatePolylineWithCoordinates(coordinates: [CLLocationCoordinate2D]) {
        var mutableCoordinates = coordinates
        
        let polyline = MGLPolylineFeature(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
        
        // Updating the MGLShapeSource’s shape will have the map redraw our polyline with the current coordinates.
        polylineSource?.shape = polyline
    }
}
