//
//  ViewController.swift
//  Deep Sudoku Solver
//
//  Created by Wai Ting Cheung on 2017. 2. 15..
//  Copyright © 2017년 Wai Ting Cheung. All rights reserved.
//

import UIKit
import Foundation
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SudokuViewControllerDelegate {
    
    let picker = UIImagePickerController()
    let magic = ImageMagic()
    let ai = MnistNet()
    var puzzle = [Int]()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var importButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        picker.delegate = self
        importButton.isEnabled = false
        activityIndicator.center = view.center
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openActionSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) -> Void in
            self.openCamera()
        })
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) -> Void in
            self.photoFromLibrary()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true {
            alertController.addAction(cameraAction)
        }
        
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func photoFromLibrary() {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker,animated: true,completion: nil)
        }
    }
    
    func importSudoku() {        
        if imageView.image != nil {
            puzzle.removeAll()
            
            let image = imageView.image!
            let width = image.size.width
            let height = image.size.height
            let xOffset = width / 9
            let yOffset = height / 9
            
            for row in 0...8 {
                for col in 0...8 {
                    
                    // Extract a tile from the puzzle
                    let newX = CGFloat(col) * xOffset + xOffset * 0.1
                    let newY = CGFloat(row) * yOffset + yOffset * 0.1
                    let rect = CGRect(x: newX, y: newY, width: xOffset * 0.8, height: yOffset * 0.8)
                    let cgTile : CGImage = image.cgImage!.cropping(to: rect)!
                    let tile = UIImage(cgImage: cgTile)
                    
                    // Sample the center of the tile to check if there is a number
                    let centerX = tile.size.width * 0.25
                    let centerY = tile.size.height * 0.25
                    let centerRect = CGRect(x: centerX, y: centerY, width: tile.size.width * 0.5, height: tile.size.height * 0.5)
                    
                    
                    if !isEmptyCell(image: tile, rect: centerRect) {
                        guard let data = magic.mnistData(image: tile)
                            else {
                                return
                        }
                        let predicted = ai.predict(input: data)
                        puzzle.append(predicted)
                    } else {
                        puzzle.append(-1)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sudokuView" {
            activityIndicator.startAnimating()
            view.addSubview(activityIndicator)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.importSudoku()
                
                let navController = segue.destination as! UINavigationController
                let viewController = navController.topViewController as! SudokuViewController
                viewController.puzzle = self.puzzle
                viewController.delegate = self
                
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode = .scaleAspectFit
        let grayImage = convertToGrayScale(image: chosenImage)
        imageView.image = grayImage
        importButton.isEnabled = true
        dismiss(animated:true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
