//
//  SearchService.swift
//  Foodie
//
//  Created by Alton Lau on 2016-08-23.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import Foundation

protocol SearchService {
    
    func search(_ searchText: String) -> [Restaurant]
    func searchCuisine(_ searchText: String) -> [Cuisine]
    func searchRestaurant(_ searchText: String) -> [Restaurant]
    
}

class SearchServiceImplementation: SearchService {
    
    func search(_ searchText: String) -> [Restaurant] {
        let restaurantService = AllServices.services.container.resolve(RestaurantService.self)!
        guard let restaurantList = restaurantService.getAll() else {
            return [Restaurant]()
        }
        
        let filteredList = restaurantList.filter { (restaurant) -> Bool in
            for cuisine in restaurant.cuisines {
                if cuisine.matches(searchText) {
                    return true
                }
            }
            
            return restaurant.matches(searchText)
        }
        
        return filteredList
    }
    
    func searchCuisine(_ searchText: String) -> [Cuisine] {
        let cuisineService = AllServices.services.container.resolve(CuisineService.self)!
        guard let cuisineList = cuisineService.getAll() else {
            return [Cuisine]()
        }
        
        let filteredList = cuisineList.filter { (cuisine) -> Bool in
            return cuisine.matches(searchText)
        }
        
        return filteredList
    }
    
    func searchRestaurant(_ searchText: String) -> [Restaurant] {
        let restaurantService = AllServices.services.container.resolve(RestaurantService.self)!
        guard let restaurantList = restaurantService.getAll() else {
            return [Restaurant]()
        }
        
        let filteredList = restaurantList.filter { (restaurant) -> Bool in
            return restaurant.matches(searchText)
        }
        
        return filteredList
    }
    
}
