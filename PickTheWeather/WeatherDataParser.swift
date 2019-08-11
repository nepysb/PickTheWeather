//
//  WeatherDataParser.swift
//  WeatherDataScrollView
//
//  Created by Beniamin on 17.06.19.
//  Copyright © 2019 Beniamin. All rights reserved.
//

import Foundation
import SwiftyJSON

//Helper class for parsing JSON
class WeatherDataParser{
    static let shared = WeatherDataParser()
    
    private init(){}
    
    func getCountriesList(countriesArray: inout [String]){
        
        if let path = Bundle.main.path(forResource: "countries", ofType: "json"){
            do{
                let json = try JSON(Data(contentsOf: URL(fileURLWithPath: path)))
                for (key,_):(String, JSON) in json {
                    countriesArray.append(key)
                }
                countriesArray.sort()
            }
            catch{
                print("error")
            }
        }
        else{
            print("no path")
            
        }
    }
    
    func getCities(country: String, citiesArray: inout [String]){
        citiesArray.removeAll()
        if let path = Bundle.main.path(forResource: "countries", ofType: "json"){
            do{
                let json = try JSON(Data(contentsOf: URL(fileURLWithPath: path)))
                let ct =  json[country].arrayValue.map({ $0.stringValue})
                for city in ct{
                        citiesArray.append(city)
                }
                citiesArray.sort()
            }
            catch{
                print("error")
            }
        }
    }
    
    func getCountryCode(country: String) -> String{
        var code = ""
        if let path = Bundle.main.path(forResource: "countryCodes", ofType: "json"){
            do{
                let json = try JSON(Data(contentsOf: URL(fileURLWithPath: path)))

                for (key,_):(String, JSON) in json {
                    if (json[Int(key)!]["name"].stringValue == country){
                        code = json[Int(key)!]["code"].stringValue
                    }
                }
            }
            catch{
                print("error")
            }
        }
        else{
            print("no path")

        }
        return code
    }
    
    private func isSingleTerm(city: String) -> Bool{
        if city.contains(" "){
            return false
        }
        return true
    }
    
}
