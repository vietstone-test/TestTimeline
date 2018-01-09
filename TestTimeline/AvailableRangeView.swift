//
//  AvailableRangeView.swift
//  TestTimeline
//
//  Created by Viet Nguyen Tran on 1/9/18.
//  Copyright © 2018 Viet Nguyen Tran. All rights reserved.
//

import UIKit

class AvailableRangeView: UIView {
    @IBOutlet weak var activeRangeView: UIView!
    
    @IBOutlet weak var activeRangeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var activeRangeHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var upArrowView: UIImageView!
    
    @IBOutlet weak var downArrowView: UIImageView!
    
    @IBOutlet weak var upTimeLabel: UILabel!
    
    @IBOutlet weak var downTimeLabel: UILabel!
    
    var minimumRangeHeight: CGFloat = 50
    
    var validY: (above: CGFloat, below: CGFloat) = (0, 0)
    
    static func create() -> AvailableRangeView? {
        return Bundle.main.loadNibNamed("AvailableRangeView", owner: nil, options: nil)?.first as? AvailableRangeView
    }
    
    override func awakeFromNib() {
        let upPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleUpArrowPanGesture(_:)))
        upArrowView.addGestureRecognizer(upPanGesture)
        
        let downPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDownArrowPanGeture(_:)))
        downArrowView.addGestureRecognizer(downPanGesture)
        
//        backgroundColor = UIColor.clear
        
        validY = (0, self.height)
        
        // first setup
        reDraw()
    }
    
    @objc func handleUpArrowPanGesture(_ gesture: UIPanGestureRecognizer) {
        defer {
            // reset translation for gesture
            gesture.setTranslation(.zero, in: nil)
        }
        
        // make movement
        let vTranslate = gesture.translation(in: self).y
        guard activeRangeTopConstraint.constant + vTranslate >= validY.above,
            activeRangeView.height - vTranslate >= minimumRangeHeight else {
            return
        }
        
        activeRangeHeightConstraint.constant = activeRangeView.height - vTranslate
        activeRangeTopConstraint.constant += vTranslate
    }
    
    @objc func handleDownArrowPanGeture(_ gesture: UIPanGestureRecognizer) {
        defer {
            // reset translation for gesture
            gesture.setTranslation(.zero, in: nil)
        }
        
        // make movement
        let vTranslate = gesture.translation(in: self).y
        guard activeRangeView.height + vTranslate >= minimumRangeHeight, activeRangeView.y + activeRangeView.height + vTranslate <= validY.below else {
            return
        }
        
        activeRangeHeightConstraint.constant = activeRangeView.height + vTranslate
    }
    
    func reDraw() {
        activeRangeTopConstraint.constant = validY.above
        activeRangeHeightConstraint.constant = minimumRangeHeight
    }
}
