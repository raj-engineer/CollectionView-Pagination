//
//  Helper.swift
//  CollectionView-Pagination
//
//  Created by Rajesh on 30/11/18.
//  Copyright © 2018 Rajesh. All rights reserved.
//

import Foundation
import UIKit
// Singleton Instance
class Helper{
    static let sharedHelper = Helper()
    private init(){}
    
    
    func common_alert( vc : UIViewController , title : String , message : String)
    {
        
        let alert_controller = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let ok_action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert_controller.addAction(ok_action)
        vc.present(alert_controller, animated: true, completion: nil)
        
    }
}
