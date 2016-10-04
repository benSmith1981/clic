//
//  Extensions.swift
//  Clickey
//
//  Created by Sem Shafiq on 10/08/15.
//  Copyright © 2015 Clickey. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import MapKit

// Swift 2
struct ExponentialMovingAverage {
    var currentValue: Double
    let smoothing: Double
    
    init(initialValue: Double = 0, smoothing: Double = 0.5) {
        self.currentValue = initialValue
        self.smoothing = smoothing
    }
    
    mutating func update(next: Double) -> Double {
        currentValue = smoothing * next + (1 - smoothing) * currentValue
        return currentValue
    }
}

extension ExponentialMovingAverage: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String { return "average = \(currentValue)" }
    var debugDescription: String { return "<ExponentialMovingAverage smoothnig = \(smoothing), currentValue = \(currentValue)" }
}

extension ExponentialMovingAverage: Equatable {}
func ==(lhs: ExponentialMovingAverage, rhs: ExponentialMovingAverage) -> Bool {
    return lhs.smoothing == rhs.smoothing && lhs.currentValue == rhs.currentValue
}

extension Dictionary where Value : Equatable {
    func allKeysForValue(val : Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}

enum DateFormat: String {
    case Time = "hh:mm"
    case ShortDate = "dd-MM-yy"
    case LongDate = "dd MMMM YYYY"
    case Server = "yyyy-MM-dd'T'HH:mm:ssZ"

    static private var timeFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = DateFormat.Time.rawValue
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter
    }()

    static private var shortDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = DateFormat.ShortDate.rawValue
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter
    }()

    static private var longDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = DateFormat.LongDate.rawValue
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter
    }()

    static private var serverFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = DateFormat.Server.rawValue
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter
    }()

    private var dateFormatter: NSDateFormatter {
        switch self {
        case .Time:         return DateFormat.timeFormatter
        case .ShortDate:    return DateFormat.shortDateFormatter
        case .LongDate:     return DateFormat.longDateFormatter
        case .Server:       return DateFormat.serverFormatter
        }
    }
}

extension NSDate {
    class func fromClickeyServer(string: String) -> NSDate? {
        return DateFormat.Server.dateFormatter.dateFromString(string)
    }

    func presentedAs(format: DateFormat) -> String {
        return format.dateFormatter.stringFromDate(self)
    }
    
    func addMonth(month:Int) -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.month = month
        let calendar = NSCalendar.currentCalendar()
        let newDate = calendar.dateByAddingComponents(dateComponents, toDate: self, options: NSCalendarOptions.init(rawValue: 0))
        return newDate!
    }
    
}

extension UIResponder {
    // Swift 1.2 finally supports static vars!. If you use 1.1 see:
    // http://stackoverflow.com/a/24924535/385979
    private weak static var _currentFirstResponder: UIResponder? = nil
    
    public class func currentFirstResponder() -> UIResponder? {
        UIResponder._currentFirstResponder = nil
        UIApplication.sharedApplication().sendAction("findFirstResponder:", to: nil, from: nil, forEvent: nil)
        return UIResponder._currentFirstResponder
    }
    
    internal func findFirstResponder(sender: AnyObject) {
        UIResponder._currentFirstResponder = self
    }
}

protocol RawRepresentable {
    typealias Raw
    static func fromRaw(raw: Raw) -> Self?
    func toRaw() -> Raw
}

public func arc4random <T: IntegerLiteralConvertible> (type: T.Type) -> T {
    var r: T = 0
    arc4random_buf(&r, sizeof(T))
    return r
}
public extension Int {
    /**
    Create a random num Int
    :param: lower number Int
    :param: upper number Int
    :return: random number Int
    By DaRkDOG
    */
    public static func random (lower: Int , upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}

extension CLLocationCoordinate2D: Equatable{}
public func ==(first:CLLocationCoordinate2D, second:CLLocationCoordinate2D) -> Bool {
    return first.latitude == second.latitude && first.longitude == second.longitude
}