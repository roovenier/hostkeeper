//
//  NewProjectController.swift
//  Hostkeeper
//
//  Created by alexander.oschepkov on 07.08.17.
//  Copyright © 2017 alexander.oschepkov. All rights reserved.
//

import Cocoa
import AES256CBC

protocol NewProjectControllerDelegate {
    func addNewProject(newProject: Project);
}

class NewProjectController: NSViewController {

    @IBOutlet weak var projectTitleField: NSTextField!
    @IBOutlet weak var projectLinkField: NSTextField!
    @IBOutlet weak var projectHostField: NSTextField!
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var noticeLabel: NSTextField!
    
    
    let managedObjectContext: NSManagedObjectContext = DataManager.instance.managedObjectContext
    var delegate: NewProjectControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveProjectAction(_ sender: NSButton) {
        let projectTitle = self.projectTitleField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let projectLink = self.projectLinkField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let projectHost = self.projectHostField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = self.usernameField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.passwordField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if projectTitle.characters.count > 0 && projectLink.characters.count > 0 && projectHost.characters.count > 0 && username.characters.count > 0 && password.characters.count > 0 {
            let newProject = NSEntityDescription.insertNewObject(forEntityName: "Project", into: managedObjectContext) as! Project
            newProject.projectTitle = projectTitle
            newProject.projectLink = projectLink
            newProject.projectHost = projectHost
            newProject.username = username
            newProject.password = password
            newProject.createdDate = NSDate()
            
            do {
                try managedObjectContext.save()
                delegate?.addNewProject(newProject: newProject)
                
                self.view.window?.close()
            } catch {
                print("Error on insert new project")
            }
        } else {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 4.5
                noticeLabel.textColor = NSColor.red
            }, completionHandler: nil)
        }
    }
}
