//
//  IViewController.swift
//  FJRouter
//
//  Created by zgjff on 2026/3/1.
//

#if canImport(UIKit)
import UIKit
public typealias IViewController = UIViewController
#elseif canImport(AppKit)
import AppKit
public typealias IViewController = NSViewController
#endif
