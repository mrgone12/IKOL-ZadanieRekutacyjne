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
import SnapKit

class ResultViewController: UIViewController, MKMapViewDelegate {
    
    let mapView: MKMapView = MKMapView()
    
    let distanceView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = UIColor(named: Constans.Colors.customBlueColor)
        return view
    }()
    
    let distanceHeaderLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "Distance:"
        label.textColor = .white
        label.font = UIFont(name: Constans.Fonts.poppinsBold, size: 17)
        return label
    }()
    
    let distanceInMetersLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "Meters"
        label.textColor = .white
        label.font = UIFont(name: Constans.Fonts.poppinsBold, size: 30)
        label.textAlignment = .center
        return label
    }()
    
    let distanceInKMLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "Kilometers"
        label.textColor = .white
        label.font = UIFont(name: Constans.Fonts.poppinsRegular, size: 20)
        label.textAlignment = .right
        return label
    }()
    
    let distanceStackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    var firstPoint: CLLocationCoordinate2D!
    var seconPoint: CLLocationCoordinate2D!
    var timer: Timer?
    //    var polylineSource: MGLShapeSource?
    var currentIndex = 1
    var allCoordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    var distance: Int!
    var labelCounter: Double = 0.0
    
    private var labelTimer: Timer?
    private var drawingTimer: Timer?
    private var polyline: MKPolyline = MKPolyline()
    
    var firstPin: AnnotationPin!
    var secondPin: AnnotationPin!
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCustomNavigationButton()
        
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
        setupViews()
        
        setupMap()
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    // Wait until the map is loaded before adding to the map.
    
    func setupMap() {
        
        firstPin = AnnotationPin(title: "FirstPoint", subtitle: "", coordinate: firstPoint)
        
        mapView.addAnnotation(firstPin)
        
        let secondMarker: MKPointAnnotation = {
            let annotation = MKPointAnnotation()
            annotation.coordinate = seconPoint
            return annotation
        }()
        
        mapView.addAnnotation(secondMarker)
        
        animatePolyline(route: allCoordinates, duration: 2, completion: nil)
        animateDistance(distance: distance, duration: 2, completion: nil)
        fitAllMarkers(shouldIncludeCurrentLocation: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(named: Constans.Colors.customBlueColor)
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: firstPin, reuseIdentifier: "firstPin")
        annotationView.image = UIImage(named: Constans.Images.pinImage)
        let transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        annotationView.transform = transform
        return annotationView
    }
    
    private func animateDistance(distance: Int, duration: TimeInterval, completion: (() -> Void)?) {
        var step: Int = 1
        
        let interval: Double = 0.01
        let numberOfSteps: Int =  Int(duration / interval)
        
        labelTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
            if step > numberOfSteps {
                self.labelTimer?.invalidate()
                self.labelTimer = nil
                self.distanceInMetersLabel.text = String(format: "%d m", distance)
                self.distanceInKMLabel.text = String(format: "≈%.2f km", Double(distance)/1000.0)
                return
            }
            
            // Update labels with distance values
            
            let currentValueInMeters = (Double(step) * interval/duration) * Double(distance)
            self.distanceInMetersLabel.text = String(format: "%.f m", currentValueInMeters)
            self.distanceInKMLabel.text = String(format: "≈%.2f km", currentValueInMeters / 1000)
            step += 1
        })
        
    }
    
    private func animatePolyline(route: [CLLocationCoordinate2D], duration: TimeInterval, completion: (() -> Void)?) {
        guard route.count > 0 else { return }
        var currentStep = 1
        let totalSteps = route.count
        let stepDrawDuration = duration/TimeInterval(totalSteps)
        var previousSegment: MKPolyline?
        
        drawingTimer = Timer.scheduledTimer(withTimeInterval: stepDrawDuration, repeats: true) { [weak self] timer in
            guard let self = self else {
                // Invalidate animation if we can't retain self
                timer.invalidate()
                completion?()
                return
            }
            
            if let previous = previousSegment {
                // Remove last drawn segment if needed.
                self.mapView.removeOverlay(previous)
                previousSegment = nil
            }
            
            guard currentStep < totalSteps else {
                // If this is the last animation step...
                let finalPolyline = MKPolyline(coordinates: route, count: route.count)
                self.mapView.addOverlay(finalPolyline)
                // Assign the final polyline instance to the class property.
                self.polyline = finalPolyline
                timer.invalidate()
                completion?()
                return
            }
            
            // Animation step.
            // The current segment to draw consists of a coordinate array from 0 to the 'currentStep' taken from the route.
            let subCoordinates = Array(route.prefix(upTo: currentStep))
            let currentSegment = MKPolyline(coordinates: subCoordinates, count: subCoordinates.count)
            self.mapView.addOverlay(currentSegment)
            
            previousSegment = currentSegment
            currentStep += 1
        }
    }
    
    //    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
    //
    //        addPolyline(to: mapView.style!)
    //        animatePolyline()
    //
    //        let firstMarker: MGLPointAnnotation = {
    //            let annotation = MGLPointAnnotation()
    //            annotation.coordinate = CLLocationCoordinate2D(latitude: firstPoint.latitude, longitude: firstPoint.longitude)
    //            return annotation
    //        }()
    //
    //
    //        mapView.addAnnotation(firstMarker)
    //
    //        let secondMarker: MGLPointAnnotation = {
    //            let annotation = MGLPointAnnotation()
    //            annotation.coordinate = CLLocationCoordinate2D(latitude: seconPoint.latitude, longitude: seconPoint.longitude)
    //            return annotation
    //        }()
    //
    //        mapView.addAnnotation(secondMarker)
    //
    //        distanceView.isHidden = false
    //    }
    
    //    func addPolyline(to style: MGLStyle) {
    //        // Add an empty MGLShapeSource, we’ll keep a reference to this and add points to this later.
    //        let source = MGLShapeSource(identifier: "polyline", shape: nil, options: nil)
    //        style.addSource(source)
    //        polylineSource = source
    //
    //        // Add a layer to style our polyline.
    //        let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
    //        layer.lineJoin = NSExpression(forConstantValue: "round")
    //        layer.lineCap = NSExpression(forConstantValue: "round")
    //        layer.lineColor = NSExpression(forConstantValue: UIColor.init(named: K.customBlueColor))
    //
    //        // The line width should gradually increase based on the zoom level.
    //        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
    //                                       [15: 5, 18: 5])
    //        style.addLayer(layer)
    //    }
    //
    //    func animatePolyline() {
    //        currentIndex = 1
    //        // Start a timer that will simulate adding points to our polyline. This could also represent coordinates being added to our polyline from another source, such as a CLLocationManagerDelegate.
    //        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    //    }
    //
    //    @objc func tick() {
    //        if currentIndex > allCoordinates.count {
    //            timer?.invalidate()
    //            timer = nil
    //            distanceInMetersLabel.text = String(format: "%d m", distance!)
    //            distanceInKMLabel.text = String(format: "≈%.2f km", Double(distance!)/1000.0)
    //            return
    //        }
    //
    //        // Create a subarray of locations up to the current index.
    //        let coordinates = Array(allCoordinates[0..<currentIndex])
    //
    //        // Update our MGLShapeSource with the current locations.
    //        updatePolylineWithCoordinates(coordinates: coordinates)
    //
    //        // Update labels with distance values
    //        distanceInMetersLabel.text = String(format: "%.f m", labelCounter)
    //        distanceInKMLabel.text = String(format: "≈%.2f km", labelCounter/1000)
    //
    //        labelCounter += Double(distance!/allCoordinates.count)
    //        currentIndex += 1
    //    }
    //
    //    func updatePolylineWithCoordinates(coordinates: [CLLocationCoordinate2D]) {
    //        var mutableCoordinates = coordinates
    //
    //        let polyline = MKPOl
    //
    //        let polyline = MGLPolylineFeature(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
    //
    //        // Updating the MGLShapeSource’s shape will have the map redraw our polyline with the current coordinates.
    //        polylineSource?.shape = polyline
    //    }
    
    func setupViews() {
        self.view.addSubview(mapView)
        
        self.view.addSubview(distanceView)
        
        distanceView.snp.makeConstraints { (make) in
             
            make.left.bottom.right.equalToSuperview()
//            make.height.equalTo(self.view.snp.height).dividedBy(7)
            make.height.equalTo(self.view.snp.height).dividedBy(7)
        }
        
        self.distanceView.addSubview(distanceStackView)
        
        distanceStackView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(10)
            make.right.bottom.equalToSuperview().offset(-10)
        }
        
        distanceStackView.addArrangedSubview(distanceHeaderLabel)
        distanceStackView.addArrangedSubview(distanceInMetersLabel)
        distanceStackView.addArrangedSubview(distanceInKMLabel)
        
        mapView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(distanceView.snp.top)
        }
    }
    
    func fitAllMarkers(shouldIncludeCurrentLocation: Bool) {
            if !shouldIncludeCurrentLocation {
                self.mapView.showAnnotations(mapView.annotations, animated: true)
            } else {
                var zoomRect = MKMapRect.null
                
                for annotation in mapView.annotations {
                    
                    let annotationPoint = MKMapPoint(annotation.coordinate)
                    let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
                    
                    if zoomRect.isNull {
                        zoomRect = pointRect
                    } else {
                        zoomRect = zoomRect.union(pointRect)
                    }
                }
                mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 40, left: 30, bottom: 150, right: 30), animated: true)
            }
        }
}
