//
//  ViewController.swift
//  Hostkeeper
//
//  Created by alexander.oschepkov on 07.08.17.
//  Copyright © 2017 alexander.oschepkov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NewProjectControllerDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    let managedObjectContext: NSManagedObjectContext = DataManager.instance.managedObjectContext
    
    var projectsArray = [Project]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        projectsArray = fetchedProjects()
        
        tableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return projectsArray.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableColumn!.identifier == "terminal" {
            let button = tableView.make(withIdentifier: "terminal", owner: self) as! NSButton
            button.title = "Открыть"
            return button
        } else {
            let result = tableView.make(withIdentifier:(tableColumn?.identifier)!, owner: self) as! NSTableCellView
            let projectTitle = projectsArray[row].value(forKey: (tableColumn?.identifier)!)! as! String
            result.textField?.stringValue = projectTitle
            return result
        }
    }
    
    // MARK: Actions
    
    func fetchedProjects() -> [Project] {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        
        do {
            let fetchedProjects = try managedObjectContext.fetch(fetch) as! [Project]
            return fetchedProjects
        } catch {
            fatalError("Failed to fetch projects: \(error)")
        }
    }
    
    // MARK: Segue
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewProjectSegue" {
            let vc = segue.destinationController as! NewProjectController
            vc.delegate = self
        }
    }
    
    // MARK: NewProjectControllerDelegate
    
    func addNewProject(newProject: Project) {
        projectsArray.insert(newProject, at: 0)
        tableView.reloadData()
    }
}
