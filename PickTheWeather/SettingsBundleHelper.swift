//
//  SettingsBundleHelper.swift
//  WeatherDataScrollView
//
//  Created by Beniamin on 18.06.19.
//  Copyright © 2019 Beniamin. All rights reserved.
//

import UIKit

class SettingsBundleHelper {
    struct SettingsBundleKeys {
        static let temperatureUnit = "temperature_preference"
        static let windSpeedUnit = "wind_speed_preference"
    }
    
    class func setVersionAndBuildNumber() {
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: "version_preference")
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: "build_preference")
    }
}
