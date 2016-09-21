//
//  CustomInfoWindow.swift
//  AllAboutGoogleMaps
//
//  Created by testio2k16 on 9/20/16.
//  Copyright © 2016 testio2k16. All rights reserved.
//

import UIKit

class CustomInfoWindow: UIView {
    
    var delegate:CustomRoutingDelegate?
    
    @IBOutlet var view1: UIView!
    
    @IBOutlet var placeName: UILabel!
    
    @IBOutlet var routingBtn: UIButton!
    
    @IBAction func routingBtnOnClick(sender: UIButton) {
        delegate?.startRouting()
        
    }
    
    
    
    
    
}
