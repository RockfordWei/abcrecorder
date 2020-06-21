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

	}
	@IBAction func onClickMail(_ sender: Any) {

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
		NotificationCenter.default.addObserver(self, selector: #selector(onUpdateRecord(notification:)), name: UserDefaults.notification, object: nil)
	}
}

extension ViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let date = UserDefaults.dates[indexPath.section]
		let records = UserDefaults.records[date] ?? []
		let vc = FormViewController()
		vc.record = records[indexPath.row]
		vc.modalPresentationStyle = .fullScreen
		navigationController?.pushViewController(vc, animated: true)
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
