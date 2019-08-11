//
//  ViewController.swift
//  WeatherDataScrollView
//
//  Created by Beniamin on 11.06.19.
//  Copyright © 2019 Beniamin. All rights reserved.

// 
//  countryCodes.json
//  WeatherDataScrollView
//
//  Created by Beniamin on 03.07.19.
//  Copyright © 2019 Beniamin. All rights reserved.

import UIKit
import SwiftyJSON

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var countriesArray = [String]()
    var citiesArray = [String]()
    var currentCountriesRow = 0
    var temperatureUnit = "C"
    var windSpeedUnit = "m/s"
    
    // MARK: Properties
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var cityPicker: UIPickerView!
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        //WeatherDataParser.shared.getCountryCode()
        showAlert()
    }
    
    func showAlert(){
        if  HelperInternetConnection.shared.isConnectedToNetwork() == false{
            
            let controller = UIAlertController(title: "No Internet Connection", message: "Please check your Internet connection and restart the app", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Exit app", style: .default, handler: exitApp)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            controller.addAction(okAction)
            controller.addAction(cancelAction)
            
            //show an alert to the user
            present(controller, animated: true, completion: nil)
        }
    }
    
    private func exitApp(alert: UIAlertAction){
        UIControl().sendAction(#selector(NSXPCConnection.suspend),
                               to: UIApplication.shared, for: nil)
    }
    
    // fill pickers with countries and cities, download default weather data
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.addBackground()
        registerSettingsBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
        resultLabel.text = ""
        resultLabel.isHidden = true
        
        WeatherDataParser.shared.getCountriesList(countriesArray: &countriesArray)
        WeatherDataParser.shared.getCities(country: countriesArray[0], citiesArray: &citiesArray)

        cityPicker.reloadAllComponents()
        downloadWeatherData(citiesArray[0], countriesArray[currentCountriesRow])
        resultLabel.isHidden = false
        
        countryPicker.dataSource = self
        countryPicker.delegate = self
        
        cityPicker.dataSource = self
        cityPicker.delegate = self
    }
    
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    // settings changed
    @objc func defaultsChanged(){
        if UserDefaults.standard.integer(forKey: "unitsSettings") == 0 {
            temperatureUnit = "C"
        }
        else{
            temperatureUnit = "F"
        }
        
        if UserDefaults.standard.integer(forKey: "windSpeedSettings") == 0 {
            windSpeedUnit = "m/s"
        }
        else{
            windSpeedUnit = "mph"
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return countriesArray.count
        default:
            return citiesArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView.tag {
        case 1:
            return countriesArray[row]
        default:
            return citiesArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        switch pickerView.tag {
        case 1:
            return NSAttributedString(string: countriesArray[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        default:
            return NSAttributedString(string: citiesArray[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        showAlert()
        resultLabel.isHidden = false
        
        switch pickerView.tag {
        case 1:
            currentCountriesRow = row
            WeatherDataParser.shared.getCities(country: countriesArray[row], citiesArray: &citiesArray)
            cityPicker.reloadAllComponents()
            cityPicker.selectRow(0, inComponent: 0, animated: false)
            downloadWeatherData(citiesArray[0], countriesArray[currentCountriesRow])
        default:
            downloadWeatherData(citiesArray[row], countriesArray[currentCountriesRow])
        }
    }
}

private extension ViewController{
    
    func downloadWeatherData(_ city: String, _ country: String) { //county must be as code!
        let countryCode = WeatherDataParser.shared.getCountryCode(country: country)
        let urlToCall = "https://api.openweathermap.org/data/2.5/weather?q=\(city),\(countryCode)&units=metric&appid=\(APIsetup.key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let dataURLx = URL(string: urlToCall!)
        print(dataURLx!) //TODO PROBLEM - NIL BY UK!
        if let dataURL = dataURLx{
            let task = URLSession.shared.dataTask(with: dataURL){(data, response, error) in
                
                if error == nil{
                    print("ok")
                    do{
                        let json = try JSON(data: data!)
                        //refactor (always uses numberValue.doubleValue)
                        var temp = json["main"]["temp"].numberValue.doubleValue
                        var pressure = json["main"]["pressure"].numberValue.doubleValue
                        var windSpeed = json["wind"]["speed"].numberValue.doubleValue
                        let lon = (json["coord"]["lon"].numberValue.doubleValue).clean
                        let lat = (json["coord"]["lat"].numberValue.doubleValue).clean
                        var temp_min = json["main"]["temp_min"].numberValue.doubleValue
                        var temp_max = json["main"]["temp_max"].numberValue.doubleValue
                        var sunrise = json["sys"]["sunrise"].numberValue.doubleValue
                        var sunset = json["sys"]["sunset"].numberValue.doubleValue
                        
                        print(sunset)
                        
                        let sunriseDate = Date(timeIntervalSince1970: sunrise)
                        let sunsetDate = Date(timeIntervalSince1970: sunset)
                        
                        func getTime(str: String) -> String{
                            let start = str.index(str.startIndex, offsetBy: 11)
                            let end = str.index(str.endIndex, offsetBy: -6)
                            let range = start..<end
                            return String(str[range])
                        }
                        
                        let sunriseTime = getTime(str: "\(sunriseDate)")
                        let sunsetTime = getTime(str: "\(sunsetDate)")
                        
                        if self.temperatureUnit == "F"{
                            temp = 9/5*temp + 32
                            temp_min = 9/5*temp_min + 32
                            temp_max = 9/5*temp_max + 32
                        }
                        
                        if self.windSpeedUnit == "mph"{
                            windSpeed *= 2.2369
                        }
                        
                        temp = round(temp * 10) / 10
                        pressure = round(pressure * 10) / 10
                        windSpeed = round(windSpeed * 10) / 10
                        
                        //second tab
                        let secondTab = self.tabBarController?.viewControllers?[1] as! MoreViewController
                        secondTab.someNums[0] = "\(lat)" // "Longitude: \(lon)"
                        secondTab.someNums[1] = "\(lon)" //"Latitude: \(lat)"
                        secondTab.someNums[2] = temp_min.clean + " [" + self.temperatureUnit + "]"
                        secondTab.someNums[3] = temp_max.clean + " [" + self.temperatureUnit + "]"
                        secondTab.someNums[4] = "\(sunriseTime)"
                        secondTab.someNums[5] = "\(sunsetTime)"
                        
                        secondTab.city = city
                        secondTab.temp = "\(temp)"
                        
                        DispatchQueue.main.async {
                            
                            if((temp == 0.0) && (pressure == 0.0) && (windSpeed == 0.0)){ //this rule is never true !?
                                self.resultLabel.text = "Data for \(city) not available"
                            }
                            else{
                                self.temperatureLabel.text = ("\(temp) [\(self.temperatureUnit)]")
                                self.pressureLabel.text = ("\(pressure) [hPa]")
                                self.windSpeedLabel.text = ("\(windSpeed) [\(self.windSpeedUnit)]")
                            }
                        }
                    }
                        
                    catch{
                        print("error")
                    }
                }
                else{
                    
                    print("\(error.debugDescription)")
                }
            }
            
            task.resume()
        }
    }
}

//source: https://stackoverflow.com/questions/27153181/how-do-you-make-a-background-image-scale-to-screen-size-in-swift
extension UIView {
    func addBackground() {
        // screen width and height:
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "gradientBg")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }}

//source: https://stackoverflow.com/questions/31390466/swift-how-to-remove-a-decimal-from-a-float-if-the-decimal-is-equal-to-0
extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.2f", self) : String(format: "%.2f", self)
    }
}




