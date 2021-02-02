//
//  DateTimeFormatter.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 01/02/21.
//

import Foundation

protocol DateComponentsFormatterProtocol {
    var unitsStyle: DateComponentsFormatter.UnitsStyle { get set }
    var allowedUnits: NSCalendar.Unit { get set }
    func string(from ti: TimeInterval) -> String?
}

extension DateComponentsFormatter: DateComponentsFormatterProtocol { }
