//
//  ViewController.swift
//  ABC Recorder
//
//  Created by Rocky Wei on 2020-06-20.
//  Copyright © 2020 Treefrog Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var tableContent: UITableView!

	@IBAction func onClickButtonAll(_ sender: Any) {

	}
	@IBAction func onClickMail(_ sender: Any) {

	}
	@IBAction func onClickAdd(_ sender: Any) {
		let vc = FormViewController()
		vc.modalPresentationStyle = .fullScreen
		navigationController?.pushViewController(vc, animated: true)
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "ABC Recording Sheet"
		tableContent.backgroundColor = .white
	}
}

