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
        digit.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        addDoneButtonOnNumpad()
    }
    
    func addDoneButtonOnNumpad() {
        let keypadToolbar: UIToolbar = UIToolbar()
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(UIView.endEditing(_:)))
        keypadToolbar.setItems([flexButton, doneButton], animated: true)
        keypadToolbar.sizeToFit()
        digit.inputAccessoryView = keypadToolbar
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        let index = digit.tag
        if let text = digit.text, !text.isEmpty {
            parentVC.puzzle[index] = Int(text)!
            parentVC.color[index] = false
            
        } else {
            parentVC.puzzle[index] = -1
            parentVC.color[index] = true
        }
    }
}
