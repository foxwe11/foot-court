//
//  NewPlaceViewController.swift
//  Foot court
//
//  Created by Admin on 05/11/2019.
//  Copyright © 2019 Anton Varenik. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    var newPlace = Place()
    var imageIsChange = false
    
    @IBOutlet weak var safeButton: UIBarButtonItem!
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // сохоанение данных в фоновом потоке
        DispatchQueue.main.async {
            self.newPlace.savePlaces()
        }
        
        
        tableView.tableFooterView = UIView()
        
        safeButton.isEnabled = false
        
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }

    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .alert)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
            
        } else {
            
            view.endEditing(true)
        }
    }
    
    func saveNewPlace() {
        
        var image: UIImage?
        
        if imageIsChange {
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        
//        newPlace = Place(name: placeName.text!,
//                         location: placeLocation.text,
//                         type: placeType.text,
//                         image: image,
//                         restaurantImage: nil)
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
}

// MARK: Text field delegate
   
extension NewPlaceViewController: UITextFieldDelegate {
       // Hide keybourd for tap  on DONE
       
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }
    
    @objc private func textFieldChanged() {
        
        if placeName.text?.isEmpty == false {
            safeButton.isEnabled = true
        } else {
            safeButton.isEnabled = false
        }
        
    }
}

// MARK: Work with image

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true) 
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        imageIsChange = true
        
        dismiss(animated: true)
        
        
        
    }
}
