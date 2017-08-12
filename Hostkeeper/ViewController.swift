//
//  ViewController.swift
//  Hostkeeper
//
//  Created by alexander.oschepkov on 07.08.17.
//  Copyright © 2017 alexander.oschepkov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NewProjectControllerDelegate, EditProjectControllerDelegate {
    
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var newProjectButton: NSButton!
    @IBOutlet weak var firstProjectButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    let managedObjectContext: NSManagedObjectContext = DataManager.instance.managedObjectContext
    
    var projectsArray = [Project]()
    var projectsArrayFiltered = [Project]()
    var isStateForEmptyTable: Bool?
    var isSearchingActive: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = NSColor.clear
        
        projectsArray = fetchedProjects()
        
        tableView.reloadData()
        
        setStatesForViews(isDataExists: projectsArray.count == 0 ? false : true)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if isSearchingActive {
            return self.projectsArrayFiltered.count
        }
        else {
            return projectsArray.count
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn!.identifier == "terminal" {
            let button = tableView.make(withIdentifier: "terminal", owner: self) as! NSButton
            button.tag = row
            button.target = self
            button.action = #selector(openTerminal(sender:))
            return button
        } else if tableColumn!.identifier == "transmit" {
            let button = tableView.make(withIdentifier: "transmit", owner: self) as! NSButton
            button.tag = row
            button.target = self
            button.action = #selector(openTransmit(sender:))
            return button
        } else if tableColumn!.identifier == "browser" {
            let button = tableView.make(withIdentifier: "browser", owner: self) as! NSButton
            button.tag = row
            button.target = self
            button.action = #selector(openBrowser(sender:))
            return button
        } else if tableColumn!.identifier == "edit" {
            let button = tableView.make(withIdentifier: "edit", owner: self) as! NSButton
            button.tag = row
            button.target = self
            button.action = #selector(editProject(sender:))
            return button
        } else if tableColumn!.identifier == "remove" {
            let button = tableView.make(withIdentifier: "remove", owner: self) as! NSButton
            button.tag = row
            button.target = self
            button.action = #selector(removeProject(sender:))
            return button
        } else {
            let result = tableView.make(withIdentifier:(tableColumn?.identifier)!, owner: self) as! NSTableCellView
            
            var projectTitle = projectsArray[row].value(forKey: (tableColumn?.identifier)!)! as! String
            if projectsArrayFiltered.count > 0 {
                projectTitle = projectsArrayFiltered[row].value(forKey: (tableColumn?.identifier)!)! as! String
            }
            
            result.textField?.stringValue = projectTitle
            return result
        }
    }
    
    // MARK: Actions
    
    func clearSearch() {
        projectsArrayFiltered.removeAll()
        searchField.stringValue = ""
        isSearchingActive = false
        tableView.reloadData()
    }
    
    func setStatesForViews(isDataExists: Bool) {
        searchField.isHidden = !isDataExists
        newProjectButton.isHidden = !isDataExists
        tableView.isHidden = !isDataExists
        firstProjectButton.isHidden = isDataExists
        isStateForEmptyTable = !isDataExists
    }
    
    @IBAction func searchFieldAction(_ sender: NSSearchField) {
        let searchValue = sender.stringValue.trimmingCharacters(in: .whitespaces)
        
        isSearchingActive = true
        
        if searchValue.characters.count == 0 {
            projectsArrayFiltered.removeAll()
            
            isSearchingActive = false
        } else {
            projectsArrayFiltered = self.projectsArray.filter { $0.projectTitle!.lowercased().contains(sender.stringValue.lowercased()) }
        }
        
        tableView.reloadData()
    }
    
    func clearAllData() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try managedObjectContext.execute(request)
        } catch {
            print("Error on clear core data")
        }
    }
    
    func openTerminal(sender: NSButton) {
        let project = isSearchingActive ? projectsArrayFiltered[sender.tag] : projectsArray[sender.tag]
        let scriptPath = Bundle.main.resourcePath! + "/exp"
        
        let fullCommand = "tell application \"Terminal\"\n activate\n do script \"\(scriptPath) \(project.password!) \(project.projectHost!) \(project.username!)\"\n end tell"
        
        let appleScript = NSAppleScript.init(source: fullCommand)
        appleScript?.executeAndReturnError(nil)
    }
    
    func openTransmit(sender: NSButton) {
        let project = isSearchingActive ? projectsArrayFiltered[sender.tag] : projectsArray[sender.tag]
        
        let fullCommand = "tell application \"Transmit\"\n activate\n tell current tab of (make new document at end)\n connect to address \"\(project.projectHost!)\" as user \"\(project.username!)\" using port 22 with password \"\(project.password!)\" with protocol SFTP\n end tell\n end tell"
        
        let appleScript = NSAppleScript.init(source: fullCommand)
        appleScript?.executeAndReturnError(nil)
    }
    
    func openBrowser(sender: NSButton) {
        let project = isSearchingActive ? projectsArrayFiltered[sender.tag] : projectsArray[sender.tag]
        
        let fullCommand = "tell application \"Google Chrome\"\n activate\n repeat with w in windows\n set i to 1\n repeat with t in tabs of w\n if URL of t starts with \"https://mail.google\" then\n set active tab index of w to i\n set index of w to 1\n return\n end if\n set i to i + 1\n end repeat\n end repeat\n open location \"\(project.projectLink!)\"\n end tell"
        
        let appleScript = NSAppleScript.init(source: fullCommand)
        appleScript?.executeAndReturnError(nil)
    }
    
    func editProject(sender: NSButton) {
        let project = isSearchingActive ? projectsArrayFiltered[sender.tag] : projectsArray[sender.tag]
        
        let vc = self.storyboard?.instantiateController(withIdentifier: "EditProjectController") as! EditProjectController
        
        vc.delegate = self
        vc.project = project
        
        self.presentViewControllerAsModalWindow(vc)
    }
    
    func removeProject(sender: NSButton) {
        let project = isSearchingActive ? projectsArrayFiltered[sender.tag] : projectsArray[sender.tag]
        
        let alert = NSAlert()
        alert.messageText = project.projectTitle!
        alert.informativeText = "Вы действительно хотите удалить этот проект?"
        alert.addButton(withTitle: "Удалить")
        alert.addButton(withTitle: "Отменить")
        alert.alertStyle = NSAlertStyle.warning
        
        alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSAlertFirstButtonReturn {
                self.managedObjectContext.delete(project)
                
                do {
                    try self.managedObjectContext.save()
                    
                    if let projectIndex = self.projectsArrayFiltered.index(of: project) {
                        self.projectsArrayFiltered.remove(at: projectIndex)
                        
                        if let indexForFullArray = self.projectsArray.index(of: project) {
                            self.projectsArray.remove(at: indexForFullArray)
                        }
                    } else {
                        self.projectsArray.remove(at: sender.tag)
                    }
                    
                    self.tableView.beginUpdates()
                    self.tableView.removeRows(at: IndexSet.init(integer: sender.tag), withAnimation: NSTableViewAnimationOptions.effectFade)
                    self.tableView.endUpdates()
                    
                    if self.projectsArrayFiltered.count == 0 {
                        self.clearSearch()
                    }
                    
                    if self.projectsArray.count == 0 {
                        self.setStatesForViews(isDataExists: false)
                    }
                } catch {
                    print("Error on insert new project")
                }
            }
        })
    }
    
    func fetchedProjects() -> [Project] {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        fetch.sortDescriptors = [sortDescriptor]
        
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
            clearSearch()
        }
        
        if segue.identifier == "FirstProjectSegue" {
            let vc = segue.destinationController as! NewProjectController
            vc.delegate = self
            clearSearch()
        }
    }
    
    // MARK: NewProjectControllerDelegate
    
    func addNewProject(newProject: Project) {
        if isStateForEmptyTable! {
            setStatesForViews(isDataExists: true)
        }
        
        projectsArray.insert(newProject, at: 0)
        
        tableView.beginUpdates()
        tableView.insertRows(at: IndexSet.init(integer: 0), withAnimation: NSTableViewAnimationOptions.effectFade)
        tableView.endUpdates()
    }
    
    // MARK: EditProjectControllerDelegate
    
    func editProjectUpdate() {
        tableView.reloadData()
    }
}
