//
//  ViewController.swift
//  ABC Recorder
//
//  Created by Rocky Wei on 2020-06-20.
//  Copyright © 2020 Treefrog Inc. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController {

	let cellId = UUID().uuidString

	@IBOutlet weak var tableContent: UITableView!

	@IBAction func onClickAbout(_ sender: Any) {
		DispatchQueue.main.async {
			self.showAlert(alertText: "ABC Recorder", alertMessage: "Powered by Treefrog Inc.\nVersion: \(UserDefaults.build)")
		}
	}
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
		guard MFMailComposeViewController.canSendMail() else {
			showAlert(alertText: "Send Records as Mail Attachment", alertMessage: "Please setup your email before attaching anything")
			return
		}
		guard let indexPaths = tableContent.indexPathsForSelectedRows else {
			showAlert(alertText: "Send Records as Mail Attachment", alertMessage: "Please choose the records to send")
			return
		}
		let records:[String] = indexPaths.compactMap { indexPath -> String? in
			let date = UserDefaults.dates[indexPath.section]
			if let rec = UserDefaults.records[date] {
				return rec[indexPath.row].csv_row
			} else {
				return nil
			}
		}
		let csv = ([ABCRecord.header] + records).joined(separator: "\n")
		guard let data = csv.data(using: .utf8) else {
			showAlert(alertText: "Send Records as Mail Attachment", alertMessage: "Unable to encode the CSV file. Please contact technical support")
			return
		}
		let mail = MFMailComposeViewController()
		mail.setSubject("ABC Recording Sheet")
		mail.addAttachmentData(data as Data, mimeType: "text/csv" , fileName: "ABC_Recording_Sheet.csv")
		mail.mailComposeDelegate = self
		//add attachment
		present(mail, animated: true)
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
		view.backgroundColor = .pinkBackground
		tableContent.backgroundColor = .pinkBackground
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
extension ViewController: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true)
	}
}
