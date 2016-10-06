//
//  FoodiePageView.swift
//  Foodie
//
//  Created by Alton Lau on 2016-08-26.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import GoogleMaps
import UIKit

class FoodiePageView: UIView {
    
    //# MARK: - Constants
    
    private let kDefaultMapZoomLevel: Float = 15.0
    
    private let pictureIcon = "picture-icon"
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private let imageView = UIImageView()
    private let locationManager = CLLocationManager()
    private let mapView = GMSMapView()
    private let scrollView = UIScrollView()
    
    fileprivate let pageControl = UIPageControl()
    
    let hoursView = HoursView()
    
    
    //# MARK: - Variables
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            activityIndicator.stopAnimating()
            if let image = newValue {
                imageView.contentMode = .scaleAspectFill
                imageView.image = image
            } else {
                imageView.contentMode = .center
                imageView.image = UIImage(named: pictureIcon)?.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    var location: CLLocation = CLLocation() {
        didSet {
            mapView.clear()
            
            let marker = GMSMarker(position: location.coordinate)
            marker.map = mapView
            mapView.camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: kDefaultMapZoomLevel)
        }
    }
    
    
    //# MARK: - Overridden Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    
    //# MARK: - Private Methods
    
    private func setup() {
        setupLocationManager()
        setupViews()
    }
    
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupViews() {
        let contentViews = [imageView, mapView, hoursView]
        for i in 0..<contentViews.count {
            let rect = CGRect(x: CGFloat(i) * frame.size.width, y: frame.minY, width: frame.size.width, height: frame.size.height)
            contentViews[i].frame = rect
            scrollView.addSubview(contentViews[i])
        }
        
        activityIndicator.center = imageView.center
        activityIndicator.startAnimating()
        
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = UIColor.foodieGray
        imageView.addSubview(activityIndicator)
        
        mapView.isMyLocationEnabled = true
        mapView.isUserInteractionEnabled = false
        mapView.settings.scrollGestures = false
        mapView.settings.zoomGestures = false
        
        hoursView.startTick()
        
        scrollView.contentSize = CGSize(width: CGFloat(contentViews.count) * frame.size.width, height: frame.height)
        scrollView.delegate = self
        scrollView.frame = frame
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPage = 1
        pageControl.currentPageIndicatorTintColor = UIColor.foodie
        pageControl.numberOfPages = contentViews.count
        pageControl.pageIndicatorTintColor = UIColor.foodieGray
        pageControl.isUserInteractionEnabled = false
        addSubview(pageControl)
        
        addConstraints([
            NSLayoutConstraint(item: pageControl, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: pageControl, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: pageControl, attribute: .bottom, multiplier: 1, constant: 0)
            ])
    }
    
}

extension FoodiePageView: UIScrollViewDelegate {
    
    //# MARK: - UIScrollViewDelegate Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width))
        pageControl.currentPage = currentPage
    }
    
}
