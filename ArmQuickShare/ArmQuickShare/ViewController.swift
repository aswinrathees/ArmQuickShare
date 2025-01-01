//
//  ViewController.swift
//  ArmQuickShare
//
//  Created by Aswin R on 26/12/24.
//

import UIKit
import Photos

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private var assetCollection: PHAssetCollection?
    private var photos: PHFetchResult<PHAsset>?
    private var imagePicker: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.sourceType = .camera
        
        fetchPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchPhotos()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier , id == "showImageSegue" {
            let showImageVC = segue.destination as! ShowImageViewController
            if let indexPath = self.tableView.indexPathForSelectedRow, let asset = self.photos?[indexPath.row] {
                showImageVC.asset = asset
            }
        }
    }
    
    @IBAction func capturePhoto(_ sender: Any) {
        guard let picker = imagePicker else {
            return
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker?.dismiss(animated: true, completion: nil)
        
        if let showImageVC = self.storyboard?.instantiateViewController(withIdentifier: "showImageVC") as? ShowImageViewController {
         
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
                showImageVC.image = image
                show(showImageVC, sender: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photos?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
        
        if let asset = self.photos?[indexPath.row] {
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: CGSize(width: 640, height: 480),
                                                  contentMode: .aspectFill,
                                                  options: nil) { result, data in
                
                if let image = result {
                    cell.imgView.image = image
                }
            }
        } else {
            cell.imgView.image = UIImage(named: "polaroid")
        }
        return cell
    }
    
    private func fetchPhotos() {
        let collection = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumUserLibrary,
            options: nil)
        
        if collection.firstObject != nil {
            assetCollection = collection.firstObject! as PHAssetCollection
            
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            self.photos = PHAsset.fetchAssets(in: assetCollection!, options: options)
        }
    }
}

