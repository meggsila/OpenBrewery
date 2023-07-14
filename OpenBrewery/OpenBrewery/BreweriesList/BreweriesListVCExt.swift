//
//  BreweriesListVCExt.swift
//  OpenBrewery
//
//  Created by Megi Sila on 5.7.23.
//

import UIKit
import CoreLocation
import Alamofire

//MARK: - UITableView extensions
extension BreweriesListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering  {
            return filteredBreweriesArray.count
        } else {
            return breweriesArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BreweryCell.cellId, for: indexPath as IndexPath) as? BreweryCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        let brewery: Brewery!
        if isFiltering {
            brewery = filteredBreweriesArray[indexPath.row]
        } else {
            brewery = breweriesArray[indexPath.row]
        }
        
        cell.brewery = brewery
        cell.nameLabel.text = brewery.name
        
        let symbolSize = CGFloat(20)
        let symbolColor = UIColor.systemOrange
        
        let locationSymbolName = "mappin"
        let locationString = "\(brewery.street), \(brewery.city), \(brewery.state)"
        let attributedLocationString = locationString.attributedStringWithSFIcon(systemName: locationSymbolName, size: symbolSize, color: symbolColor)
        cell.locationLabel.attributedText = attributedLocationString
        
        let distanceSymbolName = "location.fill"
        let distanceString = calculateDistanceFromBrewery(breweryLatitude: cell.brewery.latitude, breweryLongitude: cell.brewery.longitude)
        let attributedDistanceString = distanceString.attributedStringWithSFIcon(systemName: distanceSymbolName, size: symbolSize, color: symbolColor)
        cell.distanceLabel.attributedText = attributedDistanceString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRowIndex && !isFetching {
            currentPage += 1
            getBreweriesList(page: currentPage)
        }
    }
}

//MARK: - UISearchBar extensions
extension BreweriesListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            isFiltering = true
            filteredBreweriesArray.removeAll()
            getBreweriesByCity(city: searchText)
        } else {
            isFiltering = false
        }
        breweriesTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = false
        filteredBreweriesArray.removeAll()
        breweriesTableView.reloadData()
    }
    
    func getBreweriesByCity(city: String) {
        let url = "https://api.openbrewerydb.org/v1/breweries?by_city=\(city)"
        
        AF.request(url, method: .get).responseJSON { (response: DataResponse) in
                switch response.result {
                case .failure:
                    let networkErrorAlert = UIAlertController(title: "Network Error", message: "Something wrong happened", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                        self.dismiss(animated: true)
                    }
                    networkErrorAlert.addAction(okAction)
                    self.present(networkErrorAlert, animated: true, completion: nil)
                case .success(let data):
                    guard let data = data as? [[String: Any]] else {
                        return
                    }
                    
                    for item in data {
                        let brewery = Brewery(
                            name: item["name"] as? String ?? "",
                            street: item["street"] as? String ?? "",
                            city: item["city"] as? String ?? "",
                            state: item["state"] as? String  ?? "",
                            longitude: item["longitude"] as? String ?? "",
                            latitude: item["latitude"] as? String ?? ""
                        )
                        self.filteredBreweriesArray.append(brewery)
                    }
                }
            
            DispatchQueue.main.async {
                self.breweriesTableView.reloadData() // Reload collection view data after breweries are fetched
            }
        }
    }
}

//MARK: - CLLocationManager extension
extension BreweriesListVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        if let userLocation = locations.last {
            userLatitude = userLocation.coordinate.latitude
            userLongitude = userLocation.coordinate.longitude
            
            breweriesTableView.reloadData()
        }
    }
}

extension String {
    func attributedStringWithSFIcon(systemName: String, size: CGFloat, color: UIColor) -> NSAttributedString? {
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: size)
        let symbol = UIImage(systemName: systemName, withConfiguration: symbolConfiguration)

        let attributedString = NSMutableAttributedString()

        if let symbolImage = symbol {
            let attachment = NSTextAttachment()
            attachment.image = symbolImage
            attachment.bounds = CGRect(x: 0, y: -2, width: size, height: size)

            let imageWithColor = symbolImage.withTintColor(color, renderingMode: .alwaysOriginal)
            attachment.image = imageWithColor

            let symbolAttributedString = NSAttributedString(attachment: attachment)
            attributedString.append(symbolAttributedString)
        }

        attributedString.append(NSAttributedString(string: self))

        return attributedString
    }
}



