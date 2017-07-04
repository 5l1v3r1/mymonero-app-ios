//
//  OpenAliasResolverRequestMaker.swift
//  MyMonero
//
//  Created by Paul Shapiro on 7/3/17.
//  Copyright © 2017 MyMonero. All rights reserved.
//

import Foundation

class OpenAliasResolverRequestMaker
{ // Subclass this
	//
	// Properties
	var resolve_requestHandle: HostedMoneroAPIClient.RequestHandle?
	//
	// Imperatives - Lifecycle
	func cancelAnyRequestFor_oaResolution()
	{
		if let requestHandle = self.resolve_requestHandle {
			requestHandle.cancel()
			self.resolve_requestHandle = nil
		}
	}
	//
	// Accessors - Runtime
	//
	// Imperatives - Runtime
	//
}
