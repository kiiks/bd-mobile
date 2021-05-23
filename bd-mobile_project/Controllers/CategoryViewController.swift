//
//  ViewController.swift
//  bd-mobile_project
//
//  Created by Killian DROULEZ on 24/02/2021.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    private var categories: [Category] = []
    
    private var managedContext: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = fetchCategories()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "openTasks") {
            let destination = segue.destination as! TasksViewController
            let selectedIndex = tableView.indexPath(for: sender as! UITableViewCell)
            destination.currentCategory = categories[selectedIndex!.row]
        }
    }
    
    @IBAction func onAddBtn(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Nouvelle catégorie de tâches",
                                                message: "Ajouter une catégorie à la liste",
                                                preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "Description…"
        }

        let cancelButton = UIAlertAction(title: "Annuler",
                                         style: .cancel,
                                         handler: nil)
        let saveButton = UIAlertAction(title: "Ajouter",
                                       style: .default) { _ in
            guard let textField = alertController.textFields?.first else {
                return
            }

            self.createCategory(title: textField.text!)
            self.categories = self.fetchCategories()
            self.tableView.reloadData()
        }

        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)

        present(alertController, animated: true)
    }
    
    private func createCategory(title: String, date: Date = Date()) {
        let item = Category(context: managedContext)
        item.name = title
        item.dateCreation = date
        item.dateMAJ = date

        saveContext()
    }
    
    private func fetchCategories(searchQuery: String? = nil) -> [Category] {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()

        let dateSortDescriptor = NSSortDescriptor(keyPath: \Category.dateCreation, ascending: false)
        let titleSortDescriptor = NSSortDescriptor(keyPath: \Category.name, ascending: true)

        fetchRequest.sortDescriptors = [dateSortDescriptor, titleSortDescriptor]

        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            let predicate = NSPredicate(format: "%K contains[cd] %@",
                                        argumentArray: [#keyPath(Category.name), searchQuery])
            fetchRequest.predicate = predicate
        }

        do {
            return try self.managedContext.fetch(fetchRequest)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
}

// MARK: - Table View
extension CategoryViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        
        let formater = DateFormatter()
        formater.dateStyle = .short
        cell.detailTextLabel?.text = formater.string(from: categories[indexPath.row].dateCreation!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }

        let index = indexPath.row
        let item = categories[index]

        managedContext.delete(item)
        saveContext()

        categories.remove(at: index)

        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let detailAction = UIContextualAction(style: .normal, title: "Detail", handler: {
            (ac: UIContextualAction, view: UIView, success:(Bool) -> Void) in
            let alertController = UIAlertController(title: "Modification de catégorie de tâches",
                                                    message: "Modifier la catégorie à la liste",
                                                    preferredStyle: .alert)

            alertController.addTextField { (textField) in
                textField.placeholder = self.categories[indexPath.row].name
            }

            let cancelButton = UIAlertAction(title: "Annuler",
                                             style: .cancel,
                                             handler: nil)
            let saveButton = UIAlertAction(title: "Modifier",
                                           style: .default) { _ in
                guard let textField = alertController.textFields?.first else {
                    return
                }

                self.categories[indexPath.row].name = textField.text!
                self.saveContext()
                self.tableView.reloadData()
            }

            alertController.addAction(saveButton)
            alertController.addAction(cancelButton)

            self.present(alertController, animated: true)
        })
        
        detailAction.image = UIImage(systemName: "pencil.circle")
        detailAction.backgroundColor = UIColor.systemBlue

        return UISwipeActionsConfiguration(actions: [detailAction])
    }
    
}

