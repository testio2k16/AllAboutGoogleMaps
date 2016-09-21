//
//  ProtocolsAndExtensions.swift
//  AllAboutGoogleMaps
//
//  Created by testio2k16 on 9/20/16.
//  Copyright © 2016 testio2k16. All rights reserved.
//

import Foundation
import UIKit

protocol CustomRoutingDelegate {
    func startRouting()
}

extension UIView{
    func cardStyle(view:UIView){
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 5
        view.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 3
    }
}

