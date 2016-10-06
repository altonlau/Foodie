import RealmSwift
import XCTest

@testable import Foodie

class CuisineTests: XCTestCase {
    
    var cuisineList = [Cuisine]()
    let realm = try! Realm()
    
    override func setUp() {
        super.setUp()
        
        try! realm.write({
            realm.deleteAll()
        })
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        cuisineList.append(Cuisine(name: "Chinese", type: "Szechuan"))
        cuisineList.append(Cuisine(name: "Italian"))
        cuisineList.append(Cuisine(name: "American", type: "Fast Food"))
    }
    
    override func tearDown() {
        super.tearDown()
        
        try! realm.write({
            realm.deleteAll()
        })
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        cuisineList.removeAll()
    }
    
    func testInsertCuisine() {
        let cuisineService = AllServices.services.container.resolve(CuisineService.self)!
        
        // Test insert new cuisine
        for cuisine in cuisineList {
            XCTAssertTrue(cuisineService.insert(cuisine))
        }
        
        // Test insert already existing cuisine
        for cuisine in cuisineList {
            XCTAssertFalse(cuisineService.insert(cuisine))
        }
    }
    
    func testGetCuisine() {
        let cuisineService = AllServices.services.container.resolve(CuisineService.self)!
        var cuisine: Cuisine?
        var cuisines: [Cuisine]?
        
        // Test getting non-existing cuisine
        if let firstCuisine = cuisineList.first {
            cuisine = cuisineService.get(firstCuisine)
            XCTAssertNil(cuisine)
            
            cuisine = cuisineService.get(name: firstCuisine.name, type: firstCuisine.type)
            XCTAssertNil(cuisine)
            
            cuisines = cuisineService.get(firstCuisine.name)
            XCTAssertNil(cuisines)
            
            cuisines = cuisineService.getAll()
            XCTAssertNil(cuisines)
        }
        
        for cuisine in cuisineList {
            XCTAssertTrue(cuisineService.insert(cuisine))
        }
        
        // Test getting cuisine
        if let firstCuisine = cuisineList.first {
            cuisine = cuisineService.get(firstCuisine)
            XCTAssertNotNil(cuisine)
            XCTAssertEqual(cuisine!, firstCuisine)
            
            cuisine = cuisineService.get(name: firstCuisine.name, type: firstCuisine.type)
            XCTAssertNotNil(cuisine)
            XCTAssertEqual(cuisine!, firstCuisine)
            
            cuisines = cuisineService.get(firstCuisine.name)
            XCTAssertNotNil(cuisines)
            XCTAssertEqual(cuisines!.count, 1)
            cuisine = cuisines!.first
            XCTAssertNotNil(cuisine)
            XCTAssertEqual(cuisine!, firstCuisine)
            
            cuisines = cuisineService.getAll()
            XCTAssertNotNil(cuisines)
            XCTAssertEqual(cuisines!.count, cuisineList.count)
            cuisine = cuisines!.first
            XCTAssertNotNil(cuisine)
            XCTAssertEqual(cuisine!, firstCuisine)
        }
    }
    
    func testRemoveCuisine() {
        let cuisineService = AllServices.services.container.resolve(CuisineService.self)!
        var cuisines: [Cuisine]?
        
        // Test remove non-existing cuisine
        if let firstCuisine = cuisineList.first {
            XCTAssertNil(cuisineService.getAll())
            cuisineService.remove(firstCuisine)
            XCTAssertNil(cuisineService.getAll())
        }
        
        for cuisine in cuisineList {
            XCTAssertTrue(cuisineService.insert(cuisine))
        }
        
        // Test remove one cuisine
        if let firstCuisine = cuisineList.first {
            cuisines = cuisineService.getAll()
            XCTAssertNotNil(cuisines)
            XCTAssertEqual(cuisines!.count, cuisineList.count)
            cuisineService.remove(firstCuisine)
            cuisines = cuisineService.getAll()
            XCTAssertNotNil(cuisines)
            XCTAssertEqual(cuisines!.count, cuisineList.count - 1)
        }
        
        // Test remove the rest of the cuisine
        for i in 1...cuisineList.count - 1 {
            cuisines = cuisineService.getAll()
            XCTAssertNotNil(cuisines)
            XCTAssertEqual(cuisines!.count, cuisineList.count - i)
            cuisineService.remove(cuisineList[i])
        }
        
        cuisines = cuisineService.getAll()
        XCTAssertNil(cuisines)
        
        for cuisine in cuisineList {
            XCTAssertTrue(cuisineService.insert(cuisine))
        }
        
        // Test remove all cuisines
        cuisines = cuisineService.getAll()
        XCTAssertNotNil(cuisines)
        XCTAssertEqual(cuisines!.count, cuisineList.count)
        cuisineService.removeAll()
        cuisines = cuisineService.getAll()
        XCTAssertNil(cuisines)
    }
    
    func testUpdateCuisine() {
        let cuisineService = AllServices.services.container.resolve(CuisineService.self)!
        
        // Test update non-existing cuisine
        if let firstCuisine = cuisineList.first,
            let lastCuisine = cuisineList.last {
            XCTAssertFalse(cuisineService.update(old: firstCuisine, new: lastCuisine))
        }
        
        for cuisine in cuisineList {
            XCTAssertTrue(cuisineService.insert(cuisine))
        }
        
        // Test update existing cuisine with values of another existing cuisine
        if let firstCuisine = cuisineList.first,
            let lastCuisine = cuisineList.last {
            XCTAssertFalse(cuisineService.update(old: firstCuisine, new: lastCuisine))
        }
        
        // Test update existing cuisine
        if let firstCuisine = cuisineList.first {
            let newCuisine = Cuisine(name: "Japanese", type: "Ramen")
            
            XCTAssertNotNil(cuisineService.get(firstCuisine))
            XCTAssertNil(cuisineService.get(newCuisine))
            XCTAssertTrue(cuisineService.update(old: firstCuisine, new: newCuisine))
            XCTAssertNil(cuisineService.get(firstCuisine))
            XCTAssertNotNil(cuisineService.get(newCuisine))
        }
    }
    
}
