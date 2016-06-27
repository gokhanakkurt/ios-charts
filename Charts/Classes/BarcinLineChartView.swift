//
//  BarcinLineChartView.swift
//  Charts
//
//  Created by Ali Bahşişoğlu on 30/11/15.
//  Copyright © 2015 dcg. All rights reserved.
//

import Foundation

@objc
public protocol BarcinChartViewDelegate : ChartViewDelegate
{
    optional func chartValueSelected(chartView: ChartViewBase, entries: [ChartDataEntry], dataSetIndexes: [Int], highlights: [ChartHighlight])
}

public class BarcinLineChartView : LineChartView {
    
    public var barcinDelegate: BarcinChartViewDelegate? {
        get { return self.delegate as? BarcinChartViewDelegate }
        set { self.delegate = newValue }
    }
    
    var hValues : NSMutableArray = []
    
    var totalTouches : Int = 0
    
    internal override func initialize()
    {
        super.initialize()
        
        self.multipleTouchEnabled = true
        
        renderer = BarcinLineChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        
        self.removeGestureRecognizer(_tapGestureRecognizer)
        self.removeGestureRecognizer(_panGestureRecognizer)
        self.removeGestureRecognizer(_doubleTapGestureRecognizer)
        self.removeGestureRecognizer(_pinchGestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("detectPan:"))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.cancelsTouchesInView = false
        panGestureRecognizer.delaysTouchesEnded = false
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    func detectPan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            _indicesToHighlight.removeAll()
            setNeedsDisplay()
            self.lastHighlighted = nil
            self.hValues = []
            delegate!.chartValueNothingSelected?(self)
        } else {
            if recognizer.numberOfTouches() == 1 {
                let h = getHighlightByTouchPoint(recognizer.locationInView(self))
                let lastHighlighted = self.lastHighlighted
                
                if ((h === nil && lastHighlighted !== nil) ||
                    (h !== nil && lastHighlighted === nil) ||
                    (h !== nil && lastHighlighted !== nil && !h!.isEqual(lastHighlighted)))
                {
                    self.lastHighlighted = h
                    self.highlightValue(highlight: h, callDelegate: true)
                }
            } else if recognizer.numberOfTouches() == 2 {
                self.hValues = []
                for i in 1...recognizer.numberOfTouches() {
                    let touch = recognizer.locationOfTouch(i-1, inView: self)
                    if touch.x < self.frame.width - 20 {
                        let chartH = getHighlightByTouchPoint(touch)! as ChartHighlight
                        self.hValues.addObject(chartH)
                        self.highlightValues(self.hValues as? [ChartHighlight], callDelegate: true)
                    }
                }
            } else {
                return;
            }
        }
        
    }
    
    public func highlightValues(highs: [ChartHighlight]?, callDelegate: Bool)
    {
        _indicesToHighlight = highs ?? [ChartHighlight]()
        
        if (_indicesToHighlight.isEmpty)
        {
            self.lastHighlighted = nil
        }
        else
        {
            self.lastHighlighted = _indicesToHighlight[0];
        }
        
        if (callDelegate && delegate != nil)
        {
            if (highs?.count == 0)
            {
                barcinDelegate!.chartValueNothingSelected?(self)
            }
            else
            {
                var barcinDataEntries:[ChartDataEntry] = []
                var barcinDataIndexes:[Int] = []
                for high in highs! {
                    barcinDataEntries.append(_data.getEntryForHighlight(high)!)
                    barcinDataIndexes.append(high.dataSetIndex)
                }
                barcinDelegate?.chartValueSelected!(self, entries: barcinDataEntries, dataSetIndexes: barcinDataIndexes, highlights: highs!)
            }
        }
        
        // redraw the chart
        setNeedsDisplay()
    }
        
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.hValues = []
        self.totalTouches = (event?.touchesForView(self)?.count)!
        if event?.touchesForView(self)?.count <= 2 {
            for touch in (event?.touchesForView(self))! {
                if let chartH = getHighlightByTouchPoint(touch.locationInView(self)){
                    self.hValues.addObject(chartH)
                }
            }
            
            let arr: [ChartHighlight] = self.hValues.flatMap({$0 as? ChartHighlight})
            self.highlightValues(arr, callDelegate: true)
        }
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.totalTouches -= touches.count
        for touch in touches {
            let chartH = getHighlightByTouchPoint(touch.locationInView(self))
            let arr : [ChartHighlight] = self.hValues.flatMap({$0 as? ChartHighlight})
            for hValue in arr {
                if hValue.xIndex == chartH?.xIndex {
                    self.hValues.removeObject(hValue)
                }
            }
            
            for indice in _indicesToHighlight {
                if indice.xIndex == chartH?.xIndex {
                    _indicesToHighlight.removeAtIndex(_indicesToHighlight.indexOf(indice)!)
                }
            }
            
            
        }
        if self.totalTouches > 0 {
            var barcinDataEntries:[ChartDataEntry] = []
            var barcinDataIndexes:[Int] = []
            for high in _indicesToHighlight {
                barcinDataEntries.append(_data.getEntryForHighlight(high)!)
                barcinDataIndexes.append(high.dataSetIndex)
            }
            barcinDelegate?.chartValueSelected!(self, entries: barcinDataEntries, dataSetIndexes: barcinDataIndexes, highlights: _indicesToHighlight)
        } else {
            self.lastHighlighted = nil
            delegate!.chartValueNothingSelected?(self)
        }
        setNeedsDisplay()
    }
    
}