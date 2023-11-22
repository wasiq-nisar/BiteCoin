//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate{
    func didUpdateCurrency(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "78DBDA3B-7F3D-43B9-8676-FC61BE4FD843"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String){
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString, currency: currency)
    }
    
    func performRequest(with urlString: String, currency: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                if (error != nil){
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let data = data {
                    if let coinPrice = parseJSON(data) {
                        let price = String(format: "%.2f", coinPrice)
                        delegate?.didUpdateCurrency(price: price, currency: currency)
                    }
                }
            })
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> Double?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: weatherData)
            return decodedData.rate
        }
        catch{
            delegate?.didFailWithError(error: error)
            return  nil
        }
    }
}
