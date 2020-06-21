//
//  Styles.swift
//  ABC Recorder
//
//  Created by Rocky Wei on 2020-06-21.
//  Copyright © 2020 Treefrog Inc. All rights reserved.
//

import UIKit

fileprivate extension Int {
	func hex(_ rightShift: Int = 0) -> Int {
		let hex = rightShift > 0 ? self >> rightShift : self
		return hex & 0xFF
	}
}

extension UIColor {
	convenience init(netHex: Int, alpha: CGFloat = 1.0) {
		let red = netHex.hex(16)
		let green = netHex.hex(8)
		let blue = netHex.hex()
		self.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: alpha)
	}
	static let darkblue = UIColor(netHex: 0x1B5996)
	static let pinkBackground = UIColor(netHex: 0xF2F0F1)
	static let pinkForeground = UIColor(netHex: 0xD9C0CF)
}
