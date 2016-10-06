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
    private let kUpdateLocationInterval: TimeInterval = 20.0
    
    private let locationManager = CLLocationManager()
    private let restaurantService = AllServices.services.container.resolve(RestaurantService.self)!
    
    
    //# MARK: - Variables
    
    private var restaurantDetails: Dictionary<String, AnyObject>?
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
        foodiePageView.hoursView.stopTick()
        locationManager.stopUpdatingLocation()
        stopUpdateLocationTimer()
    }
    
    
    //# MARK: - Public Methods
    
    func updateLocation() {
        if let location = locationManager.location, let restaurant = restaurant {
//            get_travel_time(from: location, to: restaurant.location, callback: { (result) in
//                for (mode, duration) in result {
//                    if let label = self.travelLabelCollection.filter({ (label) -> Bool in
//                        return label.accessibilityLabel == mode.rawValue
//                    }).first {
//                        UIView.transitionWithView(label, duration: self.kAnimationFastDuration, options: .TransitionCrossDissolve, animations: {
//                            label.text = interval_to_string(duration)
//                            }, completion: .None)
//                    }
//                }
//            })
        }
    }
    
    
    //# MARK: - Fileprivate Methods
    
    fileprivate func startUpdateLocationTimer() {
        timer = Timer.scheduledTimer(timeInterval: kUpdateLocationInterval, target: self, selector: #selector(updateLocation), userInfo: .none, repeats: true)
        updateLocation()
    }
    
    fileprivate func stopUpdateLocationTimer() {
        timer?.invalidate()
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
//        search_location(restaurant.name, location: restaurant.location, radius: kDefaultSearchRadius, callback: { (result) in
//            if let result = result {
//                get_details(result, callback: { (result) in
//                    if let result = result?["result"] as? Dictionary<String, AnyObject> {
//                        self.restaurantDetails = result
//                        self.reloadViews()
//                        return
//                    } else {
//                      self.reloadViews()
//                    }
//                })
//            } else {
//                self.reloadViews()
//            }
//        })
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
            ratingViewWidthConstraint.constant = ratingImageView.bounds.width
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
        
        if let periods = restaurantDetails["opening_hours"]?["periods"] as? [Dictionary<String, AnyObject>] {
            var hours = [Hours]()
            for period in periods {
                if let day = period["open"]?["day"] as? Int, let open = period["open"]?["time"] as? String, let close = period["close"]?["time"] as? String, let weekday = Hours.Weekday(rawValue: day) {
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
//            get_photo(restaurantDetails, size: foodiePageView.bounds.size, callback: { (result) in
//                self.foodiePageView.image = result
//                
//                // Save new downloaded image for next time
//                if let restaurant = self.restaurant {
//                    let newRestaurant = Restaurant(name: restaurant.name, cuisines: restaurant.cuisines, location: restaurant.location, image: result)
//                    self.restaurantService.update(restaurant, new: newRestaurant)
//                }
//            })
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
            startUpdateLocationTimer()
        }
    }
    
}