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
        tableView.backgroundColor = NSColor.clear
        
        projectsArray = fetchedProjects()
        
        tableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return projectsArray.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn!.identifier == "terminal" {
            let button = tableView.make(withIdentifier: "terminal", owner: self) as! NSButton
            button.title = "Терминал"
            button.tag = row
            button.target = self
            button.action = #selector(openTerminal(sender:))
            return button
        } else if tableColumn!.identifier == "browser" {
            let button = tableView.make(withIdentifier: "browser", owner: self) as! NSButton
            button.title = "Браузер"
            button.tag = row
            button.target = self
            button.action = #selector(openBrowser(sender:))
            return button
        } else {
            let result = tableView.make(withIdentifier:(tableColumn?.identifier)!, owner: self) as! NSTableCellView
            let projectTitle = projectsArray[row].value(forKey: (tableColumn?.identifier)!)! as! String
            result.textField?.stringValue = projectTitle
            return result
        }
    }
    
    // MARK: Actions
    
    func openTerminal(sender: NSButton) {
        let project = projectsArray[sender.tag]
        let scriptPath = Bundle.main.resourcePath! + "/exp"
        
        let fullCommand = "tell application \"Terminal\"\n activate\n tell application \"System Events\" to keystroke \"t\" using command down\n do script \"\(scriptPath) \(project.password!) \(project.projectHost!) \(project.username!)\" in window 1\n end tell"
        
        let appleScript = NSAppleScript.init(source: fullCommand)
        appleScript?.executeAndReturnError(nil)
    }
    
    func openBrowser(sender: NSButton) {
        let project = projectsArray[sender.tag]
        
        let fullCommand = "tell application \"Google Chrome\"\n repeat with w in windows\n set i to 1\n repeat with t in tabs of w\n if URL of t starts with \"https://mail.google\" then\n set active tab index of w to i\n set index of w to 1\n return\n end if\n set i to i + 1\n end repeat\n end repeat\n open location \"\(project.projectLink!)\"\n end tell"
        
        print(fullCommand)
        
        let appleScript = NSAppleScript.init(source: fullCommand)
        appleScript?.executeAndReturnError(nil)
    }
    
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
