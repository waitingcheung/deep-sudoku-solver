//
//  CollectionViewCell.swift
//  Deep Sudoku Solver
//
//  Created by Wai Ting Cheung on 2017. 3. 18..
//  Copyright © 2017년 Wai Ting Cheung. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var digit: UITextField!
    @IBOutlet weak var parentVC: SudokuViewController!
    
    override func awakeFromNib() {
        addDoneButtonOnNumpad()
    }
    
    func addDoneButtonOnNumpad() {
        let keypadToolbar: UIToolbar = UIToolbar()
        keypadToolbar.items = [
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(updateDigit)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        ]
        keypadToolbar.sizeToFit()
        digit.inputAccessoryView = keypadToolbar
    }
    
    func updateDigit(sender: UIBarButtonItem!) {
        if let text = digit.text, !text.isEmpty {
            let index = digit.tag
            parentVC.puzzle[index] = Int(text)!
        }
        digit.endEditing(true)
    }
}
