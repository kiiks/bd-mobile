//
//  DetailViewController.swift
//  bd-mobile_project
//
//  Created by Killian DROULEZ on 31/03/2021.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var managedContext: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    var delegate: DetailViewDelegate!
    var selectedIndex: Int!
    var task: Task!
    
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var taskPicture: UIImageView!
    @IBOutlet weak var taskDescriptionTextfield: UITextField!
    @IBOutlet weak var taskNameTexfield: UITextField!
    @IBOutlet weak var taskSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskSwitch.isOn = task.checked
        taskNameTexfield.text = task.title
        taskDescriptionTextfield.text = task.desc
    }
    
    
    @IBAction func onCancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDoneBtn(_ sender: Any) {

        task.title = taskNameTexfield.text
        task.desc = taskDescriptionTextfield.text
        task.checked = taskSwitch.isOn
        let picture = Picture(context: managedContext)
        picture.data = taskPicture.image?.jpegData(compressionQuality: 1)
        print(taskPicture.image?.pngData() as Any)
        
        do {
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        delegate.updateTask(index: selectedIndex, task: task, picture: picture)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onAddImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")

            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("picked picture")
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            taskPicture.image = image
            imagePicker.dismiss(animated: true, completion: nil);
        }
    }
}

protocol DetailViewDelegate {
    func updateTask(index: Int, task: Task, picture: Picture)
}
