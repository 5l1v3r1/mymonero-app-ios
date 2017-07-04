//
//  EditContactFormViewController.swift
//  MyMonero
//
//  Created by Paul Shapiro on 6/30/17.
//  Copyright © 2017 MyMonero. All rights reserved.
//

import Foundation

class EditContactFormViewController: ContactFormViewController
{
	var contact: Contact
	init(withContact contact: Contact)
	{
		self.contact = contact
		super.init()
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	//
	override func setup_navigation()
	{
		super.setup_navigation()
		self.navigationItem.title = NSLocalizedString("Edit Contact", comment: "")
	}
	//
	// Overrides - Accessors
	override var _overridable_formSubmissionMode: ContactFormSubmissionController.Mode { return .update }
	override var _overridable_forMode_update__contactInstance: Contact? { return self.contact }
}
