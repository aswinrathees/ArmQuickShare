//
//  ShowImageViewController.swift
//  ArmQuickShare
//
//  Created by Aswin R on 27/12/24.
//

import UIKit
import Photos
import Social

class ShowImageViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet var selectedImage: UIImageView!
    @IBOutlet var selectedImageName: UILabel!

    var asset: PHAsset?
    var documentController: UIDocumentInteractionController?
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showImage()
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        switch sender.accessibilityIdentifier {
        case "fb": if let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
            shareOnFBAndX(vc: vc)
        }
        case "insta": shareOnInstagram()
        case "whatsapp": shareOnWhatsApp()
        case "x": if let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
            shareOnFBAndX(vc: vc)
        }
        case "pinterest": print("Pinterest")
        default: print("Default")
        }
    }
    
    private func showImage() {
        if let img = self.image {
            self.selectedImage.image = img
        } else {
            guard let image = asset else { return }
            PHImageManager.default().requestImage(for: image,
                                                  targetSize:
                                                    CGSize(width: self.view.frame.width, height: self.view.frame.width*0.5625),
                                                  contentMode: .aspectFill,
                                                  options: nil) { result, data in
                
                if let selectedAsset = result {
                    self.selectedImage.image = selectedAsset
                    self.selectedImageName.text = data?.description ?? ""
                }
            }
        }
    }
    
    private func shareOnFBAndX(vc: SLComposeViewController) {
        vc.setInitialText("Hey, check this out!")
        vc.add(self.selectedImage.image)
        present(vc, animated: true, completion: nil)
    }
    
    private func shareOnInstagram() {
        let instaURL = URL(string: "instagram://app")
        
        if UIApplication.shared.canOpenURL(instaURL!) {
            let imageData = self.selectedImage.image!.jpegData(compressionQuality: 75)
            let caption = "Hey, check this out!"
            let writePath = (NSTemporaryDirectory()).appending("instagram.igo")
            
            do {
                try imageData?.write(to: URL(fileURLWithPath: writePath), options: .atomicWrite)
                let fileUrl = URL(fileURLWithPath: writePath)
                
                self.documentController = UIDocumentInteractionController(url: fileUrl)
                self.documentController?.delegate = self
                self.documentController?.uti = "com.instagram.exclusivegram"
                self.documentController?.annotation = NSDictionary(object: caption, forKey: "InstagramCaption" as NSCopying)
                self.documentController?.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
            } catch let error as NSError{
                print("Error writing to file \(error.description)")
            }
        }
    }
    
    private func shareOnWhatsApp() {
        let whatsAppURL = URL(string: "whatsapp://app")
        
        if UIApplication.shared.canOpenURL(whatsAppURL!) {
            if let imageData = self.selectedImage.image?.jpegData(compressionQuality: 0.75) {
                // Create the full path including the directory
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let filePath = (documentsPath as NSString).appendingPathComponent("whatsAppTmp.wai")
                let fileURL = URL(fileURLWithPath: filePath)
                
                do {
                    // Create the directory if it doesn't exist
                    try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                            withIntermediateDirectories: true)
                    
                    // Write the file
                    try imageData.write(to: fileURL, options: .atomic)
                    
                    self.documentController = UIDocumentInteractionController(url: fileURL)
                    self.documentController?.delegate = self
                    self.documentController?.uti = "net.whatsapp.image"
                    self.documentController?.presentOpenInMenu(from: self.view.frame,
                                                               in: self.view,
                                                               animated: true)
                } catch {
                    print("Error writing to file: \(error)")
                }
            }
        }
    }
}
