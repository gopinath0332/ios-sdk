//
//  UIKitDynamicsAnimation.swift
//  Swift Examples
//
//  Copyright (c) 2014 Telerik. All rights reserved.
//

import Foundation
import QuartzCore

class UIKitDynamicsAnimation: TKExamplesExampleViewController, TKChartDelegate
{
    let chart = TKChart()
    var animator:UIDynamicAnimator?
    var points = [TKChartDataPoint]()
    var selectedPoint:TKChartVisualPoint?
    var originalLocation = CGPoint.zero
    var originalPosition = CGPoint.zero
    var location = CGPoint.zero
    var originalValues = [CGPoint]()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.addOption("Apply Gravity", action: applyGravity)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chart.frame = self.view.bounds
        chart.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.FlexibleWidth.rawValue | UIViewAutoresizing.FlexibleHeight.rawValue)
        chart.allowAnimations = true
        chart.delegate = self
        self.view.addSubview(chart)
        
        reloadChart()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let points = chart.visualPointsForSeries(chart.series[0]) {
        
            for point in points {
                originalValues.append(point.CGPoint)
            }
            
            let point = points[4]
            
            location = point.center
            
            let snap = UISnapBehavior(item: point, snapToPoint: point.center)
            snap.damping = 0.2
            
            let push = UIPushBehavior(items:[point], mode:UIPushBehaviorMode.Instantaneous)
            push.pushDirection = CGVectorMake(0, -1)
            push.magnitude = 0.003
            
            let animator = UIDynamicAnimator()
            animator.addBehavior(snap)
            animator.addBehavior(push)
            
            point.animator = animator
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Methods
    
    func applyGravity() {
        // >> chart-anim-gravity-swift
        animator = UIDynamicAnimator(referenceView: chart.plotView)
        if let points = chart.visualPointsForSeries(chart.series[0]) {

            var i = 0
            for point in points {
                if let animator = point.animator {
                    animator.removeAllBehaviors()
                }
                point.animator = nil
                if i < originalValues.count {
                    point.center = originalValues[i]
                }
                i+=1
            }
            
            let collision = UICollisionBehavior(items: points)
            collision.translatesReferenceBoundsIntoBoundary = true
            
            let gravity = UIGravityBehavior(items: points)
            gravity.gravityDirection = CGVectorMake(0, 2)
            
            let dynamic = UIDynamicItemBehavior(items: points)
            dynamic.elasticity = 0.5
            
            animator!.addBehavior(dynamic)
            animator!.addBehavior(gravity)
            animator!.addBehavior(collision)
            // << chart-anim-gravity-swift
        }
    }
    
    func reloadChart() {
        points = [TKChartDataPoint]()
        for i in 0..<10 {
            let x = CGFloat(i*10)
            let y = CGFloat(Int(arc4random() % 100))
            points.append(TKChartDataPoint(x: x, y: y))
        }
        let lineSeries = TKChartLineSeries(items: points)
        let shapeSize = CGFloat(UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 14 : 17)
        lineSeries.selection = TKChartSeriesSelection.DataPoint
        lineSeries.style.pointShape = TKPredefinedShape(type: TKShapeType.Rhombus, andSize: CGSizeMake(shapeSize, shapeSize))
        lineSeries.style.shapeMode = TKChartSeriesStyleShapeMode.AlwaysShow
        chart.addSeries(lineSeries)
        chart.yAxis!.style.labelStyle.textHidden = true
        
        chart.reloadData()
    }
    
    //MARK: - TKChartDelegate
    
    func chart(chart: TKChart, animationForSeries series: TKChartSeries, withState state: TKChartSeriesRenderState, inRect rect: CGRect) -> CAAnimation? {
        return nil
    }
    
    //MARK: - Events
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)

        let touch: UITouch = touches.first as UITouch!
        let touchPoint = touch.locationInView(chart.plotView)
        if let hitTestInfo = chart.hitTestForPoint(touchPoint) {
            selectedPoint = chart.visualPointForSeries(hitTestInfo.series!, dataPointIndex: hitTestInfo.dataPointIndex)
            originalLocation = touchPoint
            if let point = selectedPoint  {
                point.animator = nil
                originalPosition = point.center
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
    
        let touch:UITouch = touches.first as UITouch!
        let touchPoint = touch.locationInView(chart.plotView)
        let delta = CGPointMake((originalPosition.x) - (touchPoint.x), originalLocation.y - touchPoint.y)
        if let point = selectedPoint {
            point.center = CGPointMake(originalPosition.x, originalPosition.y - delta.y)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)

        if let point = selectedPoint {
            let touch:UITouch = touches.first as UITouch!
            let touchPoint = touch.locationInView(chart.plotView)
            let delta = CGPointMake(originalLocation.x, originalLocation.y - touchPoint.y)
            
            let snap = UISnapBehavior(item: selectedPoint!, snapToPoint: originalPosition)
            snap.damping = 0.2
            
            let push = UIPushBehavior(items: [selectedPoint!], mode: UIPushBehaviorMode.Instantaneous)
            push.pushDirection = CGVectorMake(0, delta.y > 0 ? -1 : -1)
            push.magnitude = 0.001
            
            let animator = UIDynamicAnimator()
            animator.addBehavior(snap)
            animator.addBehavior(push)
            
            point.animator = animator
        }
    }
}
