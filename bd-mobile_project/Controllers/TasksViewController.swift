//
//  TableViewController.swift
//  bd-mobile_project
//
//  Created by Killian DROULEZ on 23/03/2021.
//

import UIKit
import CoreData

class TasksViewController: UITableViewController {

    var tasks: [Task] = []
    var currentCategory: Category!
    
    private var managedContext: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = currentCategory.name
        tasks = fetchTasks()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "openDetail") {
            let destination = segue.destination as! DetailViewController
            let selectedIndex = tableView.indexPath(for: sender as! UITableViewCell)
            destination.delegate = self
            destination.selectedIndex = selectedIndex?.row
            destination.task = tasks[selectedIndex!.row]
        }
    }
    
    @IBAction func onAddBtn(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Nouvelle tâches",
                                                message: "Ajouter une tâche à la liste",
                                                preferredStyle: .alert)

        alertController.addTextField { (textFieldTitle) in
            textFieldTitle.placeholder = "Title"
        }
        alertController.addTextField { (textFieldDesc) in
            textFieldDesc.placeholder = "Description"
        }

        let cancelButton = UIAlertAction(title: "Annuler",
                                         style: .cancel,
                                         handler: nil)
        let saveButton = UIAlertAction(title: "Ajouter",
                                       style: .default) { _ in
            guard let textFieldTitle = alertController.textFields?.first else {
                return
            }
            guard let textFieldDesc = alertController.textFields?[1] else {
                return
            }

            self.createTask(title: textFieldTitle.text!, description: textFieldDesc.text!)
            self.tasks = self.fetchTasks()
            self.tableView.reloadData()
        }

        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)

        present(alertController, animated: true)
    }
    
    
    private func fetchTasks(searchQuery: String? = nil) -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

        let descSortDescriptor = NSSortDescriptor(keyPath: \Task.desc, ascending: false)
        let titleSortDescriptor = NSSortDescriptor(keyPath: \Task.title, ascending: true)

        fetchRequest.sortDescriptors = [descSortDescriptor, titleSortDescriptor]

        let predicate = NSPredicate(format: "category == %@",
                                    currentCategory)
        fetchRequest.predicate = predicate


        do {
            return try self.managedContext.fetch(fetchRequest)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func createTask(title: String, description: String = "No description", date: Date = Date()) {
        let item = Task(context: managedContext)
        item.title = title
        item.desc = description
        item.dateCreation = date
        item.dateMAJ = date
        item.checked = false
        item.category = currentCategory
        item.picture = Picture(context: managedContext)
        
        saveContext()
    }

    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
}

// MARK: - Table view
extension TasksViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath)
        
        cell.textLabel?.text = tasks[indexPath.row].title
        cell.detailTextLabel?.text = tasks[indexPath.row].desc
        cell.accessoryType = tasks[indexPath.row].checked ? .checkmark : .none
        cell.imageView?.image = UIImage(data: tasks[indexPath.row].picture?.data ?? Data())
        
        return cell
    }
    
    // Toggle checkmark on click
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tasks[indexPath.row].checked.toggle()
        saveContext()

        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        cell.accessoryType = tasks[indexPath.row].checked ? .checkmark : .none
    }
    
    // Swipe actions
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let detailAction = UIContextualAction(style: .normal, title: "Detail", handler: {
            (ac: UIContextualAction, view: UIView, success:(Bool) -> Void) in
            self.performSegue(withIdentifier: "openDetail", sender: tableView.cellForRow(at:indexPath) )
            success(true)
        })
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {
            (ac: UIContextualAction, view: UIView, success:(Bool) -> Void) in
            let index = indexPath.row
            let item = self.tasks[index]

            self.managedContext.delete(item)
            self.saveContext()

            self.tasks.remove(at: index)

            tableView.deleteRows(at: [indexPath], with: .automatic)
            success(true)
        })
        
        detailAction.image = UIImage(systemName: "info.circle")
        detailAction.backgroundColor = UIColor.systemBlue
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = UIColor.systemRed

        return UISwipeActionsConfiguration(actions: [detailAction, deleteAction])
    }
}

extension TasksViewController: DetailViewDelegate {
    func updateTask(index: Int, task: Task, picture: Picture) {
        tasks[index] = task
        tasks[index].picture = picture
        
        saveContext()
        
        tableView.reloadData()
    } 
}
