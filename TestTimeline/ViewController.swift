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
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        timeLineView.heightAnchor.constraint(equalToConstant: timeLineView.fullHeight).isActive = true
        
        // add range view
        if let availableRangeView = AvailableRangeView.create() {
            availableRangeView.translatesAutoresizingMaskIntoConstraints = false
            timeLineView.addSubview(availableRangeView)
            NSLayoutConstraint.activate([
                availableRangeView.topAnchor.constraint(equalTo: timeLineView.topAnchor),
                availableRangeView.leftAnchor.constraint(equalTo: timeLineView.leftAnchor, constant: timeLineView.leftInset),
                availableRangeView.bottomAnchor.constraint(equalTo: timeLineView.bottomAnchor),
                availableRangeView.rightAnchor.constraint(equalTo: timeLineView.rightAnchor)
                ])
            
            availableRangeView.validY = timeLineView.validY
            availableRangeView.minimumRangeHeight = timeLineView.verticalDiff
            availableRangeView.reDraw()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

