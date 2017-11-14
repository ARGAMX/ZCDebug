//
//  ZCDebug.swift
//
//  Created by Sergey Zalozniy
//  All rights reserved.
//

import Foundation

private let kErrorColor = "❌"
private let kWarningColor = "❗"
private let kDebugColor = "💬" //👻▶◼➡⏩

#if DEBUG
	public func _$l<T>(_ debug: T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
		swift_print(kDebugColor, textObject: debug, file: file, function: function, line: line)
	}
	
	public func _$le<T>(_ debug: T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
		swift_print(kErrorColor, textObject: debug, file: file, function: function, line: line)
	}
	
	public func _$lw<T>(_ debug: T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
		swift_print(kWarningColor, textObject: debug, file: file, function: function, line: line)
	}
	
	@discardableResult public func _$tf(file: String = #file, _ function: String = #function, _ line: Int = #line) -> ZCDebugObject? {
		let obj = ZCDebugObject(file: file, function: function, line: line)
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: { _ = obj.startTime }) // Prevent object from immediate dealocation
		return obj
	}
	
	public func _$fail(_ condition: Bool = true, reason: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
		guard condition else {
			return
		}
		let stackSymbols = Thread.callStackSymbols.reduce("", { (result, value) -> String in
			return result + "\n" + value
		})
		let message = "❗❗❗ fail: " + reason + "❗❗❗\n"
		_$le(message, file, function, line)
		print(stackSymbols)
		abort()
	}
#else
	public func _$l<T>(_ debug: T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {}
	
	public func _$le<T>(_ debug: T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {}
	
	public func _$lw<T>(_ debug: T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {}
	
	public func _$tf(file: String = #file, _ function: String = #function, _ line: Int = #line) -> ZCDebugObject? { return nil }
	
	public func _$fail(_ condition: Bool = true, reason: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {}
#endif

private func swift_print<T>(_ prefix: String, textObject: T, file: String, function: String, line: Int) {
	var text = ""
	if let stringObject = textObject as? String {
		text = stringObject
	} else {
		text = "\(textObject)"
	}
	let filename = ((file as NSString).lastPathComponent as NSString).deletingPathExtension
	let message = String(format: "\(prefix) \(timenow()) \(filename) [\(function)] : %-4d ~~ %@",
		line,
		text)
	print(message)
}


private func timenow() -> String {
	var buffer = [Int8](repeating: 0, count: 17)
	var atime = time(nil)
	
	let milliseconds = CFAbsoluteTimeGetCurrent()
	var integer = 0.0
	let fraction = Int(modf(milliseconds, &integer) * 1000)
	
	let format = "%H:%M:%S."
	strftime_l(&buffer, buffer.count, format, localtime(&atime), nil)
	return String(cString: buffer) + String(format: "%03d", fraction)
}


public class ZCDebugObject {
	let startTime = CFAbsoluteTimeGetCurrent()
	private var file = ""
	private var function = ""
	private var line = 0
	
	init(file: String = #file, function: String = #function, line: Int = #line) {
		self.file = file
		self.function = function
		self.line = line
		swift_print(kDebugColor, textObject: "Start \(function)", file: file, function: function, line: line)
	}
	
	deinit {
		let message = "Finished \(function) in \(CFAbsoluteTimeGetCurrent() - self.startTime)"
		swift_print(kDebugColor, textObject: message , file: file, function: function, line: line)
	}
}
