//
//  trinmUltiViewController.swift
//  demoUlti
//
//  Created by BDAFshare on 4/13/17.
//  Copyright © 2017 RAD-INF. All rights reserved.
//

import UIKit

struct User {
    
    func saveUserDefaults(dictionary:NSDictionary)->Void{
        let defaults = UserDefaults.standard
        let array = dictionary.allKeys
        for key in array {
            let value = dictionary.object(forKey: key)
            defaults .set(value, forKey: key as! String)
        }
        defaults .synchronize()
    }
    
    func getUserDefaults(key:String)->Any {
        let defaults = UserDefaults.standard
        let value:Any = defaults.object(forKey: key)!
        return value
    }
}

struct Device {
    
    // MARK: - Singletons
    static var TheCurrentDevice: UIDevice {
        struct Singleton {
            static let device = UIDevice.current
        }
        return Singleton.device
    }
    
    static var TheCurrentDeviceVersion: Float {
        struct Singleton {
            static let version = (UIDevice.current.systemVersion as NSString).floatValue
        }
        return Singleton.version
    }
    
    static var TheCurrentDeviceHeight: CGFloat {
        struct Singleton {
            static let height = UIScreen.main.bounds.size.height
        }
        return Singleton.height
    }
    
    // MARK: - Device Idiom Checks
    static var PHONE_OR_PAD: String {
        if isPhone() {
            return "iPhone"
        } else if isPad() {
            return "iPad"
        }
        return "Not iPhone nor iPad"
    }
    
    static var DEBUG_OR_RELEASE: String {
        #if DEBUG
            return "Debug"
        #else
            return "Release"
        #endif
    }
    
    static var SIMULATOR_OR_DEVICE: String {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return "Simulator"
        #else
            return "Device"
        #endif
    }
    
    static func isPhone() -> Bool {
        return TheCurrentDevice.userInterfaceIdiom == .phone
    }
    
    static func isPad() -> Bool {
        return TheCurrentDevice.userInterfaceIdiom == .pad
    }
    
    static func isDebug() -> Bool {
        return DEBUG_OR_RELEASE == "Debug"
    }
    
    static func isRelease() -> Bool {
        return DEBUG_OR_RELEASE == "Release"
    }
    
    static func isSimulator() -> Bool {
        return SIMULATOR_OR_DEVICE == "Simulator"
    }
    
    static func isDevice() -> Bool {
        return SIMULATOR_OR_DEVICE == "Device"
    }
    
    // MARK: - Device Version Checks
    enum Versions: Float {
        case Five = 5.0
        case Six = 6.0
        case Seven = 7.0
        case Eight = 8.0
        case Nine = 9.0
    }
    
    static func isVersion(version: Versions) -> Bool {
        return TheCurrentDeviceVersion >= version.rawValue && TheCurrentDeviceVersion < (version.rawValue + 1.0)
    }
    
    static func isVersionOrLater(version: Versions) -> Bool {
        return TheCurrentDeviceVersion >= version.rawValue
    }
    
    static func isVersionOrEarlier(version: Versions) -> Bool {
        return TheCurrentDeviceVersion < (version.rawValue + 1.0)
    }
    
    static var CURRENT_VERSION: String {
        return "\(TheCurrentDeviceVersion)"
    }
    
    // MARK: iOS 5 Checks
    static func IS_OS_5() -> Bool {
        return isVersion(version: .Five)
    }
    
    static func IS_OS_5_OR_LATER() -> Bool {
        return isVersionOrLater(version: .Five)
    }
    
    static func IS_OS_5_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(version: .Five)
    }
    
    // MARK: iOS 6 Checks
    static func IS_OS_6() -> Bool {
        return isVersion(version: .Six)
    }
    
    static func IS_OS_6_OR_LATER() -> Bool {
        return isVersionOrLater(version: .Six)
    }
    
    static func IS_OS_6_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(version: .Six)
    }
    
    // MARK: iOS 7 Checks
    static func IS_OS_7() -> Bool {
        return isVersion(version: .Seven)
    }
    
    static func IS_OS_7_OR_LATER() -> Bool {
        return isVersionOrLater(version: .Seven)
    }
    
    static func IS_OS_7_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(version: .Seven)
    }
    
    // MARK: iOS 8 Checks
    static func IS_OS_8() -> Bool {
        return isVersion(version: .Eight)
    }
    
    static func IS_OS_8_OR_LATER() -> Bool {
        return isVersionOrLater(version: .Eight)
    }
    
    static func IS_OS_8_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(version: .Eight)
    }
    
    // MARK: iOS 9 Checks
    static func IS_OS_9() -> Bool {
        return isVersion(version: .Nine)
    }
    
    static func IS_OS_9_OR_LATER() -> Bool {
        return isVersionOrLater(version: .Nine)
    }
    
    static func IS_OS_9_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(version: .Nine)
    }
    
    // MARK: - Device Size Checks
    enum Heights: CGFloat {
        case Inches_3_5 = 480
        case Inches_4 = 568
        case Inches_4_7 = 667
        case Inches_5_5 = 736
    }
    
    static func isSize(height: Heights) -> Bool {
        return TheCurrentDeviceHeight == height.rawValue
    }
    
    static func isSizeOrLarger(height: Heights) -> Bool {
        return TheCurrentDeviceHeight >= height.rawValue
    }
    
    static func isSizeOrSmaller(height: Heights) -> Bool {
        return TheCurrentDeviceHeight <= height.rawValue
    }
    
    static var CURRENT_SIZE: String {
        if IS_3_5_INCHES() {
            return "3.5 Inches"
        } else if IS_4_INCHES() {
            return "4 Inches"
        } else if IS_4_7_INCHES() {
            return "4.7 Inches"
        } else if IS_5_5_INCHES() {
            return "5.5 Inches"
        }
        return "\(TheCurrentDeviceHeight) Points"
    }
    
    // MARK: 3.5 Inch Checks
    static func IS_3_5_INCHES() -> Bool {
        return isPhone() && isSize(height: .Inches_3_5)
    }
    
    static func IS_3_5_INCHES_OR_LARGER() -> Bool {
        return isPhone() && isSizeOrLarger(height: .Inches_3_5)
    }
    
    static func IS_3_5_INCHES_OR_SMALLER() -> Bool {
        return isPhone() && isSizeOrSmaller(height: .Inches_3_5)
    }
    
    // MARK: 4 Inch Checks
    static func IS_4_INCHES() -> Bool {
        return isPhone() && isSize(height: .Inches_4)
    }
    
    static func IS_4_INCHES_OR_LARGER() -> Bool {
        return isPhone() && isSizeOrLarger(height: .Inches_4)
    }
    
    static func IS_4_INCHES_OR_SMALLER() -> Bool {
        return isPhone() && isSizeOrSmaller(height: .Inches_4)
    }
    
    // MARK: 4.7 Inch Checks
    static func IS_4_7_INCHES() -> Bool {
        return isPhone() && isSize(height: .Inches_4_7)
    }
    
    static func IS_4_7_INCHES_OR_LARGER() -> Bool {
        return isPhone() && isSizeOrLarger(height: .Inches_4_7)
    }
    
    static func IS_4_7_INCHES_OR_SMALLER() -> Bool {
        return isPhone() && isSizeOrLarger(height: .Inches_4_7)
    }
    
    // MARK: 5.5 Inch Checks
    static func IS_5_5_INCHES() -> Bool {
        return isPhone() && isSize(height: .Inches_5_5)
    }
    
    static func IS_5_5_INCHES_OR_LARGER() -> Bool {
        return isPhone() && isSizeOrLarger(height: .Inches_5_5)
    }
    
    static func IS_5_5_INCHES_OR_SMALLER() -> Bool {
        return isPhone() && isSizeOrLarger(height: .Inches_5_5)
    }
    
    // MARK: - International Checks
    static var CURRENT_REGION: String {
        return Locale.current.regionCode!
    }
}
extension String {
    var isNumeric: Bool {
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self.characters).isSubset(of: nums)
    }
}
extension UIImage {
    //let myPic = UIImage(data: dataIMG! as Data)
    //let mythumb = myPic?.resizedEX(withPercentage: 0.1)
    //let dataUpload = UIImagePNGRepresentation(mythumb!)
    func resizedEX(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
