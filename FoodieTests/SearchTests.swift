import MapKit
import RealmSwift
import XCTest

@testable import Foodie

class SearchTests: XCTestCase {
    
    var restaurantList = [Restaurant]()
    let realm = try! Realm()
    
    override func setUp() {
        super.setUp()
        
        let restaurantService = AllServices.services.container.resolve(RestaurantService.self)!
        
        try! realm.write({
            realm.deleteAll()
        })
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        restaurantList.append(Restaurant(name: "Maple Yip's", cuisines: [Cuisine(name: "Chinese")], location: CLLocation(latitude: 0, longitude: 0)))
        restaurantList.append(Restaurant(name: "Joey's", cuisines: [Cuisine(name: "American", type: "Burger"), Cuisine(name: "Italian"), Cuisine(name: "Japanese", type: "Sushi"), Cuisine(name: "Thai", type: "Curry")], location: CLLocation(latitude: 0, longitude: 0)))
        restaurantList.append(Restaurant(name: "Phoenix", cuisines: [Cuisine(name: "Chinese", type: "Hong Kong")], location: CLLocation(latitude: 0, longitude: 0)))
        restaurantList.append(Restaurant(name: "Jack Astors", cuisines: [Cuisine(name: "American")], location: CLLocation(latitude: 0, longitude: 0)))
        
        for restaurant in restaurantList {
            _ = restaurantService.insert(restaurant)
        }
    }
    
    override func tearDown() {
        super.tearDown()
        
        try! realm.write({
            realm.deleteAll()
        })
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        restaurantList.removeAll()
    }
    
    func testSearch() {
        let searchService = AllServices.services.container.resolve(SearchService.self)!
        
        // Test searching for non-existent Restaurant or Cuisine
        XCTAssertTrue(searchService.search("altonissuperawesome").isEmpty)
        
        // Test searching general
        XCTAssertEqual(searchService.search("Phoenix").count, 1)
        
        // Test searching for keyword that's in both Restaurant and Cuisine
        XCTAssertEqual(searchService.search("Ja").count, 2)
        
        // Test searching for case insensitive keyword
        XCTAssertEqual(searchService.search("MAPLE").count, 1)
    }
    
    func testSearchCuisine() {
        let searchService = AllServices.services.container.resolve(SearchService.self)!
        
        // Test searching for non-existent Cuisine
        XCTAssertTrue(searchService.searchCuisine("Joey's").isEmpty)
        
        // Test searching for Cuisine Name
        XCTAssertEqual(searchService.searchCuisine("Chinese").count, 2)
        
        // Test searching for Cuisine Type
        XCTAssertEqual(searchService.searchCuisine("Hong").count, 1)
        
        // Test searching for case insensitive keyword
        XCTAssertEqual(searchService.searchCuisine("japanese").count, 1)
    }
    
    func testSearchRestaurant() {
        let searchService = AllServices.services.container.resolve(SearchService.self)!
        
        // Test searching for non-existent Restaurant
        XCTAssertTrue(searchService.searchRestaurant("American").isEmpty)
        
        // Test searching for Restaurant
        XCTAssertEqual(searchService.searchRestaurant("J").count, 2)
        
        // Test searching for case insensitive keyword
        XCTAssertEqual(searchService.searchRestaurant("phoenix").count, 1)
    }
    
}
