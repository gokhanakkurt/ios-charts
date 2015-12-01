//
//  BarcinLineChartRenderer.swift
//  Charts
//
//  Created by Ali Bahşişoğlu on 30/11/15.
//  Copyright © 2015 dcg. All rights reserved.
//

import Foundation


public class BarcinLineChartRenderer : LineChartRenderer {
    
    internal override func drawLinearFill(context context: CGContext, dataSet: LineChartDataSet, entries: [ChartDataEntry], minx: Int, maxx: Int, trans: ChartTransformer)
    {
        guard let dataProvider = dataProvider else { return }
        
        CGContextSaveGState(context)
        
        let filled = super.generateFilledPath(
            entries,
            fillMin: dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0,
            from: minx,
            to: maxx,
            matrix: trans.valueToPixelMatrix)
        
        let set = dataSet as? BarcinLineChartDataSet
        
        if set?.isFillGradientEnabled == true {
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colorLocations:[CGFloat] = [0.4, 1.0]
            let gradient = CGGradientCreateWithColors(colorSpace, set?.gradientColors, colorLocations)
            
            CGContextSetAlpha(context, CGFloat(0.33))
            CGContextBeginPath(context)
            CGContextAddPath(context, filled)
            CGContextClip(context)
            CGContextDrawLinearGradient(context, gradient, CGPoint.zero, CGPoint(x: 0, y: viewPortHandler.chartHeight*1.3), CGGradientDrawingOptions.DrawsAfterEndLocation)
            
        } else {
            CGContextSetFillColorWithColor(context, dataSet.fillColor.CGColor)
            
            // filled is usually drawn with less alpha
            CGContextSetAlpha(context, dataSet.fillAlpha)
            CGContextBeginPath(context)
            CGContextAddPath(context, filled)
            CGContextFillPath(context)
        }
        
        CGContextRestoreGState(context)
    }
    
    private var _highlightPointBuffer = CGPoint()
    private var _lineSegments = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func drawHighlighted(context context: CGContext, indices: [ChartHighlight])
    {
        guard let lineData = dataProvider?.lineData, chartXMax = dataProvider?.chartXMax else { return }
        CGContextSaveGState(context)
        let set = lineData._dataSets.first as! BarcinLineChartDataSet
        let trans = dataProvider?.getTransformer(set.axisDependency)
        var minx = 9999
        var maxx = 0
        for (var i = 0; i < indices.count; i++) {
            if !set.isHighlightEnabled { continue }
            
            let xIndex = indices[i].xIndex;
            
            if xIndex < minx {
                minx = xIndex
            }
            
            if xIndex > maxx {
                maxx = xIndex
            }
            
            if (CGFloat(xIndex) > CGFloat(chartXMax) * _animator.phaseX) { continue }
            
            let yValue = set.yValForXIndex(xIndex)
            if (yValue.isNaN) { continue }
            
            let y = CGFloat(yValue) * _animator.phaseY; // get the y-position
            
            _highlightPointBuffer.x = CGFloat(xIndex)
            _highlightPointBuffer.y = y
            
            trans?.pointValueToPixel(&_highlightPointBuffer)
            
            CGContextSetStrokeColorWithColor(context, set.highlightColor.CGColor)
            CGContextSetLineWidth(context, set.highlightLineWidth)
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, _highlightPointBuffer.x, viewPortHandler.contentTop)
            CGContextAddLineToPoint(context, _highlightPointBuffer.x, viewPortHandler.contentBottom)
            CGContextStrokePath(context)
        }
        
        let entries = set.yVals
        
        if indices.count > 1 {
            var e1: ChartDataEntry!
            var e2: ChartDataEntry!
            
            if (_lineSegments.count != max((entries.count - 1) * 2, 2))
            {
                _lineSegments = [CGPoint](count: max((entries.count - 1) * 2, 2), repeatedValue: CGPoint())
            }
            
            let phaseX = _animator.phaseX
            let phaseY = _animator.phaseY
            let valueToPixelMatrix = trans!.valueToPixelMatrix
            
            e1 = entries[minx]
            
            let count = Int(ceil(CGFloat(maxx + 1 - minx) * phaseX + CGFloat(minx)))
            
            for (var x = count > 1 ? minx + 1 : minx, j = 0; x < count; x++)
            {
                e1 = entries[x == 0 ? 0 : (x - 1)]
                e2 = entries[x]
                
                _lineSegments[j++] = CGPointApplyAffineTransform(CGPoint(x: CGFloat(e1.xIndex), y: CGFloat(e1.value) * phaseY), valueToPixelMatrix)
                _lineSegments[j++] = CGPointApplyAffineTransform(CGPoint(x: CGFloat(e2.xIndex), y: CGFloat(e2.value) * phaseY), valueToPixelMatrix)
            }
            
            let size = max((count - minx - 1) * 2, 2)
            CGContextSetStrokeColorWithColor(context, set.highlightLineColor!.CGColor )
            CGContextStrokeLineSegments(context, _lineSegments, size)
        }
        
        let filled = super.generateFilledPath(
            entries,
            fillMin: set.fillFormatter?.getFillLinePosition(dataSet: set, dataProvider: dataProvider!) ?? 0.0,
            from: minx,
            to: maxx+1,
            matrix: trans!.valueToPixelMatrix)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.4, 1.0]
        let gradient = CGGradientCreateWithColors(colorSpace, set.highlightGradientColors, colorLocations)
        CGContextSetAlpha(context, CGFloat(0.8))
        CGContextBeginPath(context)
        CGContextAddPath(context, filled)
        CGContextClip(context)
        CGContextDrawLinearGradient(context, gradient, CGPoint.zero, CGPoint(x: 0, y: viewPortHandler.chartHeight*1.3), CGGradientDrawingOptions.DrawsAfterEndLocation)
        
        CGContextRestoreGState(context)
    }
    
    /*private func createRect(context context: CGContext, str:String, point:CGPoint) {
    UIColor.yellowColor().setFill()
    let path:UIBezierPath = UIBezierPath(roundedRect: CGRectMake(point.x, point.y, 100, 50), cornerRadius: 10)
    path.fill()
    } */
    
}