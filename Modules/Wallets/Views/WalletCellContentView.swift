//
//  WalletCellContentView.swift
//  MyMonero
//
//  Created by Paul Shapiro on 6/11/17.
//  Copyright (c) 2014-2017, MyMonero.com
//
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of
//	conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list
//	of conditions and the following disclaimer in the documentation and/or other
//	materials provided with the distribution.
//
//  3. Neither the name of the copyright holder nor the names of its contributors may be
//	used to endorse or promote products derived from this software without specific
//	prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
//  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//
import UIKit

class WalletCellContentView: UIView
{
	var sizeClass: UICommonComponents.WalletIconView.SizeClass
	var iconView: UICommonComponents.WalletIconView!
	var titleLabel: UILabel!
	var subtitleLabel: UILabel!
	//
	// Lifecycle - Init
	init(sizeClass: UICommonComponents.WalletIconView.SizeClass)
	{
		self.sizeClass = sizeClass
		super.init(frame: .zero)
		self.setup()
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	func setup()
	{
		do {
			let view = UICommonComponents.WalletIconView(sizeClass: self.sizeClass)
			self.addSubview(view)
			self.iconView = view
		}
		do {
			let view = UILabel()
			view.textColor = UIColor(rgb: 0xFCFBFC)
			view.font = UIFont.middlingSemiboldSansSerif
			view.numberOfLines = 1
			self.addSubview(view)
			self.titleLabel =  view
		}
		do {
			let view = UILabel()
			view.textColor = UIColor(rgb: 0x9E9C9E)
			view.font = UIFont.middlingRegularMonospace
			view.numberOfLines = 1
			self.addSubview(view)
			self.subtitleLabel =  view
		}
	}
	//
	// Lifecycle - Teardown/Reuse
	deinit
	{
		self.tearDown_object()
	}
	func tearDown_object()
	{
		if self.object != nil {
			self.stopObserving_object()
			self.object = nil
		}
	}
	func prepareForReuse()
	{
		self.tearDown_object()
	}
	func stopObserving_object()
	{
		assert(self.object != nil)
		NotificationCenter.default.removeObserver(self, name: PersistableObject.NotificationNames.booted.notificationName, object: self.object!)
		NotificationCenter.default.removeObserver(self, name: PersistableObject.NotificationNames.failedToBoot.notificationName, object: self.object!)
		//
		NotificationCenter.default.removeObserver(self, name: Wallet.NotificationNames.labelChanged.notificationName, object: self.object!)
		NotificationCenter.default.removeObserver(self, name: Wallet.NotificationNames.balanceChanged.notificationName, object: self.object!)
		NotificationCenter.default.removeObserver(self, name: Wallet.NotificationNames.swatchColorChanged.notificationName, object: self.object!)
		NotificationCenter.default.removeObserver(self, name: PersistableObject.NotificationNames.willBeDeleted.notificationName, object: self.object!)
		NotificationCenter.default.removeObserver(self, name: PersistableObject.NotificationNames.willBeDeinitialized.notificationName, object: self.object!)

	}
	//
	// Accessors
	var iconView_x: CGFloat
	{
		switch self.sizeClass {
			case .large48, .large43:
				return 16
			case .medium32:
				return 15
		}
	}
	var labels_x: CGFloat
	{
		switch self.sizeClass {
			case .large48:
				return 80
			case .large43:
				return 75
			case .medium32:
				return 66
		}
	}
	var titleLabels_y: CGFloat
	{
		switch self.sizeClass {
			case .large48:
				return 23
			case .large43:
				return 22
			case .medium32:
				return 15
		}
	}
	//
	// Imperatives - Configuration
	weak var object: Wallet? // weak to prevent self from preventing .willBeDeinitialized from being received
	func configure(withObject object: Wallet)
	{
		if self.object != nil {
			self.prepareForReuse() // in case this is not being used in an actual UITableViewCell (which has a prepareForReuse)
		}
		assert(self.object == nil)
		self.object = object
		self._configureUIWithWallet()
		self.startObserving_object()
	}
	func _configureUIWithWallet()
	{
		assert(self.object != nil)
		self.__configureUIWithWallet_labels()
		self.__configureUIWithWallet_swatchColor()
	}
	func __configureUIWithWallet_labels()
	{
		assert(self.object != nil)
		self.titleLabel.text = self.object!.walletLabel
		if self.object!.isLoggingIn {
			self.subtitleLabel.text = "Logging in…"
			return
		}
		if self.object!.didFailToInitialize_flag == true { // unlikely but possible
			self.subtitleLabel.text = "Load error"
			return
		}
		if self.object!.didFailToBoot_flag == true { // possible when server incorrect
			self.subtitleLabel.text = "Login error"
			return
		}
		var subtitleLabel_text: String?
		do {
			if self.object!.hasEverFetched_accountInfo == false {
				subtitleLabel_text = "Loading…"
			} else {
				subtitleLabel_text = "\(self.object!.balance_formattedString) \(self.object!.currency.humanReadableCurrencySymbolString)"
				if self.object!.hasLockedFunds {
					subtitleLabel_text = subtitleLabel_text! + " (\(self.object!.lockedBalance_formattedString) 🔒)"
				}
			}
		}
		assert(subtitleLabel_text != nil)
		self.subtitleLabel.text = subtitleLabel_text
	}
	func __configureUIWithWallet_swatchColor()
	{
		self.iconView.configure(withSwatchColor: self.object!.swatchColor)
	}
	func clearFields()
	{
		self.iconView.configure(withSwatchColor: .blue)
		self.titleLabel.text = ""
		self.subtitleLabel.text = ""
	}
	//
	func startObserving_object()
	{
		assert(self.object != nil)
		NotificationCenter.default.addObserver(self, selector: #selector(_wallet_loggedIn), name: PersistableObject.NotificationNames.booted.notificationName, object: self.object!)
		NotificationCenter.default.addObserver(self, selector: #selector(_wallet_failedToLogIn), name: PersistableObject.NotificationNames.failedToBoot.notificationName, object: self.object!)
		//
		NotificationCenter.default.addObserver(self, selector: #selector(_labelChanged), name: Wallet.NotificationNames.labelChanged.notificationName, object: self.object!)
		NotificationCenter.default.addObserver(self, selector: #selector(_balanceChanged), name: Wallet.NotificationNames.balanceChanged.notificationName, object: self.object!)
		NotificationCenter.default.addObserver(self, selector: #selector(_swatchColorChanged), name: Wallet.NotificationNames.swatchColorChanged.notificationName, object: self.object!)
		NotificationCenter.default.addObserver(self, selector: #selector(_willBeDeleted), name: PersistableObject.NotificationNames.willBeDeleted.notificationName, object: self.object!)
		NotificationCenter.default.addObserver(self, selector: #selector(_willBeDeinitialized), name: PersistableObject.NotificationNames.willBeDeinitialized.notificationName, object: self.object!)
	}
	//
	// Imperatives - Overrides
	override func layoutSubviews()
	{
		super.layoutSubviews()
		self.iconView.frame = CGRect(
			x: self.iconView_x,
			y: 16,
			width: self.iconView.frame.size.width,
			height: self.iconView.frame.size.height
		)
		let labels_x = self.labels_x
		let labels_rightMargin: CGFloat = 40
		let labels_width = self.frame.size.width - labels_x - labels_rightMargin
		self.titleLabel.frame = CGRect(
			x: labels_x,
			y: self.titleLabels_y,
			width: labels_width,
			height: 16 // TODO: size with font for accessibility?
		).integral
		self.subtitleLabel.frame = CGRect(
			x: labels_x,
			y: self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 1,
			width: labels_width,
			height: 20 // TODO: size with font for accessibility? NOTE: must support emoji, currently, for locked icon
		).integral
	}
	//
	// Delegation - Wallet NSNotifications
	@objc func _wallet_loggedIn()
	{
		self.__configureUIWithWallet_labels()
	}
	@objc func _wallet_failedToLogIn()
	{
		self.__configureUIWithWallet_labels()
	}
	@objc func _labelChanged()
	{
		self.__configureUIWithWallet_labels()
	}
	@objc func _balanceChanged()
	{
		self.__configureUIWithWallet_labels()
	}
	@objc func _swatchColorChanged()
	{
		self.__configureUIWithWallet_swatchColor()
	}
	@objc func _willBeDeleted()
	{
		self.tearDown_object() // stopObserving/release
	}
	@objc func _willBeDeinitialized()
	{
		self.tearDown_object() // stopObserving/release
	}
}
