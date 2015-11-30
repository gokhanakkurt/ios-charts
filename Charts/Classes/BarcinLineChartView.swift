//
//  BarcinLineChartView.swift
//  Charts
//
//  Created by Ali Bahşişoğlu on 30/11/15.
//  Copyright © 2015 dcg. All rights reserved.
//

import Foundation


public class BarcinLineChartView : LineChartView {
    
    internal override func initialize()
    {
        super.initialize()
        renderer = BarcinLineChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
    }
    
}