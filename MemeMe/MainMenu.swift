//
//  MainMenu.swift
//  MemeMe
//
//  Created by Casey Arnold on 8/19/15.
//  Copyright (c) 2015 Casey Arnold. All rights reserved.
//

import Foundation
import UIKit


class MainMenu: UIViewController {
    
    //Locking Screen in Portrait View 
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
}


