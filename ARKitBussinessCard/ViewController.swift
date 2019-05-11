//
//  ViewController.swift
//  ARKitBussinessCard
//
//  Created by sun on 11/5/2562 BE.
//  Copyright © 2562 sun. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MessageUI
import Contacts

class ViewController: UIViewController, ARSCNViewDelegate {
    
    let configuration = ARImageTrackingConfiguration()
    @IBOutlet var sceneView: ARSCNView!
       var menuShown = false
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       if !menuShown {setupARSession()} // check ว่า มีเมนูอะไรเช่น email sms show อยู่หรือเปล่า ถ้าไม่มีให้ setupARSession ทำงาน
        
    }
    
    func setupARSession()  {
        
          // Create a session configuration
        
        guard let trackingImages =  ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        configuration.trackingImages = trackingImages
        configuration.maximumNumberOfTrackedImages = 1
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
       // sceneView.session.pause() // เมื่อออกจาก แอพให้หยุด ar แต่เราไม่ใช้มัน
    }

    
  
    // render Rootnode
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            
            guard anchor is ARImageAnchor else { return }
            
            // RootNode
            guard let RootNode = sceneView.scene.rootNode.childNode(withName: "RootNode", recursively: false) else { return }
            
            RootNode.removeFromParentNode()
            node.addChildNode(RootNode)
            RootNode.isHidden = false
            
        }

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //  find touchespoint in ar
        guard let currentTouchLocation = touches.first?.location(in: self.sceneView), let hitTestResult = self.sceneView.hitTest(currentTouchLocation, options: nil).first?.node.name else { return }
        
        switch hitTestResult {
        case "phoneIcon":
            callPhoneNumber("0645125888")
        case "smsLogo":
            sendSMSTo("0645125888")
        case "Email":
            sendEmailTo("twinsamson@gmail.com")
        case "saveIcon":
            saveContactToAddressBook()
       
        default: ()
        }
        
        
    }
    
    /// call phone number
    func callPhoneNumber(_ number: String){
        
        
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            
              menuShown = true
            
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
            
        }else{
            print("Error Trying To Connect To Mobile Provider")
        }
    }
    
    
    /// Sends An SMS To The Number On The Business Card
    ///
    /// - Parameter number: String
    func sendSMSTo(_ number: String){
        
        if MFMessageComposeViewController.canSendText(){
            
              menuShown = true
            
            let smsController = MFMessageComposeViewController()
            smsController.body = "Enquiry About Your Business"
            smsController.recipients = [number]
           smsController.messageComposeDelegate = self
            present(smsController, animated: true, completion: nil)
        }else{
            print("Error Loading SMS Composer")
            
            showSaveMessage("Error Loading SMS Composer")
        }
        
    }
    
    /// Sends An Email To The Business Card Holder
    ///
    /// - Parameter recipient: String
    func sendEmailTo(_ recipient: String){
        
        if MFMailComposeViewController.canSendMail(){
            
              menuShown = true
            
            let mailComposer = MFMailComposeViewController()
        
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("Enquiry About Your Business")
            mailComposer.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            mailComposer.setToRecipients([recipient])
            present(mailComposer, animated: true, completion: nil)
        }else{
            print("Error Loading Email Composer")
        }
        
    }
    
    
    
    
    func saveContactToAddressBook(){
        
        //1. Create A Contact
        let businessContact = CNMutableContact()
        
        //2. Create The First & Last Names Of The Contact & The Associates Job Title
        let fullName = "Chaichana Lohasaptawee"
        businessContact.givenName = "Chaichana"
        businessContact.familyName = "Lohasaptawee"
    //    businessContact.jobTitle =
  //      businessContact.organizationName =
        
     
        
        //4. Set The Associates Work Email
        let workEmail = CNLabeledValue(label:CNLabelWork, value: "twinsamson@gmail.com" as NSString)
        businessContact.emailAddresses = [workEmail]
        
        //5. Set The Associates Work Phone Number
        businessContact.phoneNumbers = [CNLabeledValue ( label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: "0645125888"))]
        
        //6. Set The Associates Work Address
        let address = CNMutablePostalAddress()
       //  let cardAdress = businessCard.cardData.address
        address.street = " Bangna-Trad "
        address.city = "Bangkok "
        address.postalCode = "10260"
        
        businessContact.postalAddresses = [CNLabeledValue(label: CNLabelWork, value: address)]
        
     
        //8. Save It To The Device
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(businessContact, toContainerWithIdentifier:nil)
        
        do{
            try store.execute(saveRequest)
            showSaveMessage("\(fullName) Saved To Contacts")
            
        }catch{
            showSaveMessage("\(fullName) Not Saved To Contacts")
        }
        
    }
    
    
    
    
    /// Shows A Success Or Error Message When Trying To Save The Associate's Contact Details
    ///
    /// - Parameter message: String
    func showSaveMessage(_ message: String){
        
        let saveMessage = UIAlertController(title: "Message From ChaiChana", message: message, preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        saveMessage.addAction(dismissButton)
        present(saveMessage, animated: true, completion: nil)
    }
    // ----------------------------------------------------------------------/
    
    
    
    
}// main class





// mail and sms delegate

extension ViewController: MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true)  { self.menuShown = false }
    }
}

extension ViewController: MFMessageComposeViewControllerDelegate{
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        controller.dismiss(animated: true) { self.menuShown = false }
        
    }
    
}

//-------------------------------------------------------------------------/


 
