//
//  EditProjectController.swift
//  Hostkeeper
//
//  Created by alexander.oschepkov on 08.08.17.
//  Copyright © 2017 alexander.oschepkov. All rights reserved.
//

import Cocoa

protocol EditProjectControllerDelegate {
    func editProjectUpdate();
}

class EditProjectController: NSViewController {

    @IBOutlet weak var projectTitleField: NSTextField!
    @IBOutlet weak var projectLinkField: NSTextField!
    @IBOutlet weak var projectHostField: NSTextField!
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    
    let managedObjectContext: NSManagedObjectContext = DataManager.instance.managedObjectContext
    var delegate: EditProjectControllerDelegate?
    var project: Project?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = project!.projectTitle!
        
        projectTitleField.stringValue = project!.projectTitle!
        projectLinkField.stringValue = project!.projectLink!
        projectHostField.stringValue = project!.projectHost!
        usernameField.stringValue = project!.username!
        passwordField.stringValue = project!.password!
    }
    
    @IBAction func saveProjectAction(_ sender: NSButton) {
        let projectTitle = self.projectTitleField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let projectLink = self.projectLinkField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let projectHost = self.projectHostField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = self.usernameField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.passwordField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if projectTitle.characters.count > 0 && projectLink.characters.count > 0 && projectHost.characters.count > 0 && username.characters.count > 0 && password.characters.count > 0 {
            project?.projectTitle = projectTitle
            project?.projectLink = projectLink
            project?.projectHost = projectHost
            project?.username = username
            project?.password = password
            
            do {
                try managedObjectContext.save()
                delegate?.editProjectUpdate()
                
                self.view.window?.close()
            } catch {
                print("Error on insert new project")
            }
        }
    }
    
}
