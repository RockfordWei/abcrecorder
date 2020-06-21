//
//  ViewController.swift
//  ABC Recorder
//
//  Created by Rocky Wei on 2020-06-20.
//  Copyright © 2020 Treefrog Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	let cellId = UUID().uuidString

	@IBOutlet weak var tableContent: UITableView!

	@IBAction func onClickButtonAll(_ sender: Any) {
		if let rows = tableContent.indexPathsForSelectedRows {
			for row in rows {
				tableContent.deselectRow(at: row, animated: true)
			}
		} else {
			UserDefaults.dates.enumerated().forEach { item in
				if let section = UserDefaults.records[item.element] {
					for row in 0..<section.count {
						let indexPath = IndexPath(row: row, section: item.offset)
						tableContent.selectRow(at: indexPath, animated: true, scrollPosition: .none)
					}
				}
			}
		}
	}
	@IBAction func onClickMail(_ sender: Any) {

	}
	@IBAction func onClickEdit(_ sender: Any) {
		if let indexPath = tableContent.indexPathsForSelectedRows?.first {
			let date = UserDefaults.dates[indexPath.section]
			let records = UserDefaults.records[date] ?? []
			let vc = FormViewController()
			vc.record = records[indexPath.row]
			vc.modalPresentationStyle = .fullScreen
			navigationController?.pushViewController(vc, animated: true)
		} else {
			showAlert(alertText: "View Record", alertMessage: "Please select a record to view and edit details")
		}
	}
	@IBAction func onClickAdd(_ sender: Any) {
		let vc = FormViewController()
		vc.record = nil
		vc.modalPresentationStyle = .fullScreen
		navigationController?.pushViewController(vc, animated: true)
	}

	@objc func onUpdateRecord(notification: Notification) {
		DispatchQueue.main.async {
			self.tableContent.reloadData()
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "ABC Recording Sheet"
		tableContent.backgroundColor = .white
		tableContent.dataSource = self
		tableContent.delegate = self
		tableContent.allowsSelection = true
		tableContent.allowsMultipleSelection = true
		tableContent.allowsSelectionDuringEditing = false
		tableContent.allowsMultipleSelectionDuringEditing = false
		NotificationCenter.default.addObserver(self, selector: #selector(onUpdateRecord(notification:)), name: UserDefaults.notification, object: nil)
	}
}

extension ViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }
		let date = UserDefaults.dates[indexPath.section]
		let records = UserDefaults.records[date] ?? []
		let rec = records[indexPath.row]
		showAlert(alertText: "Delete Record", alertMessage:
			"Click OK to delete this record \"\(rec.client_behaviour)\" on \(rec.time_start.timestamp()). Note: this operation cannot be recovered",
			cancellation: { _ in }, completion: { _ in
				_ = UserDefaults.delete(record: rec)
				DispatchQueue.main.async {
					self.tableContent.reloadData()
				}
		})
	}
}
extension ViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return UserDefaults.dates.count
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return UserDefaults.dates[section].simple()
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let date = UserDefaults.dates[section]
		return UserDefaults.records[date]?.count ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell
		if let xell = tableView.dequeueReusableCell(withIdentifier: cellId) {
			cell = xell
		} else {
			cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
		}
		let date = UserDefaults.dates[indexPath.section]
		let records = UserDefaults.records[date] ?? []
		let rec = records[indexPath.row]
		cell.textLabel?.text = rec.client_behaviour
		cell.detailTextLabel?.text = rec.time_start.timestamp()
		return cell
	}
}
