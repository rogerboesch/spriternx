
import Foundation
import AppKit

protocol RBValueRulerDelegate {
    func dialValueDidChange(value newValue: Float)
}

class RBValueRuler: NSScrollView {
    
    // -------------------------------------------------------------------------
    // MARK: - Properties

    var delegate: RBValueRulerDelegate?
    
    private var visibleUnits = Array<RBValueRulerUnit>()
    private var unitContainerView: NSView!
    private var minValue: Int!
    private var maxValue: Int!
    private var initialValue: Float = 0
    private var driftLock: Bool = false
    
    // -------------------------------------------------------------------------
    // MARK: - Set values

    func setCurrentValue(value newValue: Float) {
        setDialValue(value: newValue)
    }

    func setMinValue(value newValue: Int) {
        if newValue < maxValue {
            self.minValue = newValue
            
            if self.valueInCenter() > Float(newValue) {
                self.setDialValue(value: self.valueInCenter())
            }
            else {
                self.setDialValue(value: Float(newValue))
            }
        }
    }

    func setMaxValue(value newValue: Int) {
        if newValue > minValue {
            self.maxValue = newValue
            
            if self.valueInCenter() < Float(newValue) {
                self.setDialValue(value: self.valueInCenter())
            }
            else {
                self.setDialValue(value: Float(newValue))
            }
        }
    }

    private func setDialValue(value newValue: Float) {
        if self.driftLock {
            return
        }
        
        if self.visibleUnits.count > 0 {
            let balanceToCenter = (self.frame.size.width / 2) / self.visibleUnits.first!.frame.size.width
            
            if newValue <= Float(CGFloat(self.maxValue) - balanceToCenter) && newValue >= Float(CGFloat(self.minValue) + balanceToCenter) {
                let contentWidth = self.unitContainerView.frame.size.width
                let centerOffsetX: CGFloat = (contentWidth - self.bounds.size.width) / 2.0;
                let valueInLeftEdge = CGFloat(newValue) - balanceToCenter + 0.5
                let valueForFirstUnit = Int(floor(valueInLeftEdge))
                let firstUnitOffsetMultiplier = valueInLeftEdge - CGFloat(valueForFirstUnit)
                
                let firstUnitPixelInterval = self.visibleUnits.first!.frame.size.width * firstUnitOffsetMultiplier
                
                DispatchQueue.main.async(execute: {
                    self.documentView!.scroll(NSMakePoint(centerOffsetX, 0))
                    self.visibleUnits.removeAll(keepingCapacity: true)
                    self.unitContainerView.subviews.removeAll(keepingCapacity: true)
                    let unit = self.insertUnit(valueForFirstUnit)
                    self.visibleUnits.append(unit)
                    var frame: CGRect = unit.frame
                    frame.origin.x = self.documentVisibleRect.minX - firstUnitPixelInterval
                    frame.origin.y = 0
                    unit.frame = frame
                    self.boundsDidChange()
                })
            }
            else if newValue > Float(CGFloat(self.maxValue) - balanceToCenter) && newValue <= Float(self.maxValue) {
                let valueInLeftEdge = CGFloat(newValue) - balanceToCenter;
                let firstUnitValue = floor(valueInLeftEdge)
                let firstUnitOriginX = self.unitContainerView.frame.size.width - ((CGFloat(self.maxValue) + balanceToCenter) - firstUnitValue + 0.5) * self.visibleUnits.first!.frame.size.width
                let offsetToLeftEdge = ( valueInLeftEdge - firstUnitValue + 0.5 ) * self.visibleUnits.first!.frame.size.width
                
                DispatchQueue.main.async(execute: {
                    self.driftLock = true
                    self.documentView!.scroll(NSMakePoint(round(firstUnitOriginX + offsetToLeftEdge), 0))
                    
                    self.visibleUnits.removeAll(keepingCapacity: true)
                    self.unitContainerView.subviews.removeAll(keepingCapacity: true)
                    
                    let unit = self.insertUnit(Int(firstUnitValue))
                    
                    self.visibleUnits.append(unit)
                    var frame: CGRect = unit.frame
                    
                    frame.origin.x = round(firstUnitOriginX)
                    frame.origin.y = 0
                    unit.frame = frame
                    
                    self.defineUnits()
                    self.driftLock = false
                    
                    self.boundsDidChange()
                })
            }
            else if newValue < Float(CGFloat(self.maxValue) + balanceToCenter) && newValue >= Float(self.minValue) {
                let valueInLeftEdge = CGFloat(newValue) - balanceToCenter
                let valueInBeggining = CGFloat(self.minValue) - balanceToCenter
                let firstUnitValue = floor(valueInLeftEdge + 0.5)
                let documentFirstValue = floor(valueInBeggining + 0.5)
                let documentFirstValueOriginX = 0 - ( self.visibleUnits.first!.frame.size.width - ( ( 0.5 - ( valueInBeggining - documentFirstValue ) ) * self.visibleUnits.first!.frame.size.width) )
                let documentOffsetPixels = round(( valueInLeftEdge - valueInBeggining ) * self.visibleUnits.first!.frame.size.width)
                
                var firstUnitValueOriginX: CGFloat!
                
                if firstUnitValue > documentFirstValue {
                    firstUnitValueOriginX = (( firstUnitValue - documentFirstValue ) * self.visibleUnits.first!.frame.size.width) + documentFirstValueOriginX
                }
                else {
                    firstUnitValueOriginX = documentFirstValueOriginX
                }
                
                DispatchQueue.main.async(execute: {
                    self.driftLock = true
                    self.documentView!.scroll(NSMakePoint(documentOffsetPixels, 0))
                    
                    self.visibleUnits.removeAll(keepingCapacity: true)
                    self.unitContainerView.subviews.removeAll(keepingCapacity: true)
                    
                    let unit = self.insertUnit(Int(firstUnitValue))
                    
                    self.visibleUnits.append(unit)
                    var frame: CGRect = unit.frame
                    
                    frame.origin.x = round(firstUnitValueOriginX)
                    frame.origin.y = 0
                    unit.frame = frame
                    
                    self.defineUnits()
                    self.driftLock = false
                    
                    self.boundsDidChange()
                })
            }
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Notification

    @objc func boundsDidChange() {
        if self.driftLock {
            return
        }
        
        if self.visibleUnits.count > 0 {
            let firstUnit = self.visibleUnits.first
            let lastUnit = self.visibleUnits.last

            if firstUnit!.value > self.minValue && lastUnit!.value < self.maxValue {
                self.driftContentToCenter()
            }
            
            if lastUnit!.value >= self.maxValue {
                self.driftContentToEnd()
            }
            
            if firstUnit!.value <= self.minValue {
                self.driftContentToBeginning()
            }
            
            // Send current center value to delegate
            self.delegate?.dialValueDidChange(value: self.valueInCenter())
        }
        
        self.defineUnits()
    }

    // -------------------------------------------------------------------------
    // MARK: - Drift content

    private func driftContentToCenter() {
        if self.driftLock {
            return
        }
        
        let contentWidth = self.unitContainerView.frame.size.width
        let centerOffsetX: CGFloat = (contentWidth - self.bounds.size.width) / 2.0;

        if documentVisibleRect.midX < contentWidth * 0.25 || documentVisibleRect.midX > contentWidth * 0.75 {
            let driftOffset = centerOffsetX - self.contentView.bounds.origin.x
            self.driftLock = true;
            self.documentView!.scroll(NSMakePoint(centerOffsetX, 0))
            for unit in self.visibleUnits {
                unit.frame.origin.x += driftOffset
            }
            self.driftLock = false
        }
    }

    private func driftContentToBeginning() {
        if self.driftLock {
            return
        }
        
        let firstUnit = self.visibleUnits.first
        
        _ = self.unitContainerView.frame.size.width
        let balanceToCenter = (self.frame.size.width / 2) / self.visibleUnits.first!.frame.size.width - 0.5
        let pixelsIntervalToCenter = firstUnit!.frame.size.width * balanceToCenter

        if firstUnit!.frame.origin.x > 0 + pixelsIntervalToCenter {
            self.driftLock = true
            
            DispatchQueue.main.async(execute: {
                self.documentView!.scroll(NSMakePoint(self.documentVisibleRect.minX - firstUnit!.frame.minX + pixelsIntervalToCenter, 0))
                var i: Int = 0
                
                for unit in self.visibleUnits {
                    let originX: CGFloat = CGFloat(i) * unit.frame.size.width
                    unit.frame.origin.x = originX + pixelsIntervalToCenter
                    unit.value = self.minValue + i
                    i += 1
                }
                
                self.driftLock = false
            })
        }
    }

    private func driftContentToEnd() {
        if self.driftLock == true {
            return
        }
        
        let lastUnit = self.visibleUnits.last
        let contentWidth = self.unitContainerView.frame.size.width
        let balanceToCenter = (self.frame.size.width / 2) / self.visibleUnits.first!.frame.size.width - 0.5
        let pixelsIntervalToCenter = lastUnit!.frame.size.width * balanceToCenter
        
        if lastUnit!.frame.origin.x < ( contentWidth - lastUnit!.frame.size.width) - pixelsIntervalToCenter {
            self.driftLock = true
            
            DispatchQueue.main.async(execute: {
                self.documentView!.scroll(NSMakePoint(( contentWidth + (self.documentVisibleRect.maxX - lastUnit!.frame.maxX) ) - self.frame.size.width - pixelsIntervalToCenter, 0))
                var i: Int = 0
                
                for unit in self.visibleUnits {
                    let originX: CGFloat = contentWidth - ( CGFloat(self.visibleUnits.count) * unit.frame.size.width) + (CGFloat(i) * unit.frame.size.width)
                    unit.frame.origin.x = originX - pixelsIntervalToCenter
                    unit.value = ( self.maxValue - self.visibleUnits.count ) + i + 1
                    i += 1
                }
                
                self.driftLock = false
            })
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Place unit views
    
    private func insertUnit(_ value: Int) -> RBValueRulerUnit {
        let unit: RBValueRulerUnit = RBValueRulerUnit(frame: CGRect(x: 0, y: 0, width: 200, height: self.unitContainerView.frame.height))
        unit.value = value
        
        self.unitContainerView.addSubview(unit)
        return unit
    }

    private  func placeNewUnitOnRight(_ rightEdge: CGFloat) -> CGFloat {
        let previousUnit = self.visibleUnits.last
        var newUnitValue: Int!
        
        if previousUnit != nil {
            newUnitValue = previousUnit!.value + 1
        }
        else {
            newUnitValue = 0;
        }
        
        let unit = self.insertUnit(newUnitValue)
        self.visibleUnits.append(unit)
        
        var frame: CGRect = unit.frame
        frame.origin.x = rightEdge
        frame.origin.y = 0
        unit.frame = frame
        
        return frame.maxX
    }

    private func placeNewUnitOnLeft(_ leftEdge: CGFloat) -> CGFloat {
        let nextUnit = self.visibleUnits.first
        let unit = self.insertUnit(nextUnit!.value - 1)
        
        self.visibleUnits.insert(unit, at: 0)
        
        var frame: CGRect = unit.frame
        frame.origin.x = leftEdge - frame.size.width
        frame.origin.y = 0
        unit.frame = frame
        
        return frame.minX
    }

    private func defineUnits() {
        if self.visibleUnits.count == 0 {
            _ = self.placeNewUnitOnRight(documentVisibleRect.minX)
            self.setDialValue(value: self.initialValue)
        }
        
        // Add units that are missing on right side
        var lastUnit = self.visibleUnits.last
        var rightEdge: CGFloat = lastUnit!.frame.maxX
        while rightEdge < documentVisibleRect.maxX {
            rightEdge = self.placeNewUnitOnRight(rightEdge)
        }
        
        // Add units that are missing on left side
        var firstUnit = self.visibleUnits.first
        var leftEdge: CGFloat = firstUnit!.frame.minX
        while leftEdge > documentVisibleRect.minX {
            leftEdge = self.placeNewUnitOnLeft(leftEdge)
        }
        
        // Remove units that have fallen off right edge
        lastUnit = self.visibleUnits.last
        while lastUnit!.frame.origin.x > documentVisibleRect.maxX {
            lastUnit?.removeFromSuperview()
            self.visibleUnits.removeLast()
            lastUnit = self.visibleUnits.last
        }
        
        // Remove units that have fallen off left edge
        firstUnit = self.visibleUnits.first;
        while firstUnit!.frame.maxX < documentVisibleRect.minX {
            firstUnit!.removeFromSuperview()
            self.visibleUnits.remove(at: 0)
            firstUnit = self.visibleUnits[0]
        }
    }
    
    private func valueInCenter() -> Float {
        let firstUnit = self.visibleUnits.first
        let value: CGFloat = CGFloat(firstUnit!.value)
        
        // value in px of first unit interval from left edge
        let firstUnitPixelInterval = documentVisibleRect.minX - firstUnit!.frame.minX
        
        // Metric float value of first item from left edge from 0 to 1
        let firstUnitFloatInterval = firstUnitPixelInterval / firstUnit!.frame.size.width

        // Metric value from left edge to center of scrollview
        let balanceToCenter = (self.frame.size.width / 2) / firstUnit!.frame.size.width
        
        // Final value is value + firstUnitFloatInterval + balanceToCenter - 0.5 because the center of number in center of unit
        let finalValue = value + firstUnitFloatInterval + balanceToCenter - 0.5

        return Float(finalValue)
    }

    // -------------------------------------------------------------------------
    // MARK: - Scrolling
    
    private func scrollToPointX(X x: CGFloat) {
        self.documentView!.scroll(NSMakePoint(x, 0))
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Initializers
    
    private func commonInit() {
        self.wantsLayer = true
        
        // Container view create
        self.unitContainerView = NSView(frame: CGRect(x: 0, y: 0, width: 4000, height: self.frame.height))
        self.unitContainerView.wantsLayer = true
        
        // Limits
        self.minValue = -1000
        self.maxValue = 1000
        self.setDialValue(value: 0)
        self.scrollsDynamically = false
        
        // Set elasticities
        self.verticalScrollElasticity = .none
        self.horizontalScrollElasticity = .allowed
        
        // Set background color behind dial
        self.backgroundColor = NSColor.white
        
        // Set the container view as documentView
        self.documentView = self.unitContainerView
        
        // Initialize units
        self.defineUnits()
        
        // Set continuously notification
        self.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(RBValueRuler.boundsDidChange), name: NSView.boundsDidChangeNotification, object: nil)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

}
