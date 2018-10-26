//
//  QuestionView.swift
//  OpenQuizz
//
//  Created by ALEXANDRE GROSSON on 23/10/2018.
//  Copyright © 2018 GROSSON. All rights reserved.
//

import UIKit

class QuestionView: UIView {
    
    @IBOutlet private var label:UILabel!
    @IBOutlet  private var icon : UIImageView!
    
    enum Style {
        case correct, incorrect, standard
    }
    
    var title = ""
    {
        didSet {
            label.text = title
        }
    }
    
    var style: Style = .standard {
        didSet {
            setStyle(style)
        }
    }
    
    private func setStyle(_ style: Style){
        switch style {
        case .correct:
            backgroundColor = UIColor(red: 200/255.0, green: 236/255.0, blue: 160/255.0, alpha: 1)
            icon.image = UIImage(named: "Icon Correct")
            icon.isHidden = false
        case .incorrect:
            backgroundColor = #colorLiteral(red: 1, green: 0.2601473331, blue: 0.4819564819, alpha: 1)
            icon.image = #imageLiteral(resourceName: "Icon Error")
            icon.isHidden = false
        case .standard:
            backgroundColor = #colorLiteral(red: 0.7607843137, green: 0.7725490196, blue: 0.7882352941, alpha: 1)
            icon.isHidden = true
        }
    }
    
}
