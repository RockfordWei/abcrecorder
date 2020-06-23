//
//  Extensions.swift
//  ABC Recorder
//
//  Created by Rocky Wei on 2020-06-20.
//  Copyright © 2020 Treefrog Inc. All rights reserved.
//

import UIKit

class ABCRecord: NSObject, Codable {

	var id = UUID()
	var time_start = Date()
	var time_end = Date()
	var location = ""
	var precondition_client = ""
	var precondition_reporter = ""
	var client_behaviour = ""
	var client_saying = ""
	var reporter_action = ""
	var reporter_saying = ""

	static var header: String {
		let head: [String] = [
			"id", "start time", "end time", "Where were you and Client?",
			"What was he doing/saying before the behaviour?",
			"What were you doing/saying before the behaviour?",
			"What did he do?", "What did he say?",
			"What did you do?", "Waht did you say?"
		]
		return head.map { "\"\($0)\""}.joined(separator: ",")
	}
	var csv_row: String {
		return [
			id.uuidString, time_start.timestamp(), time_end.timestamp(), location,
			precondition_client,
			precondition_reporter,
			client_behaviour, client_saying,
			reporter_action, reporter_saying
		].map { "\"\($0)\""}.joined(separator: ",")
	}
	var html_row: String {
		let html =
		"""
		<tr>
			<td>
				<p>DATE: <u>\(time_start.simple())</u></p>
				<p>START TIME:<br/><u>\(time_start.timestamp())</u></p>
				<p>END TIME:<br/><u>\(time_end.timestamp())</u></p>
			</td>
			<td>
				<p><b>Where were you and Client?</b><br/>\(location)</p>
				<p><b>What was he doing/saying before the behaviour</b><br/>\(precondition_client)</p>
				<p><b>What were you doing/saying before the behaviour</b><br/>\(precondition_reporter)</p>
			</td>
			<td>
				<p><b>What did he do?</b><br/>\(client_behaviour)</p>
				<p><b>What did he say?</b><br/>\(client_saying)</p>
			</td>
			<td>
				<p><b>What did you do?</b><br/>\(reporter_action)</p>
				<p><b>What did you say?</b><br/>\(reporter_saying)</p>
			</td>
		</tr>
		"""
		return html
	}
}

extension UserDefaults {

	static var build: String {
		let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
		let num = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
		return "\(ver).\(num)"
	}
	
	private static let recordset = "abcrecordset"
	private static let encoder = JSONEncoder()
	private static let decoder = JSONDecoder()

	static let notification = Notification.Name(rawValue: "UserDefaultNotificationUpdate")
	static func delete(record: ABCRecord) -> Bool {
		let dayIndex = record.time_start.dayBegin()
		var rec = records
		guard let section = rec[dayIndex] else { return false }
		rec[dayIndex] = section.filter { $0.id != record.id }
		if rec[dayIndex]?.isEmpty ?? true {
			rec.removeValue(forKey: dayIndex)
		}
		records = rec
		return true
	}

	static func append(record: ABCRecord) {
		let dayIndex = record.time_start.dayBegin()
		let this = [record]
		var rec = records
		if let section = rec[dayIndex] {
			rec[dayIndex] = (this + section).sorted { $0.time_start > $1.time_start }
		} else {
			rec[dayIndex] = this
		}
		records = rec
	}
	static var records: [Date: [ABCRecord]] {
		get {
			do {
				guard let encoded = standard.data(forKey: recordset) else { return  [:] }
				return try decoder.decode([Date: [ABCRecord]].self, from: encoded)
			} catch (let error) {
				NSLog("unable to load recordset: \(error)")
				return [:]
			}
		}
		set {
			do {
				let encoded = try encoder.encode(newValue)
				standard.set(encoded, forKey: recordset)
			} catch (let error) {
				NSLog("unable to save recordset: \(error)")
			}
		}
	}
	static var dates: [Date] {
		return records.keys.map { $0 }.sorted { $0 > $1 }
	}
}

extension Date {
	func dayBegin() -> Date {
		let yy = Calendar.current.component(.year, from: self)
		let mm = Calendar.current.component(.month, from: self)
		let dd = Calendar.current.component(.day, from: self)
		let cc = DateComponents(calendar: Calendar.current, timeZone: .current,
														year: yy, month: mm, day: dd, hour: 0, minute: 0, second: 0)
		return Calendar.current.date(from: cc) ?? self
	}

	func ago() -> String {
		let interval = Date().timeIntervalSince(self)
		let text: String
		switch interval {
		case 0..<60:
			text = "Just now"
		case 60..<120:
			text = "A minute ago"
		case 120..<3600:
			text = String(format: "%d minutes ago", Int(interval / 60))
		case 3600..<7200:
			text = "An hour ago"
		case 7200..<86400:
			text = String(format: "%d hours ago", Int(interval / 3600))
		case 86400..<(86400 * 7):
			text = String(format: "%d days ago", Int(interval / 86400))
		default:
			text = self.simple()
		}
		return text
	}

	public func simple(includingYear: Bool = true) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = includingYear ? "MMM d, yyyy" : "MMM d"
		return formatter.string(from: self)
	}
	func timestamp() -> String {
		let fmt = DateFormatter()
		fmt.dateFormat = "yyyy-MM-dd HH:mm"
		return fmt.string(from: self)
	}
	init(timestamp: String? = nil) {
		let fmt = DateFormatter()
		fmt.dateFormat = "yyyy-MM-dd HH:mm"
		if let tm = timestamp {
			self = fmt.date(from: tm) ?? Date()
		} else {
			self = Date()
		}
	}
}

extension UIViewController {
	static func createLabel(_ content: String) -> UILabel {
		let text = UILabel()
		text.translatesAutoresizingMaskIntoConstraints = false
		text.text = content
		text.numberOfLines = 0
		return text
	}
	
	static func createTextField(placeholder: String? = nil, defaultValue: String? = nil) -> UITextField {
		let text = UITextField()
		text.translatesAutoresizingMaskIntoConstraints = false
		text.placeholder = placeholder
		text.text = defaultValue
		text.returnKeyType = .continue
		text.borderStyle = .roundedRect
		return text
	}
	func showAlert(alertText : String, alertMessage : String, cancellation: ((UIAlertAction) -> Void)? = nil, completion: ((UIAlertAction) -> Void)? = nil) {
		DispatchQueue.main.async {
			let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: completion))
			if let cancel = cancellation {
				alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: cancel))
			}
			self.present(alert, animated: true, completion: nil)
		}
	}
}

extension String {
	var nullable: String? {
		return self == "N/A" ? nil : self
	}
}
