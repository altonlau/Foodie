//
//  MainController.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-16.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import CoreLocation
import UIKit

class MainController: UIViewController {
    
    //# MARK: - Constants
    
    private let kAnimateFoodieInterval: TimeInterval = 20
    private let kPanTransitionPercentage: CGFloat = 0.9
    private let kReturnToCenterDuration = 0.5
    private let kTintTag = 1
    private let kTransitionAnimationDuration: TimeInterval = 0.5
    
    private let locationManager = CLLocationManager()
    
    
    //# MARK: - Variables
    
    private var isDragging = false
    private var restaurant: Restaurant?
    private var startPoint: CGPoint = .zero
    private var timer: Timer?
    
    
    //# MARK: - IBOutlets
    
    @IBOutlet weak var foodieButton: UIButton!
    @IBOutlet weak var listFoodiesImageView: UIImageView!
    @IBOutlet weak var settingsFoodieImageView: UIImageView!
    
    
    //# MARK: - IBActions
    
    @IBAction func foodieButtonPressed(_ sender: AnyObject) {
        let restaurantService = AllServices.services.container.resolve(RestaurantService.self)!
        if let location = locationManager.location, CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            restaurant = restaurantService.getRandom(location)
        } else {
            restaurant = restaurantService.getRandom()
        }
        
        if restaurant != .none {
            performSegue(withIdentifier: FoodieSegueIdentifier, sender: self)
        }
    }
    
    @IBAction func foodieButtonDragged(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            startPoint = foodieButton.center
            isDragging = true
        } else if sender.state == .changed {
            var point = sender.translation(in: view)
            let distance = hypot(point.x, point.y)
            let maxDistance = foodieButton.bounds.width / 2
            
            if distance > maxDistance {
                let angle = atan2(point.y, point.x)
                point.x = cos(angle) * maxDistance
                point.y = sin(angle) * maxDistance
            }
            
            foodieButton.imageView?.image = UIImage(named: "foodie-sushi-18")
            foodieButton.center = CGPoint(x: startPoint.x + point.x, y: startPoint.y + point.y)
            
            reloadViews()
        } else if sender.state == .ended {
            UIView.animate(withDuration: kReturnToCenterDuration, animations: {
                if self.listFoodiesImageView.alpha > self.kPanTransitionPercentage {
                    self.performSegue(withIdentifier: AllFoodiesSegueIdentifier, sender: self)
                } else if self.settingsFoodieImageView.alpha > self.kPanTransitionPercentage {
                    self.performSegue(withIdentifier: SettingsSegueIdentifier, sender: self)
                }
                self.foodieButton.center = self.startPoint
                self.listFoodiesImageView.alpha = 0
                self.settingsFoodieImageView.alpha = 0
                }, completion: { (Bool) in
                    self.foodieButton.imageView?.image = UIImage(named: "foodie-sushi-0")
                    self.isDragging = false
            })
        }
    }
    
    @IBAction func unwindFoodieSegue(_ segue: UIStoryboardSegue) {}
    
    
    //# MARK: - Overridden Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == FoodieSegueIdentifier {
            guard let foodieController = segue.destination as? FoodieController else {
                return
            }
            
            foodieController.restaurant = restaurant
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    
    //# MARK: - Public Methods
    
    func animateFoodie() {
        if foodieButton.isEnabled && !isDragging {
            foodieButton.isEnabled = !foodieButton.isEnabled
            if let imageView = foodieButton.imageView {
                imageView.animationImages = {
                    var array = [UIImage]()
                    for i in 0...17 {
                        array.append(UIImage(named: "foodie-sushi-\(i)")!)
                    }
                    return array
                    }()
                imageView.animationRepeatCount = 1
                imageView.startAnimating(delayFrames: [0.0375, 0.0375, 0.07, 0.0375, 0.0375, 0.0375, 0.0375, 0.0375, 0.07, 0.0375, 0.0375, 0.0375, 0.0375, 0.0375, 0.0375, 0.0375, 0.0375, 0], completion: {
                    self.foodieButton.isEnabled = !self.foodieButton.isEnabled
                })
            }
        }
    }
    
    
    //# MARK: - Private Methods
    
    private func setup() {
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: kAnimateFoodieInterval, target: self, selector: #selector(animateFoodie), userInfo: .none, repeats: true)
    }
    
    private func reloadViews() {
        if startPoint != .zero {
            let minListDistance = listFoodiesImageView.center.y - startPoint.y - (foodieButton.bounds.width / 2)
            let maxListDistance = (listFoodiesImageView.center.y - startPoint.y + minListDistance) / 2
            let listDistance = hypot(foodieButton.center.x - listFoodiesImageView.center.x, foodieButton.center.y - listFoodiesImageView.center.y)
            let listPercentDistance = 1 - ((listDistance - minListDistance) / (maxListDistance - minListDistance))
            
            let minSettingsDistance = startPoint.y - settingsFoodieImageView.center.y - (foodieButton.bounds.width / 2)
            let maxSettingsDistance = (startPoint.y - settingsFoodieImageView.center.y + minSettingsDistance) / 2
            let settingsDistance = hypot(settingsFoodieImageView.center.x - foodieButton.center.x, settingsFoodieImageView.center.y - foodieButton.center.y)
            let settingsPercentDistance = 1 - ((settingsDistance - minSettingsDistance) / (maxSettingsDistance - minSettingsDistance))
            
            listFoodiesImageView.alpha = listPercentDistance
            settingsFoodieImageView.alpha = settingsPercentDistance
        }
    }
    
}

