//
//  UIViewController+Extensions.swift
//  FJRouter
//
//  Created by zgjff on 2025/4/12.
//

#if canImport(UIKit)
import Foundation
import UIKit

extension UIViewController {
    func lastPresentedViewController() -> UIViewController? {
        guard let pted = presentedViewController else {
            return nil
        }
        var lpted = pted
        while lpted.presentedViewController != nil {
            if let vc = lpted.presentedViewController {
                lpted = vc
            }
        }
        return lpted
    }
}

#endif
