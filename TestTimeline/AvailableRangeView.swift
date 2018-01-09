//
//  AvailableRangeView.swift
//  TestTimeline
//
//  Created by Viet Nguyen Tran on 1/9/18.
//  Copyright © 2018 Viet Nguyen Tran. All rights reserved.
//

import UIKit

protocol AvailableRangeViewDelegate: class {
    func normalizeY(_ y: CGFloat) -> (CGFloat, Date)
}

class AvailableRangeView: UIView {
    @IBOutlet weak var activeRangeView: UIView!
    
    @IBOutlet weak var activeRangeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var activeRangeHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var upArrowView: UIImageView!
    
    @IBOutlet weak var downArrowView: UIImageView!
    
    @IBOutlet weak var upTimeLabel: UILabel!
    
    @IBOutlet weak var downTimeLabel: UILabel!
    
    weak var delegate: AvailableRangeViewDelegate?
    
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
        
        if gesture.state == .began || gesture.state == . changed {
            // make movement
            let vTranslate = gesture.translation(in: self).y
            guard activeRangeTopConstraint.constant + vTranslate >= validY.above,
                activeRangeView.height - vTranslate >= minimumRangeHeight else {
                    return
            }
            
            activeRangeHeightConstraint.constant = activeRangeView.height - vTranslate
            activeRangeTopConstraint.constant += vTranslate
            
            updateTimeLabel()
        } else if gesture.state == .ended || gesture.state == .cancelled {
            normalizeAboveLine()
        }
        
    }
    
    @objc func handleDownArrowPanGeture(_ gesture: UIPanGestureRecognizer) {
        defer {
            // reset translation for gesture
            gesture.setTranslation(.zero, in: nil)
        }
        
        if gesture.state == .began || gesture.state == . changed {
            // make movement
            let vTranslate = gesture.translation(in: self).y
            guard activeRangeView.height + vTranslate >= minimumRangeHeight, activeRangeView.y + activeRangeView.height + vTranslate <= validY.below else {
                return
            }
            
            activeRangeHeightConstraint.constant = activeRangeView.height + vTranslate
            
            updateTimeLabel()
        } else if gesture.state == .ended || gesture.state == .cancelled {
            normalizeBelowLine()
        }
    }
    
    func reDraw() {
        activeRangeTopConstraint.constant = validY.above
        activeRangeHeightConstraint.constant = minimumRangeHeight
        
        updateTimeLabel()
    }
    
    func updateTimeLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        if let upNormalize = delegate?.normalizeY(activeRangeTopConstraint.constant) {
            let date = upNormalize.1
            upTimeLabel.text = formatter.string(from: date)
        }
        
        if let downNormalize = delegate?.normalizeY(activeRangeTopConstraint.constant + activeRangeHeightConstraint.constant) {
            let date = downNormalize.1
            downTimeLabel.text = formatter.string(from: date)
        }
    }
    
    func normalizeAboveLine() {
        if let upNormalize = delegate?.normalizeY(activeRangeTopConstraint.constant) {
            let y = upNormalize.0
            let delta = y - activeRangeTopConstraint.constant
            activeRangeTopConstraint.constant += delta
            activeRangeHeightConstraint.constant -= delta
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.timeZone = Calendar.current.timeZone
            formatter.locale = Calendar.current.locale
            
            let date = upNormalize.1
            upTimeLabel.text = formatter.string(from: date)
        }
    }
    
    func normalizeBelowLine() {
        if let downNormalize = delegate?.normalizeY(activeRangeTopConstraint.constant + activeRangeHeightConstraint.constant) {
            let y = downNormalize.0
            let delta = y - (activeRangeTopConstraint.constant + activeRangeHeightConstraint.constant)
            activeRangeHeightConstraint.constant += delta
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.timeZone = Calendar.current.timeZone
            formatter.locale = Calendar.current.locale
            
            let date = downNormalize.1
            downTimeLabel.text = formatter.string(from: date)
        }
    }
}
