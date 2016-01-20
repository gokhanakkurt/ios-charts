//
//  BarcinLineChartDataSet.swift
//  Charts
//
//  Created by Ali Bahşişoğlu on 30/11/15.
//  Copyright © 2015 dcg. All rights reserved.
//

import Foundation

public class BarcinLineChartDataSet : LineChartDataSet {
    
    public var tag : Int = 0
    
    public var gradientColors : CFArray = []
    
    public var highlightGradientColors : CFArray = []
    
    public var fillGradientEnabled = false
    
    public var highlightLineColor : UIColor?
    
    public var isFillGradientEnabled : Bool {
        return fillGradientEnabled
    }
}