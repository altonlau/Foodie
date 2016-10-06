//
//  SettingsController.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-24.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {
    
    //# MARK: - Properties
    
    enum Setting {
        case Cuisine, Distance
    }
    
    
    //# MARK: - Constants
    
    fileprivate let kNumberOfVisibleRows = 4
    
    fileprivate let cellIdentifier = "cuisineTableViewCellIdentifier"
    
    
    //# MARK: - Variables
    
    var distance = DistanceSetting.any
    var settingType = Setting.Distance
    
    fileprivate var cuisineList = [Cuisine]()
    fileprivate var selectedCuisineList = [Cuisine]()
    
    
    //# MARK: - IBOutlets
    
    @IBOutlet weak var cuisineView: UIView!
    @IBOutlet weak var distanceView: UIView!
    
    
    //# MARK: - IBActions
    
    @IBAction func distanceButtonPressed(_ sender: RoundedButton) {
        if let settingsController = storyboard?.instantiateViewController(withIdentifier: SettingsControllerIdentifier) as? SettingsController {
            settingsController.distance = DistanceSetting(rawValue: sender.tag) ?? .any
            settingsController.settingType = .Cuisine
            
            navigationController?.pushViewController(settingsController, animated: true)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        var settingsService = AllServices.services.container.resolve(SettingsService.self)!
        settingsService.cuisineFilter = selectedCuisineList
        settingsService.distanceFilter = distance
        
        navigationController?.dismiss(animated: true, completion: .none)
    }
    
    
    //# MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCuisineList()
        setupViews()
    }
    
    
    //# MARK: - Private Methods
    
    private func setupCuisineList() {
        if settingType == Setting.Cuisine {
            let cuisineService = AllServices.services.container.resolve(CuisineService.self)!
            let settingsService = AllServices.services.container.resolve(SettingsService.self)!
            
            if let cuisines = cuisineService.getAll() {
                cuisineList = cuisines.sorted(by: { (prev, next) -> Bool in
                    return prev.name.compare(next.name) == .orderedAscending
                })
            }
            selectedCuisineList = settingsService.cuisineFilter
        }
    }
    
    private func setupViews() {
        navigationController?.navigationBar.barTintColor = UIColor.foodieBackground
        
        switch settingType {
        case .Cuisine:
            navigationItem.title = "What Are You Feeling?"
            cuisineView.isHidden = false
            distanceView.isHidden = true
        default:
            navigationItem.rightBarButtonItem = .none
            navigationItem.title = "How Far Do You Want to Go?"
            cuisineView.isHidden = true
            distanceView.isHidden = false
        }
    }
    
}

extension SettingsController: UITableViewDataSource {
    
    //# MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as! CuisineSettingTableViewCell
        
        if indexPath.row == 0 && (selectedCuisineList.isEmpty || selectedCuisineList.count == cuisineList.count) {
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        } else if indexPath.row > 0 && selectedCuisineList.contains(cuisineList[indexPath.row - 1]) {
            tableView.selectRow(at: indexPath as IndexPath, animated: false, scrollPosition: .none)
        }
        cell.name = indexPath.row == 0 ? "Any" : cuisineList[indexPath.row - 1].name
        cell.type = indexPath.row == 0 ? "" : cuisineList[indexPath.row - 1].type
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cuisineList.count + 1
    }
    
}

extension SettingsController: UITableViewDelegate {
    
    //# MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cuisineView.bounds.height / CGFloat(kNumberOfVisibleRows)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
            selectedCuisineList.append(cuisineList[indexPath.row - 1])
        }
        
        if indexPath.row == 0 || selectedCuisineList.count == cuisineList.count {
            for i in 1..<tableView.numberOfRows(inSection: 0) {
                let indexPath = IndexPath(row: i, section: 0)
                tableView.deselectRow(at: indexPath, animated: true)
                self.tableView(tableView, didDeselectRowAt: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            if let index = selectedCuisineList.index(of: cuisineList[indexPath.row - 1]) {
                selectedCuisineList.remove(at: index)
            }
        }
        
        if selectedCuisineList.isEmpty {
            let animated = indexPath.row != 0
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: animated, scrollPosition: .top)
        }
    }
    
}
