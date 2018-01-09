//
//  ViewController.swift
//  TestTimeline
//
//  Created by Viet Nguyen Tran on 1/8/18.
//  Copyright © 2018 Viet Nguyen Tran. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var timeLineView: TimelineView!
    private var availableRangeView: AvailableRangeView!
    
    var fullHeight: CGFloat {
        return timeLineView.fullHeight + 40 + 8
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        timeLineView.heightAnchor.constraint(equalToConstant: timeLineView.fullHeight).isActive = true
        
        // add range view
        if let availableRangeView = AvailableRangeView.create() {
            self.availableRangeView = availableRangeView
            availableRangeView.delegate = self
            availableRangeView.translatesAutoresizingMaskIntoConstraints = false
            timeLineView.addSubview(availableRangeView)
            NSLayoutConstraint.activate([
                availableRangeView.topAnchor.constraint(equalTo: timeLineView.topAnchor),
                availableRangeView.leftAnchor.constraint(equalTo: timeLineView.leftAnchor, constant: timeLineView.leftInset),
                availableRangeView.bottomAnchor.constraint(equalTo: timeLineView.bottomAnchor),
                availableRangeView.rightAnchor.constraint(equalTo: timeLineView.rightAnchor)
                ])
            
            availableRangeView.validY = timeLineView.validY
            availableRangeView.minimumRangeHeight = timeLineView.verticalDiff / 2
            availableRangeView.reDraw()
        }
    }

}

extension ViewController: AvailableRangeViewDelegate {
    func normalizeY(_ y: CGFloat) -> (CGFloat, Date) {
        return timeLineView.normalizeY(y)
    }
}

