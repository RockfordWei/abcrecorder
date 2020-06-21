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

	private let fieldStart = UIViewController.createTextField(placeholder: "START TIME")
	private let fieldStop = UIViewController.createTextField(placeholder: "END TIME")


	private var chain: [Int: UITextField] = [:]
	private var currentActiveTextField: UITextField? = nil

	private func dig(upper: UITextField? = nil, lower: UITextField) {
		panel.addSubview(lower)
		if let u = upper {
			lower.topAnchor.constraint(equalTo: u.bottomAnchor, constant: 16).isActive = true
			chain[u.hashValue] = lower
		} else {
			lower.topAnchor.constraint(equalTo: panel.topAnchor, constant: 16).isActive = true
		}
		lower.heightAnchor.constraint(equalToConstant: 48).isActive = true
		lower.centerXAnchor.constraint(equalTo: panel.centerXAnchor).isActive = true
		lower.widthAnchor.constraint(equalTo: panel.widthAnchor).isActive = true
		lower.delegate = self
	}

	@objc func onClickInputDone(_ sender: UIBarButtonItem) {
		if let active = currentActiveTextField {
			active.text = datePicker.date.timestamp()
			_ = active.resignFirstResponder()
			if let next = chain[active.hashValue] {
				_ = next.becomeFirstResponder()
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		navigationItem.title = "Add New Record"
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
		dig(lower: fieldStart)
		dig(upper: fieldStart, lower: fieldStop)
	}
}

extension FormViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		var anchor = textField.frame.origin
		if anchor.y > view.bounds.height / 2.0 {
			anchor.y -= view.bounds.height / 4.0
			panel.contentOffset = anchor
		}
		currentActiveTextField = textField
	}
}
