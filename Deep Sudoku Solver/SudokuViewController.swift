//
//  SudokuController.swift
//  Deep Sudoku Solver
//
//  Created by Wai Ting Cheung on 2017. 3. 17..
//  Copyright © 2017년 Wai Ting Cheung. All rights reserved.
//

import UIKit

extension UIImage{
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}

protocol SudokuViewControllerDelegate {
    func importSudoku()
}

class SudokuViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var doneButton : UIBarButtonItem!
    @IBOutlet weak var solveButton : UIBarButtonItem!
    
    var screenSize : CGRect!
    var screenWidth : CGFloat!
    var screenHeight : CGFloat!
    
    let reuseIdentifier = "cell"
    var puzzle = [Int]()
    var color = [Bool]()
    var delegate : SudokuViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenSize = self.view.frame
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let topInset = (collectionView.frame.size.height - screenWidth) / 2
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: screenWidth / 9, height: screenWidth / 9)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        // Mark empty cells
        for index in 0..<81 {
            color.append(puzzle[index] == -1)
        }
        
        // Add frames for the puzzle
        for row in 0...2 {
            for col in 0...2 {
                let layer = CALayer()
                let x = CGFloat(col) * screenWidth / 3
                let y = CGFloat(row) * screenWidth / 3 + topInset
                layer.frame = CGRect(x: x, y: y, width: screenWidth / 3, height: screenWidth / 3)
                layer.borderWidth = 1.5
                collectionView.layer.addSublayer(layer)
            }
        }
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: topInset, width: screenWidth, height: screenWidth)
        layer.borderWidth = 3
        collectionView.layer.addSublayer(layer)
        
        registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 81
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth / 9, height: screenWidth / 9);
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.digit.tag = indexPath.row
        
        if (color[indexPath.row]) {
            cell.digit.textColor = UIColor.blue
        }
        
        let digit = puzzle[indexPath.row]
        if digit != -1 {
            cell.digit.text = String(digit)
        }
        
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 1
        
        return cell
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func solveSudoku() {
        var grid = ""
        for index in 0..<puzzle.count {
            let digit = puzzle[index]
            if digit != -1 {
                grid += String(digit)
            } else {
                grid += "."
            }
        }
        
        // Initial setup for the solver
        for s in 0..<(9 * 9) {
            units.append(squareUnits(s))
            peers.append(squarePeers(s).allObjects as! [Int])
        }
        
        let solution = solve(grid)
        puzzle = solution.gridValues(solution.description)
        collectionView.reloadData()
    }
    
    @IBAction func displayShareSheet() {
        let image =  UIImage.init(view: collectionView)
        
        // set up activity view controller
        let imageToShare = [ image ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        doneButton.isEnabled = false
        solveButton.isEnabled = false
        
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize!.height, right: 0)
        collectionView.contentInset = contentInsets
        collectionView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        doneButton.isEnabled = true
        solveButton.isEnabled = true
        
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: -keyboardSize!.height, right: 0)
        collectionView.contentInset = contentInsets
        collectionView.scrollIndicatorInsets = contentInsets
    }
}
