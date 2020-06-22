//
//  FormViewController.swift
//  ABC Recorder
//
//  Created by Rocky Wei on 2020-06-20.
//  Copyright © 2020 Treefrog Inc. All rights reserved.
//

import UIKit

class FormViewController: UIViewController {

	private let panel: UIScrollView = {
		let v = UIScrollView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.showsVerticalScrollIndicator = true
		v.showsHorizontalScrollIndicator = false
		v.backgroundColor = .clear
		v.contentSize = CGSize(width: UIScreen.main.bounds.width - 32.0, height: UIScreen.main.bounds.height * 2)
		return v
	}()

	private let datePicker: UIDatePicker = {
		let picker = UIDatePicker()
		picker.datePickerMode = .dateAndTime
		picker.minuteInterval = 5
		let timespan: TimeInterval = 180 * 86400
		picker.minimumDate = Date(timeIntervalSinceNow: -1 * timespan)
		picker.maximumDate = Date(timeIntervalSinceNow: timespan)
		return picker
	}()

	private let sectionDateTime = UIViewController.createLabel("DATE/TIME")
	private let fieldStart = UIViewController.createTextField(placeholder: "START TIME")
	private let fieldStop = UIViewController.createTextField(placeholder: "END TIME")
	private let sectionCondition = UIViewController.createLabel("PRE-CONDITION OR ANTECEDENT\n(What happened before the behaviour)")
	private let fieldLocation = UIViewController.createTextField(placeholder: "Where were you and Client")
	private let fieldClientBefore = UIViewController.createTextField(placeholder: "What was he/she doing/saying before the behaviour")
	private let fieldReporterBefore = UIViewController.createTextField(placeholder: "What were you doing/saying before the behaviour")
	private let sectionHappen = UIViewController.createLabel("WHAT BEHAVIOUR OCCURRED AND A\nDESCRIPTION OF WHAT YOU SAW & HEARD")
	private let fieldDoing = UIViewController.createTextField(placeholder: "What did he/she do?")
	private let fieldSaying = UIViewController.createTextField(placeholder: "What did he/she say?")
	private let sectionResponse = UIViewController.createLabel("YOUR ACTIONS OR CONSEQUENSES\n(describe what you did and for how long)")
	private let fieldAction = UIViewController.createTextField(placeholder: "What did you do?")
	private let fieldResponse = UIViewController.createTextField(placeholder: "What did you say?")
	private var chain: [Int: UIView] = [:]
	private var currentActiveTextField: UITextField? = nil

	private let buttonAdd: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .darkblue
		button.titleLabel?.textColor = .white
		return button
	}()

	private func dig(upper: UIView? = nil, lower: UIView) {
		panel.addSubview(lower)
		if let u = upper {
			lower.topAnchor.constraint(equalTo: u.bottomAnchor, constant: 16).isActive = true
		} else {
			lower.topAnchor.constraint(equalTo: panel.topAnchor, constant: 16).isActive = true
		}
		lower.heightAnchor.constraint(equalToConstant: 48).isActive = true
		lower.centerXAnchor.constraint(equalTo: panel.centerXAnchor).isActive = true
		lower.widthAnchor.constraint(equalTo: panel.widthAnchor).isActive = true
		if let text = lower as? UITextField {
			text.delegate = self
			text.returnKeyType = .continue
			text.font = UIFont.systemFont(ofSize: 15, weight: .regular)
		} else if let label = lower as? UILabel {
			label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
		}
	}

	var record: ABCRecord? = nil

	@objc func onClickInputDone(_ sender: UIBarButtonItem) {
		if let active = currentActiveTextField {
			active.text = datePicker.date.timestamp()
			_ = active.resignFirstResponder()
			if let next = chain[active.hashValue] {
				_ = next.becomeFirstResponder()
			}
		}
	}

	@objc func onClickButtonAdd(_ sender: Any) {
		var rec: ABCRecord
		if let existing = record {
			rec = existing
			_ = UserDefaults.delete(record: existing)
		} else {
			rec = ABCRecord()
		}
		let adate = Date(timestamp: fieldStart.text)
		let bdate = Date(timestamp: fieldStop.text)
		rec.time_start = min(adate, bdate)
		rec.time_end = max(adate, bdate)
		rec.location = fieldLocation.text ?? "N/A"
		rec.precondition_client = fieldClientBefore.text ?? "N/A"
		rec.precondition_reporter = fieldReporterBefore.text ?? "N/A"
		rec.client_behaviour = fieldDoing.text ?? "N/A"
		rec.client_saying = fieldSaying.text ?? "N/A"
		rec.reporter_action = fieldAction.text ?? "N/A"
		rec.reporter_saying = fieldResponse.text ?? "N/A"
		UserDefaults.append(record: rec)
		NotificationCenter.default.post(name: UserDefaults.notification, object: rec)
		navigationController?.popViewController(animated: true)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .pinkBackground
		navigationItem.title = record == nil ? "Add New Record" : "Edit Record"
		view.addSubview(panel)
		panel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		panel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32.0).isActive = true
		panel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		panel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

		let inputBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48))
		inputBar.items = [
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onClickInputDone(_:)))
		]

		fieldStart.inputView = datePicker
		fieldStart.inputAccessoryView = inputBar
		fieldStop.inputView = datePicker
		fieldStop.inputAccessoryView = inputBar
		dig(lower: sectionDateTime)
		dig(upper: sectionDateTime, lower: fieldStart)
		dig(upper: fieldStart, lower: fieldStop)
		dig(upper: fieldStop, lower: sectionCondition)
		dig(upper: sectionCondition, lower: fieldLocation)
		dig(upper: fieldLocation, lower: fieldClientBefore)
		dig(upper: fieldClientBefore, lower: fieldReporterBefore)
		dig(upper: fieldReporterBefore, lower: sectionHappen)
		dig(upper: sectionHappen, lower: fieldDoing)
		dig(upper: fieldDoing, lower: fieldSaying)
		dig(upper: fieldSaying, lower: sectionResponse)
		dig(upper: sectionResponse, lower: fieldAction)
		dig(upper: fieldAction, lower: fieldResponse)
		dig(upper: fieldResponse, lower: buttonAdd)

		chain[fieldStart.hashValue] = fieldStop
		chain[fieldStop.hashValue] = fieldLocation
		chain[fieldLocation.hashValue] = fieldClientBefore
		chain[fieldClientBefore.hashValue] = fieldReporterBefore
		chain[fieldReporterBefore.hashValue] = fieldDoing
		chain[fieldDoing.hashValue] = fieldSaying
		chain[fieldSaying.hashValue] = fieldAction
		chain[fieldAction.hashValue] = fieldResponse
		buttonAdd.setTitle(record == nil ? "Add record" : "Update record", for: .normal)
		buttonAdd.addTarget(self, action: #selector(onClickButtonAdd(_:)), for: .touchUpInside)
		
		if let rec = record {
			fieldStart.text = rec.time_start.timestamp()
			fieldStop.text = rec.time_end.timestamp()
			fieldLocation.text = rec.location.nullable
			fieldClientBefore.text = rec.precondition_client.nullable
			fieldReporterBefore.text = rec.precondition_reporter.nullable
			fieldDoing.text = rec.client_behaviour.nullable
			fieldSaying.text = rec.client_saying.nullable
			fieldAction.text = rec.reporter_action.nullable
			fieldResponse.text = rec.reporter_saying.nullable
		}
	}
}

extension FormViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		var anchor = textField.frame.origin
		if anchor.y > view.bounds.height / 4.0 {
			anchor.y -= view.bounds.height / 4.0
			panel.contentOffset = anchor
		}
		currentActiveTextField = textField
	}
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let ret = textField.resignFirstResponder()
		if let next = chain[textField.hashValue] as? UITextField {
			_ = next.becomeFirstResponder()
			textFieldDidBeginEditing(next)
		}
		return ret
	}
}
