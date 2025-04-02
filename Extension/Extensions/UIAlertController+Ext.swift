//
//  UIAlertController+Ext.swift
//  Extension
//
//  Created by Noah Pope on 10/24/24.
//

import UIKit

extension UIAlertController
{
    func addActions(_ actions: UIAlertAction...)
    {
        for action in actions { self.addAction(action) }
    }
}
