//
//  InsertLocationController.swift
//  Foodie
//
//  Created by Alton Lau on 2016-08-27.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import GoogleMaps
import UIKit

@objc protocol InsertLocationControllerDelegate: class {
    func insertLocationController(_ controller: InsertLocationController, didPick location: CLLocation)
}

class InsertLocationController: ModalCardViewController {
    
    //# MARK: - Constants
    
    private let kDefaultMapZoomLevel: Float = 15.0
    private let kErrorAnimationDuration: Double = 0.2
    private let kErrorShowDuration: Double = 2.0
    private let kCouldNotGetAddressError = "Could Not Get Address"
    private let kLocationNotFoundError = "Location Not Found"
    
    private let annotationIdentifier = "restaurantAnnotationIdentifier"
    private let locationManager = CLLocationManager()
    private let locationService = AllServices.services.container.resolve(LocationService.self)!
    
    
    //# MARK: - Variables
    
    var restaurantLocation: CLLocation?
    weak var delegate: InsertLocationControllerDelegate?
    
    
    //# MARK: - IBOutlets
    
    @IBOutlet weak var searchButton: ProcessingButton!
    @IBOutlet weak var errorView: RoundedView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    
    
    //# MARK: - IBActions
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        closeButtonPressed(sender)
        
        if let location = restaurantLocation {
            delegate?.insertLocationController(self, didPick: location)
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: AnyObject) {
        self.searchButton.startAnimating()
        viewTapped(sender)
        
        guard let address = locationTextField.text, !address.isEmpty else {
            searchButton.stopAnimating()
            return
        }
        locationService.getLocation(fromAddress: address) { (location) in
            guard let location = location else {
                self.searchButton.stopAnimating()
                self.showError(withMessage: self.kLocationNotFoundError)
                return
            }
            
            self.restaurantLocation = location
            self.updateMap(location: location, shouldPlaceMarker: true, animated: true)
            self.searchButton.stopAnimating()
        }
    }
    
    @IBAction func viewTapped(_ sender: AnyObject) {
        if locationTextField.isFirstResponder {
            locationTextField.resignFirstResponder()
        }
    }
    
    
    //# MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    //# MARK: - Fileprivate Methods
    
    fileprivate func updateMap(location: CLLocation, shouldPlaceMarker placeMarker: Bool, animated: Bool) {
        searchButton.startAnimating()
        locationService.getAddress(fromLocation: location, completion: { (address) in
            guard let address = address else {
                self.searchButton.stopAnimating()
                self.showError(withMessage: self.kCouldNotGetAddressError)
                return
            }
            
            self.locationTextField.text = address
            self.updateMap(location: location, animated: animated)
            if placeMarker {
                self.updateMapMarker(location: location, animated: animated)
            }
            self.searchButton.stopAnimating()
        })
    }
    
    
    //# MARK: - Private Methods
    
    private func setup() {
        setupLocationManager()
        setupViews()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupViews() {
        if let location = restaurantLocation {
            updateMap(location: location, shouldPlaceMarker: true, animated: false)
        }
        
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    private func showError(withMessage message: String) {
        errorView.isHidden = false
        errorLabel.text = message
        UIView.animate(withDuration: kErrorAnimationDuration, animations: {
            self.errorView.alpha = 1
            }, completion: { (Bool) in
                dispatch_later(self.kErrorShowDuration, block: {
                    UIView.animate(withDuration: self.kErrorAnimationDuration, animations: { 
                        self.errorView.alpha = 0
                        }, completion: { (Bool) in
                            self.errorView.isHidden = true
                    })
                })
        })
    }
    
    private func updateMap(location: CLLocation, animated: Bool) {
        let cameraPosition = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: kDefaultMapZoomLevel)
        if animated {
            mapView.animate(to: cameraPosition)
        } else {
            mapView.camera = cameraPosition
        }
    }
    
    private func updateMapMarker(location: CLLocation, animated: Bool) {
        mapView.clear()
        
        let marker = GMSMarker(position: location.coordinate)
        marker.appearAnimation = animated ? kGMSMarkerAnimationNone : kGMSMarkerAnimationPop
        marker.map = mapView
    }

}

extension InsertLocationController: CLLocationManagerDelegate {
    
    //# MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first, restaurantLocation == .none {
            updateMap(location: location, shouldPlaceMarker: false, animated: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.error(error.localizedDescription)
    }
    
}

extension InsertLocationController: GMSMapViewDelegate {
    
    //# MARK: - GMSMapViewDelegate Methods
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        restaurantLocation = location
        updateMap(location: location, shouldPlaceMarker: true, animated: true)
    }
    
}
