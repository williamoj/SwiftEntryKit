//
//  QLCompatibility.swift
//  Pods
//
//  Created by Daniel Huri on 5/12/18.
//

import Foundation

public typealias QLAttribute = NSLayoutAttribute
public typealias QLRelation = NSLayoutRelation

#if os(OSX)
import AppKit
public typealias QLView = NSView
public typealias QLPriority = NSLayoutConstraint.Priority
#else
import UIKit
public typealias QLView = UIView
public typealias QLPriority = UILayoutPriority
#endif
