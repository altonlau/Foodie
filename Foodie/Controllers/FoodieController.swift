//
//  FoodieController.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-23.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import CoreLocation
import UIKit

class FoodieController: ModalCardViewController {
    
    //# MARK: - Contants
    
    private let kAnimationFastDuration = 0.2
    private let kAnimationSlowDuration = 1.0
    private let kDefaultSearchRadius = 100
    private let kMaximumRating: CGFloat = 5.0
    
    private let locationManager = CLLocationManager()
    private let googleService = AllServices.services.container.resolve(GoogleService.self)!
    private let restaurantService = AllServices.services.container.resolve(RestaurantService.self)!
    
    
    //# MARK: - Variables
    
    private var restaurantDetails: [String : Any]?
    private var timer: Timer?
    
    var restaurant: Restaurant?
    
    
    //# MARK: - IBOutlets
    
    @IBOutlet weak var foodiePageView: FoodiePageView!
    @IBOutlet weak var cuisineLabel: UILabel!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet var travelLabelCollection: [UILabel]!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet var travelImageViewCollection: [UIImageView]!
    @IBOutlet weak var ratingViewWidthConstraint: NSLayoutConstraint!
    
    
    //# MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    
    //# MARK: - Fileprivate Methods
    
    fileprivate func updateLocation() {
        if let location = locationManager.location, let restaurant = restaurant {
            googleService.getTravelTime(from: location, to: restaurant.location, completion: { (result) in
                for (mode, duration) in result {
                    if let label = self.travelLabelCollection.filter({ (label) -> Bool in
                        return label.accessibilityLabel == mode.rawValue
                    }).first {
                        UIView.transition(with: label, duration: self.kAnimationFastDuration, options: .transitionCrossDissolve, animations: {
                            label.text = interval_to_string(duration)
                            }, completion: .none)
                    }
                }
            })
        }
    }
    
    
    //# MARK: - Private Methods
    
    private func setup() {
        guard let restaurant = restaurant else {
            dismiss(animated: true, completion: .none)
            return
        }
        
        setupLocationManager()
        setupRestaurant(restaurant)
        setupViews(restaurant)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupRestaurant(_ restaurant: Restaurant) {
        googleService.searchLocation(name: restaurant.name, location: restaurant.location, radius: kDefaultSearchRadius) { (result) in
            if let result = result {
                self.googleService.getDetails(for: result, completion: { (result) in
                    if let result = result?["result"] as? [String : Any] {
                        self.restaurantDetails = result
                        self.reloadViews()
                    }
                })
            }
        }
    }
    
    private func setupViews(_ restaurant: Restaurant) {
        if let image = restaurant.image {
            foodiePageView.image = image
        }
        foodiePageView.location = restaurant.location
        cuisineLabel.text = {
            var array = [String]()
            for cuisine in restaurant.cuisines {
                array.append(cuisine.name + (cuisine.type.isEmpty ? "" : " (" + cuisine.type + ")"))
            }
            return array.joined(separator: ", ")
            }()
        restaurantLabel.text = restaurant.name
        ratingImageView.image = ratingImageView.image?.withRenderingMode(.alwaysTemplate)
        for travelImageView in travelImageViewCollection {
            travelImageView.image = travelImageView.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    private func reloadViews() {
        guard let restaurantDetails = restaurantDetails else {
            foodiePageView.image = .none
            ratingView.backgroundColor = UIColor.white
            ratingViewWidthConstraint.constant = 0
            return
        }
        
        if let rating = restaurantDetails["rating"] as? CGFloat {
            ratingView.backgroundColor = UIColor.foodieGray
            ratingViewWidthConstraint.constant = ratingImageView.bounds.width * rating / self.kMaximumRating
            UIView.animate(withDuration: self.kAnimationSlowDuration) {
                self.view.layoutIfNeeded()
            }
        } else {
            ratingView.backgroundColor = UIColor.white
            ratingViewWidthConstraint.constant = ratingImageView.bounds.width
        }
        
        if let periods = (restaurantDetails["opening_hours"] as? [String : Any])?["periods"] as? [[String : Any]] {
            var hours = [Hours]()
            for period in periods {
                if let day = (period["open"] as? [String : Any])?["day"] as? Int, let open = (period["open"] as? [String : Any])?["time"] as? String, let close = (period["close"] as? [String : Any])?["time"] as? String, let weekday = Hours.Weekday(rawValue: day) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HHmm"
                    if let from = dateFormatter.date(from: open), let to = dateFormatter.date(from: close) {
                        hours.append(Hours(from: from, to: to, weekday: weekday))
                    }
                }
            }
            foodiePageView.hoursView.hours = hours
        }
        
        if restaurant?.image == .none {
            googleService.getPhoto(for: restaurantDetails, size: foodiePageView.bounds.size, completion: { (result) in
                self.foodiePageView.image = result
                
                // Save new downloaded image for next time
                if let restaurant = self.restaurant {
                    let newRestaurant = Restaurant(name: restaurant.name, cuisines: restaurant.cuisines, location: restaurant.location, image: result)
                    _ = self.restaurantService.update(old: restaurant, new: newRestaurant)
                }
            })
        }
    }
    
}

extension FoodieController: CLLocationManagerDelegate {
    
    //# MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        for imageView in travelImageViewCollection {
            imageView.isHidden = status == .denied || status == .notDetermined
        }
        for label in travelLabelCollection {
            label.isHidden = status == .denied || status == .notDetermined
        }
        if status == .authorizedWhenInUse {
            updateLocation()
        }
    }
    
}
