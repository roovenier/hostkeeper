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
    @IBOutlet weak var projectPortField: NSTextField!
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var noticeLabel: NSTextField!
    
    let managedObjectContext: NSManagedObjectContext = DataManager.instance.managedObjectContext
    var delegate: EditProjectControllerDelegate?
    var project: Project?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        _ = self.view.window?.styleMask.remove(.resizable)
        
        let xOriginPosition = (self.presenting?.view.window?.frame.origin.x)! + ((self.presenting?.view.window?.frame.size.width)! - (self.view.window?.frame.size.width)!) / 2
        let yOriginPosition = (self.presenting?.view.window?.frame.origin.y)! + ((self.presenting?.view.window?.frame.size.height)! - (self.view.window?.frame.size.height)!) / 2
        
        let windowPosition = CGPoint(x: xOriginPosition, y: yOriginPosition)
        let windowSize = self.view.window?.frame.size
        self.view.window?.setFrame(NSRect(origin: windowPosition, size: windowSize!), display: true)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = project!.projectTitle!
        
        projectTitleField.stringValue = project!.projectTitle!
        projectLinkField.stringValue = project!.projectLink!
        projectHostField.stringValue = project!.projectHost!
        projectPortField.stringValue = project!.projectPort!
        usernameField.stringValue = project!.username!
        passwordField.stringValue = project!.password!
    }
    
    @IBAction func saveProjectAction(_ sender: NSButton) {
        let projectTitle = self.projectTitleField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let projectHost = self.projectHostField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = self.usernameField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.passwordField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if projectTitle.characters.count > 0 && projectHost.characters.count > 0 && username.characters.count > 0 && password.characters.count > 0 {
            let projectLink = self.projectLinkField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let projectPort = self.projectPortField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            
            project?.projectTitle = projectTitle
            project?.projectLink = projectLink
            project?.projectHost = projectHost
            project?.projectPort = projectPort.characters.count == 0 ? "22" : projectPort
            project?.username = username
            project?.password = password
            
            do {
                try managedObjectContext.save()
                delegate?.editProjectUpdate()
                
                self.view.window?.close()
            } catch {
                print("Error on insert new project")
            }
        } else {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.5
                self.noticeLabel.textColor = NSColor.red
            }, completionHandler: nil)
        }
    }
    
}
