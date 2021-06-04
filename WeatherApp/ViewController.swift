//
//  ViewController.swift
//  WeatherApp
//
//  Created by Zarina Bekova on 5/12/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tempMaxLabel: UILabel!
    @IBOutlet weak var tempMinLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var cloudsLabel: UILabel!
    @IBOutlet weak var weatherStackView: UIStackView!
    @IBOutlet weak var detailsStackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var weatherResult: WeatherResult? // здесь хранятся данные о погоде к-рые мы получили
    var dataTask: URLSessionDataTask?
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        return dateFormatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        cityLabel.text = "Enter city name"
        timeLabel.text = ""
        
        weatherStackView.alpha = 0
        detailsStackView.alpha = 0
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.type = .axial
        gradient.colors = [UIColor.blue.cgColor, UIColor.red.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = view.bounds
        
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    func showWeatherResult() {
        if let weatherResult = weatherResult {
            cityLabel.text = weatherResult.name
            descriptionLabel.text = weatherResult.weather.first?.main ?? "N/A"
            tempLabel.text = "\(Int(weatherResult.main.temp))º"
            tempMaxLabel.text = "\(Int(weatherResult.main.temp_max))℃"
            tempMinLabel.text = "\(Int(weatherResult.main.temp_min))℃"
            feelsLikeLabel.text = "\(Int(weatherResult.main.feels_like))º"
            windLabel.text = "\(weatherResult.wind.speed) m/s"
            humidityLabel.text = "\(weatherResult.main.humidity) %"
            pressureLabel.text = "\(weatherResult.main.pressure) hPa"
            visibilityLabel.text = "\(weatherResult.visibility) m"
            cloudsLabel.text = "\(weatherResult.clouds.all) %"
            timeLabel.text = dateFormatter.string(from: Date())
            
            if let id = weatherResult.weather.first?.id {
                let icon: UIImage
                
                switch id {
                case 200..<300:
                    icon = UIImage(systemName: "cloud.bolt")!
                case 300..<400:
                    icon = UIImage(systemName: "cloud.drizzle")!
                case 500..<600:
                    icon = UIImage(systemName: "cloud.rain")!
                case 600..<700:
                    icon = UIImage(systemName: "cloud.snow")!
                case 700..<800:
                    icon = UIImage(systemName: "cloud.fog")!
                case 800:
                    icon = UIImage(systemName: "sun.max")!
                case 801, 802:
                    icon = UIImage(systemName: "cloud.sun")!
                case 803:
                    icon = UIImage(systemName: "cloud")!
                case 804:
                    icon = UIImage(systemName: "smoke")!
                default:
                    icon = UIImage(systemName: "questionmark")!
                    
                }
                
                iconImageView.image = icon
            }
            
            UIView.animate(withDuration: 0.3) {
                self.weatherStackView.alpha = 1
                self.detailsStackView.alpha = 1
            }
           
        }
        
    }
    
    func weatherURL(searchText: String) -> URL { // функ-я, к-рая получает URL
        let encoded = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encoded!)&appid=d1ccb5ac56a15316b87065c694d56b80&units=metric"
        
        return URL(string: urlString)!
    }
    
    func parse(data: Data) -> WeatherResult? {
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(WeatherResult.self, from: data)
            return result
        } catch {
            print("JSON parsing Error: \(error.localizedDescription)")
            return nil
        }
        
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Error", message: "There was an error accessing the weather data. Please try again.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func performSearch() {
        
        UIView.animate(withDuration: 0.3) {
            self.weatherStackView.alpha = 0
            self.detailsStackView.alpha = 0
        }
        
        activityIndicator.startAnimating()
        searchBar.resignFirstResponder()
        weatherResult = nil
        dataTask?.cancel()
        
        let url = weatherURL(searchText: searchBar.text!)
        let session = URLSession.shared
        dataTask = session.dataTask(with: url) { (data, response, error) in
            if let error = error as NSError?, error.code == -999 {
                return
            } else if let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                self.weatherResult = self.parse(data: data)
                
                DispatchQueue.main.async {
                    self.showWeatherResult()
                    self.activityIndicator.stopAnimating()
                }
            } else {
                print("ERROR")
                
                DispatchQueue.main.async {
                    self.showNetworkError()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        
        dataTask?.resume()
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }
    
}

// Key = d1ccb5ac56a15316b87065c694d56b80

