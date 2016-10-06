//
//  InsertFoodieController.swift
//  Foodie
//
//  Created by Alton Lau on 2016-05-05.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import MapKit
import SVProgressHUD
import UIKit

class InsertFoodieController: UIViewController {
    
    //# MARK: - Constants
    
    private let kTextFieldLeftViewPadding: CGFloat = 15.0
    
    fileprivate let keyboardHandler = KeyboardHandler()
    
    fileprivate let addIcon = "add-icon"
    fileprivate let cameraIcon = "camera-icon"
    fileprivate let searchIcon = "search-icon"
    
    fileprivate let cellIdentifier = "cuisineTableViewCellIdentifier"
    
    fileprivate let cuisineService = AllServices.services.container.resolve(CuisineService.self)!
    fileprivate let locationService = AllServices.services.container.resolve(LocationService.self)!
    fileprivate let restaurantService = AllServices.services.container.resolve(RestaurantService.self)!
    fileprivate let searchService = AllServices.services.container.resolve(SearchService.self)!
    
    
    //# MARK: - Variables
    
    fileprivate var cuisineList = [Cuisine]()
    fileprivate var filteredCuisineList = [Cuisine]()
    fileprivate var selectedCuisineList = [Cuisine]()
    fileprivate var selectedLocation: CLLocation?
    fileprivate var hasImage = false
    
    var restaurant: Restaurant?
    
    
    //# MARK: - IBOutlets
    
    @IBOutlet weak var cuisineTableView: UITableView!
    @IBOutlet weak var cameraButton: CircularImageButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var searchCuisineTextField: UITextField!
    @IBOutlet weak var restaurantNameTextField: UITextField!
    
    
    //# MARK: - IBActions
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cameraButtonPressed(_ sender: AnyObject) {
        let alertController = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
                requestForCameraAccess({ (success) in
                    if success {
                        let imagePickerController = UIImagePickerController()
                        imagePickerController.allowsEditing = false
                        imagePickerController.delegate = self
                        imagePickerController.sourceType = .camera
                        self.present(imagePickerController, animated: true, completion: .none)
                    }
                })
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(UIAlertAction(title: "Choose Photo From Library", style: .default, handler: { (action) in
                requestForPhotoLibraryAccess({ (success) in
                    if success {
                        let imagePickerController = UIImagePickerController()
                        imagePickerController.allowsEditing = true
                        imagePickerController.delegate = self
                        imagePickerController.sourceType = .photoLibrary
                        self.present(imagePickerController, animated: true, completion: .none)
                    }
                })
            }))
        }
        if hasImage {
            alertController.addAction(UIAlertAction(title: "Delete Photo", style: .destructive, handler: { (action) in
                self.setImage(.none)
            }))
        }
        
        let cameraAccess = UIImagePickerController.isSourceTypeAvailable(.camera)
        let photoLibraryAccess = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        if cameraAccess || photoLibraryAccess || hasImage {
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: .none))
            present(alertController, animated: true, completion: .none)
        } else {
            let alertController = UIAlertController(title: "Whoops!", message: "Your device doesn't have a camera or a photo library. Something's wrong with your device.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: .none))
            present(alertController, animated: true, completion: .none)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        guard let name = restaurantNameTextField.text, let location = selectedLocation, !name.isEmpty else {
            let alertController = UIAlertController(title: "Missing Fields", message: "You need to have at least a restaurant name and its location to save this Foodie.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: .none))
            present(alertController, animated: true, completion: .none)
            return
        }
        
        SVProgressHUD.show()
        
        let newRestaurant = Restaurant(name: name, cuisines: Array(selectedCuisineList), location: location, image: hasImage ? cameraButton.imageView?.image : .none)
        var success = false
        
        if let restaurant = restaurant {
            success = restaurantService.update(old: restaurant, new: newRestaurant)
        } else {
            success = restaurantService.insert(newRestaurant)
        }
        
        if success {
            SVProgressHUD.showSuccess(withStatus: "Saved!")
            _ = navigationController?.popViewController(animated: true)
        } else {
            SVProgressHUD.dismiss()
            let alertContoller = UIAlertController(title: "Foodie Already Exists", message: "This Foodie already exists. You must really like this one!", preferredStyle: .alert)
            alertContoller.addAction(UIAlertAction(title: "Yeah!", style: .cancel, handler: .none))
            present(alertContoller, animated: true, completion: .none)
        }
    }
    
    @IBAction func searchCuisineTextFieldChanged(_ sender: UITextField) {
        if let searchText = sender.text, !searchText.isEmpty {
            filteredCuisineList = searchService.searchCuisine(searchText)
        } else {
            filteredCuisineList = cuisineList
        }
        
        cuisineTableView.reloadData()
    }
    
    @IBAction func unwindInsertFoodieSegue(_ segue: UIStoryboardSegue) {}
    
    @IBAction func viewTapped(_ sender: AnyObject) {
        if searchCuisineTextField.isFirstResponder {
            searchCuisineTextField.resignFirstResponder()
        }
        
        if restaurantNameTextField.isFirstResponder {
            restaurantNameTextField.resignFirstResponder()
        }
    }
    
    
    //# MARK: - Overridden Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == InsertLocationSegueIdentifier {
            guard let insertLocationController = segue.destination as? InsertLocationController else {
                return
            }
            
            insertLocationController.restaurantLocation = selectedLocation
            insertLocationController.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCuisineList()
        setupKeyboardHandler()
        setupViews()
    }
    
    
    //# MARK: - Public Methods
    
    func updateView() {
        keyboardHandler.enabled = true
        updateCuisineList()
    }
    
    
    //# MARK: - Fileprivate Methods
    
    fileprivate func setImage(_ image: UIImage?) {
        if let image = image {
            cameraButton.imageView?.contentMode = .scaleAspectFill
            cameraButton.borderStyle = CircularImageButton.ImageBorderStyle.Solid
            cameraButton.setImage(image, for: .normal)
            cameraButton.setImage(UIImage(named: cameraIcon)?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            hasImage = true
        } else {
            cameraButton.imageView?.contentMode = .scaleToFill
            cameraButton.borderStyle = CircularImageButton.ImageBorderStyle.Dashed
            cameraButton.setImage(UIImage(named: cameraIcon)?.withRenderingMode(.alwaysTemplate), for: .normal)
            hasImage = false
        }
    }
    
    fileprivate func setLocation(_ location: CLLocation?) {
        if let location = location {
            locationService.getAddress(fromLocation: location) { (address) in
                self.locationButton.setTitle(address, for: .normal)
                self.selectedLocation = location
            }
        }
    }
    
    
    //# MARK: - Private Methods
    
    private func setupCuisineList() {
        let cuisineService = AllServices.services.container.resolve(CuisineService.self)!
        
        if let cuisines = cuisineService.getAll() {
            cuisineList = cuisines.sorted(by: { (prev, next) -> Bool in
                return prev.name.compare(next.name) == .orderedAscending
            })
            
            filteredCuisineList = cuisineList
        }
        
        if let restaurant = restaurant {
            restaurantNameTextField.text = restaurant.name
            selectedCuisineList = restaurant.cuisines
        }
    }
    
    private func setupKeyboardHandler() {
        keyboardHandler.referenceView = searchCuisineTextField
        keyboardHandler.slideView = view
    }
    
    private func setupViews() {
        setImage(restaurant?.image)
        setLocation(restaurant?.location)
        
        searchCuisineTextField.leftView = UIImageView(image: UIImage(named: searchIcon))
        searchCuisineTextField.leftView?.contentMode = .center
        searchCuisineTextField.leftView?.frame.size.width += kTextFieldLeftViewPadding
        searchCuisineTextField.leftViewMode = .always
    }
    
    private func updateCuisineList() {
        let cuisineService = AllServices.services.container.resolve(CuisineService.self)!
        
        if let cuisines = cuisineService.getAll() {
            cuisineList = cuisines.sorted(by: { (prev, next) -> Bool in
                return prev.name.compare(next.name) == .orderedAscending
            })
            
            filteredCuisineList = cuisineList
        }
        
        cuisineTableView.reloadData()
    }
    
}

extension InsertFoodieController: InsertLocationControllerDelegate {
    
    //# MARK: - InsertFoodieControllerDelegate Methods
    
    func insertLocationController(_ controller: InsertLocationController, didPick location: CLLocation) {
        setLocation(location)
    }
    
}

extension InsertFoodieController: UIImagePickerControllerDelegate {
    
    //# MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            setImage(image)
        }
        picker.dismiss(animated: true, completion: .none)
    }
    
}

extension InsertFoodieController: UINavigationControllerDelegate {
    
    //# MARK: - UINavigationControllerDelegate Methods
    
}

extension InsertFoodieController: UITableViewDataSource {
    
    //# MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if indexPath.row == filteredCuisineList.count {
            cell.accessoryType = .none
            cell.imageView?.image = UIImage(named: addIcon)
            cell.textLabel?.text = "New Cuisine"
            cell.detailTextLabel?.text = .none
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            let cellSelected = selectedCuisineList.contains(filteredCuisineList[indexPath.row])
            cell.accessoryType = cellSelected ? .checkmark : .none
            cell.imageView?.image = .none
            cell.textLabel?.text = filteredCuisineList[indexPath.row].name
            cell.detailTextLabel?.text = filteredCuisineList[indexPath.row].type
            
            if cellSelected {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
        cell.separatorInset = .zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cuisine = filteredCuisineList.remove(at: indexPath.row)
            
            if let index = cuisineList.index(of: cuisine) {
                cuisineList.remove(at: index)
            }
            if let index = selectedCuisineList.index(of: cuisine) {
                selectedCuisineList.remove(at: index)
            }
            cuisineService.remove(cuisine)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCuisineList.count + 1
    }
    
}

extension InsertFoodieController: UITableViewDelegate {
    
    //# MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == filteredCuisineList.count {
            keyboardHandler.enabled = false
            performSegue(withIdentifier: InsertCuisineSegueIdentifier, sender: self)
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            if !selectedCuisineList.contains(filteredCuisineList[indexPath.row]) {
                selectedCuisineList.append(filteredCuisineList[indexPath.row])
            }
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.row != filteredCuisineList.count {
            if let index = selectedCuisineList.index(of: filteredCuisineList[indexPath.row]) {
                selectedCuisineList.remove(at: index)
            }
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}
