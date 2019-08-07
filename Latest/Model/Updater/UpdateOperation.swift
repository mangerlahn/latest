//
//  UpdateOperation.swift
//  Latest
//
//  Created by Max Langer on 01.07.19.
//  Copyright © 2019 Max Langer. All rights reserved.
//

import Foundation

class UpdateOperation: StatefulOperation {
	
	enum ProgressState {
		case none
		case pending
		case initializing
		case downloading(loadedSize: Int64, totalSize: Int64)
		case extracting(progress: Double)
		case installing
		case error(Error)
		case cancelling
	}
	
	typealias ProgressHandler = (_: ProgressState) -> Void
	
	typealias CompletionHandler = () -> Void
	
	let app: AppBundle
	
	let progressHandler: UpdateOperation.ProgressHandler
	
	let completionHandler: UpdateOperation.CompletionHandler
	
	init(app: AppBundle, progressHandler: @escaping UpdateOperation.ProgressHandler, completionHandler: @escaping UpdateOperation.CompletionHandler) {
		self.app = app
		self.progressHandler = progressHandler
		self.completionHandler = completionHandler
		
		self.progressHandler(.pending)
	}
	
	override func execute() {
		self.progressHandler(.initializing)
	}
	
	override func cancel() {
		super.cancel()
		self.progressHandler(.cancelling)
	}
		
	override func finish() {
		if let error = self.error {
			self.progressHandler(.error(error))
		} else {
			self.progressHandler(.none)
		}
		
		self.completionHandler()
		super.finish()
	}
	
}

extension NSError {

	static var noUpdate: NSError {
		let description = NSLocalizedString("No update was found for this app.", comment: "Error description when no update was found for a particular app.")
		return NSError(latestErrorWithCode: NSError.LatestErrorCodes.noUpdate, localizedDescription: description)
	}
}
