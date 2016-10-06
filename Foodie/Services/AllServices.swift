//
//  AllServices.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-16.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import Foundation
import Swinject

public class AllServices {
    
    public static let services = AllServices()
    public let container: Container
    
    init() {
        container = Container()
        container.register(CuisineService.self) { _ in CuisineServiceImplementation() }.inObjectScope(.container)
        container.register(LocationService.self) { _ in LocationServiceImplementation() }.inObjectScope(.container)
        container.register(RestaurantService.self) { _ in RestaurantServiceImplementation() }.inObjectScope(.container)
        container.register(SearchService.self) { _ in SearchServiceImplementation() }.inObjectScope(.container)
        container.register(SettingsService.self) { _ in SettingsServiceImplementation() }.inObjectScope(.container)
    }
    
}
