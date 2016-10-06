//
//  AllFoodiesController.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-21.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

class AllFoodiesController: UITableViewController {
    
    //# MARK: - Constants
    
    private let tableViewCellIdentifier = "foodieItemTableViewCellIdentifier"
    private let restaurantService = AllServices.services.container.resolve(RestaurantService.self)!
    
    
    //# MARK: - Variables
    
    var restaurantList = [Restaurant]()
    
    
    //# MARK: - IBActions
    
    @IBAction func editButtonPressed(_ sender: AnyObject) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    
    //# MARK: - UITableViewDataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath)
        let restaurant = restaurantList[indexPath.row]
        cell.textLabel?.text = restaurant.name
        cell.detailTextLabel?.text = {
            var array = [String]()
            for cuisine in restaurant.cuisines {
                array.append(cuisine.name + (cuisine.type.isEmpty ? "" : " (" + cuisine.type + ")"))
            }
            return array.joined(separator: ", ")
            }()
        cell.imageView?.image = restaurant.image
        
        return cell
    }
    
    
    //# MARK: - UITableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let restaurant = restaurantList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            restaurantService.remove(restaurant)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: InsertFoodieSegueIdentifier, sender: self)
    }
    
    
    //# MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateRestaurants()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == InsertFoodieSegueIdentifier {
            guard let insertFoodieController = segue.destination as? InsertFoodieController, let selectedIndex = tableView.indexPathForSelectedRow?.row else {
                return
            }
            
            insertFoodieController.restaurant = restaurantList[selectedIndex]
        }
    }
    
    
    //# MARK: - Private Methods
    
    private func setupViews() {
        navigationController?.navigationBar.barTintColor = UIColor.foodieBackground
        (view as? UITableView)?.tableFooterView = UIView(frame: .zero)
    }
    
    private func updateRestaurants() {
        restaurantList = restaurantService.getAll()?.sorted(by: { (prev, next) -> Bool in
            return prev.name.compare(next.name) == .orderedAscending
        }) ?? [Restaurant]()
        tableView.reloadData()
    }
    
}
