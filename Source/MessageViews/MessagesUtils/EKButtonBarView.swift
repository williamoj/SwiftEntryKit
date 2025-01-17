//
//  ButtonsBarView.swift
//  SwiftEntryKit_Example
//
//  Created by Daniel Huri on 4/28/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import UIKit
import QuickLayout

/**
 Dynamic button bar view
 Buttons are set according to the received content.
 1-2 buttons spread horizontally
 3 or more buttons spread vertically
 */
public class EKButtonBarView: UIView {
    
    // MARK: Props
    private var buttonViews: [EKButtonView] = []
    
    private let buttonBarContent: EKProperty.ButtonBarContent
    private let spreadAxis: QLAxis
    private let oppositeAxis: QLAxis
    private let relativeEdge: NSLayoutAttribute
    
    var bottomCornerRadius: CGFloat = 0 {
        didSet {
            adjustRoundCornersIfNecessary()
        }
    }
    
    private lazy var buttonEdgeRatio: CGFloat = {
        return 1.0 / CGFloat(self.buttonBarContent.content.count)
    }()
    
    private(set) lazy var intrinsicHeight: CGFloat = {
        var height: CGFloat = 0
        switch buttonBarContent.content.count {
        case 0:
            height += 1
        case 1...buttonBarContent.horizontalDistributionThreshold:
            height += buttonBarContent.buttonHeight
        default:
            for _ in 1...buttonBarContent.content.count {
                height += buttonBarContent.buttonHeight
            }
        }
        return height
    }()
    
    private var compressedConstraint: NSLayoutConstraint!
    private lazy var expandedConstraint: NSLayoutConstraint = {
        return set(.height, of: intrinsicHeight, priority: .defaultLow)
    }()

    // MARK: Setup
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(with buttonBarContent: EKProperty.ButtonBarContent) {
        self.buttonBarContent = buttonBarContent
        if buttonBarContent.content.count <= buttonBarContent.horizontalDistributionThreshold {
            spreadAxis = .horizontally
            oppositeAxis = .vertically
            relativeEdge = .width
        } else {
            spreadAxis = .vertically
            oppositeAxis = .horizontally
            relativeEdge = .height
        }
        super.init(frame: .zero)
        setupButtonBarContent()
        setupSeparatorViews()
        
        compressedConstraint = set(.height, of: 1, priority: .must)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        adjustRoundCornersIfNecessary()
    }

    private func setupButtonBarContent() {
        for content in buttonBarContent.content {
            let buttonView = EKButtonView(content: content)
            addSubview(buttonView)
            buttonViews.append(buttonView)
        }
        layoutButtons()
    }
    
    private func layoutButtons() {
        guard !buttonViews.isEmpty else {
            return
        }
        let suffix = Array(buttonViews.dropFirst())
        if !suffix.isEmpty {
            suffix.layout(.height, to: buttonViews.first!)
        }
        buttonViews.layoutToSuperview(axis: oppositeAxis)
        buttonViews.spread(spreadAxis, stretchEdgesToSuperview: true)
        buttonViews.layout(relativeEdge, to: self, ratio: buttonEdgeRatio, priority: .must)
    }
    
    private func setupTopSeperatorView() {
        let topSeparatorView = UIView()
        addSubview(topSeparatorView)
        topSeparatorView.set(.height, of: 1)
        topSeparatorView.layoutToSuperview(.left, .right, .top)
        topSeparatorView.backgroundColor = buttonBarContent.separatorColor
    }
    
    private func setupSeperatorView(after view: UIView) {
        let midSepView = UIView()
        addSubview(midSepView)
        let sepAttribute: NSLayoutAttribute
        let buttonAttribute: NSLayoutAttribute
        switch oppositeAxis {
        case .vertically:
            sepAttribute = .centerX
            buttonAttribute = .right
        case .horizontally:
            sepAttribute = .centerY
            buttonAttribute = .bottom
        }
        midSepView.layout(sepAttribute, to: buttonAttribute, of: view)
        midSepView.set(relativeEdge, of: 1)
        midSepView.layoutToSuperview(axis: oppositeAxis)
        midSepView.backgroundColor = buttonBarContent.separatorColor
    }
    
    private func setupSeparatorViews() {
        setupTopSeperatorView()
        for button in buttonViews.dropLast() {
            setupSeperatorView(after: button)
        }
    }
    
    // Amination
    public func expand() {
        
        let expansion = {
            self.compressedConstraint.priority = .defaultLow
            self.expandedConstraint.priority = .must
            
            /* NOTE: Calling layoutIfNeeded for the whole view hierarchy.
             Sometimes it's easier to just use frames instead of AutoLayout for
             hierarch complexity considerations. Here the animation influences almost the
             entire view hierarchy. */
            SwiftEntryKit.layoutIfNeeded()
        }
        
        alpha = 1
        if buttonBarContent.expandAnimatedly {
            let damping: CGFloat = buttonBarContent.content.count <= 2 ? 0.4 : 0.8
            SwiftEntryKit.layoutIfNeeded()
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 0, options: [.beginFromCurrentState, .allowUserInteraction, .layoutSubviews, .allowAnimatedContent], animations: {
                expansion()
            }, completion: nil)
        } else {
            expansion()
        }
    }
    
    public func compress() {
        compressedConstraint.priority = .must
        expandedConstraint.priority = .defaultLow
    }
    
    private func adjustRoundCornersIfNecessary() {
        let size = CGSize(width: bottomCornerRadius, height: bottomCornerRadius)
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .bottom, cornerRadii: size)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}
