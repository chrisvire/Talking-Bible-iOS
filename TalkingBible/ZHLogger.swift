//
//  Copyright 2015 Talking Bibles International
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

// Public
var logLevel = defaultDebugLevel
var ZHLogShowDateTime: Bool = true
var ZHLogShowLogLevel: Bool = true
var ZHLogShowFileName: Bool = true
var ZHLogShowLineNumber: Bool = true
var ZHLogShowFunctionName: Bool = true

enum ZHLogLevel: Int {
    case All        = 0
    case Verbose    = 10
    case Debug      = 20
    case Info       = 30
    case Warning    = 40
    case Error      = 50
    case Off        = 60
    static func logLevelString(logLevel: ZHLogLevel) -> String {
        switch logLevel {
        case .Verbose: return "Verbose"
        case .Info: return "Info"
        case .Debug: return "Debug"
        case .Warning: return "Warning"
        case .Error: return "Error"
        default:
            assertionFailure("Invalid level to get string")
            return "Invalid"
        }
    }
}

// Be sure to set the "DEBUG" symbol.
// Set it in the "Swift Compiler - Custom Flags" section, "Other Swift Flags" line. You add the DEBUG symbol with the -D DEBUG entry.
#if DEBUG_VERSION
    let defaultDebugLevel = ZHLogLevel.All
    #else
let defaultDebugLevel = ZHLogLevel.Warning
#endif

var _ZHLogDateFormatter: NSDateFormatter?
var ZHLogDateFormatter: NSDateFormatter {
    if _ZHLogDateFormatter == nil {
        _ZHLogDateFormatter = NSDateFormatter()
        _ZHLogDateFormatter!.locale = NSLocale(localeIdentifier: "en_US_POSIX") //24H
        _ZHLogDateFormatter!.dateFormat = "y-MM-dd HH:mm:ss.SSS"
    }
    return _ZHLogDateFormatter!
}

// Default
#if DEBUG_VERSION
    var ZHLogFunc: (format: String) -> Void = println
    var ZHLogUsingNSLog: Bool = false
    #else
var ZHLogFunc: (format: String, args: CVarArgType...) -> Void = NSLog
var ZHLogUsingNSLog: Bool = true
#endif

func logVerbose(_ logText: String = "",
    file: String = __FILE__,
    line: UWord = __LINE__,
    function: String = __FUNCTION__,
    #args: CVarArgType...)
{
    if ZHLogLevel.Verbose.rawValue >= logLevel.rawValue {
        log(.Verbose, file: file, function: function, line: line, logText, args: getVaList(args))
    }
}

func logInfo(_ logText: String = "",
    file: String = __FILE__,
    line: UWord = __LINE__,
    function: String = __FUNCTION__,
    #args: CVarArgType...)
{
    if ZHLogLevel.Info.rawValue >= logLevel.rawValue {
        log(.Info, file: file, function: function, line: line, logText, args: getVaList(args))
    }
}

func logDebug(_ logText: String = "",
    file: String = __FILE__,
    line: UWord = __LINE__,
    function: String = __FUNCTION__,
    #args: CVarArgType...)
{
    if ZHLogLevel.Debug.rawValue >= logLevel.rawValue {
        log(.Debug, file: file, function: function, line: line, logText, args: getVaList(args))
    }
}

func logWarning(_ logText: String = "",
    file: String = __FILE__,
    line: UWord = __LINE__,
    function: String = __FUNCTION__,
    #args: CVarArgType...)
{
    if ZHLogLevel.Warning.rawValue >= logLevel.rawValue {
        log(.Warning, file: file, function: function, line: line, logText, args: getVaList(args))
    }
}

func logError(_ logText: String = "",
    file: String = __FILE__,
    line: UWord = __LINE__,
    function: String = __FUNCTION__,
    #args: CVarArgType...)
{
    if ZHLogLevel.Error.rawValue >= logLevel.rawValue {
        log(.Error, file: file, function: function, line: line, logText, args: getVaList(args))
    }
}

private func log(level: ZHLogLevel, file: String = __FILE__, var function: String = __FUNCTION__, line: UWord = __LINE__, format: String, #args: CVaListPointer) {
    let time: String = ZHLogShowDateTime ? (ZHLogUsingNSLog ? "" : "\(ZHLogDateFormatter.stringFromDate(NSDate())) ") : ""
    let level: String = ZHLogShowLogLevel ? "[\(ZHLogLevel.logLevelString(level))] " : ""
    var fileLine: String = ""
    if ZHLogShowFileName {
        fileLine += "[" + file.lastPathComponent
        if ZHLogShowLineNumber {
            fileLine += ":\(line)"
        }
        fileLine += "] "
    }
    if !ZHLogShowFunctionName { function = "" }
    let message = NSString(format: format, arguments: args) as String
    let logText = "\(time)\(level)\(fileLine)\(function): \(message)"
    
    ZHLogFunc(format: logText)
}