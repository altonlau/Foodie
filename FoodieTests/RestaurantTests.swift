import MapKit
import RealmSwift
import XCTest

@testable import Foodie

class RestaurantTests: XCTestCase {
    
    var restaurantList = [Restaurant]()
    let realm = try! Realm()
    
    override func setUp() {
        super.setUp()
        
        try! realm.write({
            realm.deleteAll()
        })
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        let image = UIImage(data: try! Data(contentsOf: URL(string: "https://dummyimage.com/750x1334/D3F6FF/6A7B7F.png&text=Photo")!))
        
        restaurantList.append(Restaurant(name: "Maple Yip's", cuisines: [Cuisine(name: "Chinese")], location: CLLocation(latitude: 13, longitude: 75)))
        restaurantList.append(Restaurant(name: "Joey's", cuisines: [Cuisine(name: "American", type: "Burger"), Cuisine(name: "Italian"), Cuisine(name: "Japanese", type: "Sushi"), Cuisine(name: "Thai", type: "Curry")], location: CLLocation(latitude: 24, longitude: 63)))
        restaurantList.append(Restaurant(name: "Phoenix", cuisines: [Cuisine(name: "Chinese", type: "Hong Kong")], location: CLLocation(latitude: 67, longitude: 235), image: image))
    }
    
    override func tearDown() {
        super.tearDown()
        
        try! realm.write({
            realm.deleteAll()
        })
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        restaurantList.removeAll()
    }
    
    func testInsertRestaurant() {
        let restaurantService = AllServices.services.container.resolve(RestaurantService.self)!
        
        // Test insert new restaurant
        for restaurant in restaurantList {
            XCTAssertTrue(restaurantService.insert(restaurant))
        }
        
        // Test insert already existing restaurant
        for restaurant in restaurantList {
            XCTAssertFalse(restaurantService.insert(restaurant))
        }
    }
    
    func testGetRestaurant() {
        let restaurantService = AllServices.services.container.resolve(RestaurantService.self)!
        var settingsService = AllServices.services.container.resolve(SettingsService.self)!
        var restaurant: Restaurant?
        var restaurants: [Restaurant]?
        
        // Test getting non-existing restaurant
        if let firstRestaurant = restaurantList.first {
            restaurant = restaurantService.get(firstRestaurant)
            XCTAssertNil(restaurant)
            
            restaurant = restaurantService.get(name: firstRestaurant.name, cuisines: firstRestaurant.cuisines, location: firstRestaurant.location, image: firstRestaurant.image)
            XCTAssertNil(restaurant)
            
            restaurants = restaurantService.get(firstRestaurant.name)
            XCTAssertNil(restaurants)
            
            restaurants = restaurantService.getAll()
            XCTAssertNil(restaurants)
            
            restaurant = restaurantService.getRandom()
            XCTAssertNil(restaurant)
        }
        
        for restaurant in restaurantList {
            XCTAssertTrue(restaurantService.insert(restaurant))
        }
        
        // Test getting restaurant
        if let firstRestaurant = restaurantList.first {
            restaurant = restaurantService.get(firstRestaurant)
            XCTAssertNotNil(restaurant)
            XCTAssertEqual(restaurant!, firstRestaurant)
            
            restaurant = restaurantService.get(name: firstRestaurant.name, cuisines: firstRestaurant.cuisines, location: firstRestaurant.location, image: firstRestaurant.image)
            XCTAssertNotNil(restaurant)
            XCTAssertEqual(restaurant!, firstRestaurant)
            
            restaurants = restaurantService.get(firstRestaurant.name)
            XCTAssertNotNil(restaurants)
            XCTAssertEqual(restaurants!.count, 1)
            restaurant = restaurants!.first
            XCTAssertNotNil(restaurant)
            XCTAssertEqual(restaurant!, firstRestaurant)
            
            restaurants = restaurantService.getAll()
            XCTAssertNotNil(restaurants)
            XCTAssertEqual(restaurants!.count, restaurantList.count)
            restaurant = restaurants!.first
            XCTAssertNotNil(restaurant)
            XCTAssertEqual(restaurant!, firstRestaurant)
            
            restaurant = restaurantService.getRandom()
            XCTAssertNotNil(restaurant)
            
            settingsService.cuisineFilter = firstRestaurant.cuisines
            restaurant = restaurantService.getRandom()
            XCTAssertNotNil(restaurant)
            XCTAssertEqual(restaurant, firstRestaurant)
        }
    }
    
    func testRemoveRestaurant() {
        let restaurantService = AllServices.services.container.resolve(RestaurantService.self)!
        var restaurants: [Restaurant]?
        
        // Test remove non-existing restaurant
        if let firstRestaurant = restaurantList.first {
            XCTAssertNil(restaurantService.getAll())
            restaurantService.remove(firstRestaurant)
            XCTAssertNil(restaurantService.getAll())
        }
        
        for restaurant in restaurantList {
            XCTAssertTrue(restaurantService.insert(restaurant))
        }
        
        // Test remove one restaurant
        if let firstRestaurant = restaurantList.first {
            restaurants = restaurantService.getAll()
            XCTAssertNotNil(restaurants)
            XCTAssertEqual(restaurants!.count, restaurantList.count)
            restaurantService.remove(firstRestaurant)
            restaurants = restaurantService.getAll()
            XCTAssertNotNil(restaurants)
            XCTAssertEqual(restaurants!.count, restaurantList.count - 1)
        }
        
        // Test remove the rest of the restaurant
        for i in 1...restaurantList.count - 1 {
            restaurants = restaurantService.getAll()
            XCTAssertNotNil(restaurants)
            XCTAssertEqual(restaurants!.count, restaurantList.count - i)
            restaurantService.remove(restaurantList[i])
        }
        
        restaurants = restaurantService.getAll()
        XCTAssertNil(restaurants)
        
        for restaurant in restaurantList {
            XCTAssertTrue(restaurantService.insert(restaurant))
        }
        
        // Test remove all restaurants
        restaurants = restaurantService.getAll()
        XCTAssertNotNil(restaurants)
        XCTAssertEqual(restaurants!.count, restaurantList.count)
        restaurantService.removeAll()
        restaurants = restaurantService.getAll()
        XCTAssertNil(restaurants)
    }
    
    func testUpdateRestaurant() {
        let restaurantService = AllServices.services.container.resolve(RestaurantService.self)!
        
        // Test update non-existing restaurant
        if let firstRestaurant = restaurantList.first,
            let lastRestaurant = restaurantList.last {
            XCTAssertFalse(restaurantService.update(old: firstRestaurant, new: lastRestaurant))
        }
        
        for restaurant in restaurantList {
            XCTAssertTrue(restaurantService.insert(restaurant))
        }
        
        // Test update existing restaurant with values of another existing restaurant
        if let firstRestaurant = restaurantList.first,
            let lastRestaurant = restaurantList.last {
            XCTAssertFalse(restaurantService.update(old: firstRestaurant, new: lastRestaurant))
        }
        
        // Test update existing restaurant
        let restaurant1 = Restaurant(name: "Kinka", cuisines: [Cuisine(name: "Japanese", type: "Izakaya")], location: CLLocation(latitude: 13, longitude: 75))
        if let firstRestaurant = restaurantList.first {
            XCTAssertNotNil(restaurantService.get(firstRestaurant))
            XCTAssertNil(restaurantService.get(restaurant1))
            XCTAssertTrue(restaurantService.update(old: firstRestaurant, new: restaurant1))
            XCTAssertNil(restaurantService.get(firstRestaurant))
            XCTAssertNotNil(restaurantService.get(restaurant1))
        }
        
        // Test minor update on existing restaurant with an extra cuisine
        let restaurant2 = Restaurant(name: "Kinka", cuisines: [Cuisine(name: "Japanese", type: "Izakaya"), Cuisine(name: "Korean")], location: CLLocation(latitude: 13, longitude: 75))
        XCTAssertNotNil(restaurantService.get(restaurant1))
        XCTAssertNil(restaurantService.get(restaurant2))
        XCTAssertTrue(restaurantService.update(old: restaurant1, new: restaurant2))
        XCTAssertNil(restaurantService.get(restaurant1))
        XCTAssertNotNil(restaurantService.get(restaurant2))
        
        // Test minor update on existing restaurant reducing cuisines
        XCTAssertNotNil(restaurantService.get(restaurant2))
        XCTAssertNil(restaurantService.get(restaurant1))
        XCTAssertTrue(restaurantService.update(old: restaurant2, new: restaurant1))
        XCTAssertNil(restaurantService.get(restaurant2))
        XCTAssertNotNil(restaurantService.get(restaurant1))
        
        // Test minor update on existing restaurant changing locations
        let restaurant3 = Restaurant(name: "Kinka", cuisines: [Cuisine(name: "Japanese", type: "Izakaya")], location: CLLocation(latitude: 80, longitude: 80))
        XCTAssertNotNil(restaurantService.get(restaurant1))
        XCTAssertNil(restaurantService.get(restaurant3))
        XCTAssertTrue(restaurantService.update(old: restaurant1, new: restaurant3))
        XCTAssertNil(restaurantService.get(restaurant1))
        XCTAssertNotNil(restaurantService.get(restaurant3))
        
        // Test minor update on existing restaurant changing back locations
        XCTAssertNotNil(restaurantService.get(restaurant3))
        XCTAssertNil(restaurantService.get(restaurant1))
        XCTAssertTrue(restaurantService.update(old: restaurant3, new: restaurant1))
        XCTAssertNil(restaurantService.get(restaurant3))
        XCTAssertNotNil(restaurantService.get(restaurant1))
        
        // Test minor update on existing restaurant changing image
        let image = UIImage(data: try! Data(contentsOf: URL(string: "https://dummyimage.com/750x1334/D3F6FF/6A7B7F.png&text=Foodie")!))
        
        let restaurant4 = Restaurant(name: "Kinka", cuisines: [Cuisine(name: "Japanese", type: "Izakaya")], location: CLLocation(latitude: 13, longitude: 75), image: image)
        XCTAssertNotNil(restaurantService.get(restaurant1))
        XCTAssertNil(restaurantService.get(restaurant4))
        XCTAssertTrue(restaurantService.update(old: restaurant1, new: restaurant4))
        XCTAssertNil(restaurantService.get(restaurant1))
        XCTAssertNotNil(restaurantService.get(restaurant4))
        
        // Test minor update on existing restaurant removing image
        XCTAssertNotNil(restaurantService.get(restaurant4))
        XCTAssertNil(restaurantService.get(restaurant1))
        XCTAssertTrue(restaurantService.update(old: restaurant4, new: restaurant1))
        XCTAssertNil(restaurantService.get(restaurant4))
        XCTAssertNotNil(restaurantService.get(restaurant1))
    }
    
}
