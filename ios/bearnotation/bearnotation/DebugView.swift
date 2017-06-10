//
//  DebugView.swift
//  bearnotation
//
//  Created by Mahasak Pijittum on 6/10/2560 BE.
//  Copyright © 2560 Mahasak Pijittum. All rights reserved.
//

import Foundation

import UIKit

class DebugView: UIView {
    var shouldSetupConstraints = true
    var bannerView: UITextView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bannerView = UITextView(frame: CGRect.zero)
        bannerView.backgroundColor = UIColor(red: 39/255, green: 53/255, blue: 182/255, alpha: 1)
        bannerView.text = "Debug"
        
        self.addSubview(bannerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        bannerView = UITextView(frame: CGRect.zero)
        bannerView.text = "Debug"
        
        self.addSubview(bannerView)
    }
    
    override func updateConstraints() {
        if(shouldSetupConstraints) {
            // AutoLayout constraints
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
}
