//
//  ViewController.swift
//  OpenBrewery
//
//  Created by Megi Sila on 5.7.23.
//

import UIKit
import CoreLocation
import Alamofire

class BreweriesListVC: UIViewController {
    var breweriesTableView: UITableView!
    var currentPage = 1
    var isFetching = false
    
    var searchController: UISearchController!
    
    let logoImageView: UIView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "app-logo")
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.text = "Open Brewery"
        label.font = .systemFont(ofSize: 35, weight: .bold)
        return label
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()

    var breweriesArray = [Brewery]()
    var filteredBreweriesArray = [Brewery]()
    var isFiltering = false
    
    let locationManager = CLLocationManager()
    var userLatitude: CLLocationDegrees = 0.0
    var userLongitude: CLLocationDegrees = 0.0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLocationManager()
        setupHeader()
        setupSearchController()
        setupBreweriesTableView()
        getBreweriesList(page: 1)
    }
    
    func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()

    }
    
    func setupHeader() {
        view.addSubview(logoImageView)
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            logoImageView.widthAnchor.constraint(equalToConstant: 50),
            logoImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            nameLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            nameLabel.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a city..."
        searchController.searchBar.setValue("Cancel", forKey: "cancelButtonText")
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = .label
        
        searchController.searchBar.backgroundImage = UIImage()
        containerView.backgroundColor = .systemBackground
        containerView.clipsToBounds = true
        searchController.searchBar.clipsToBounds = true
        
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: view.frame.width),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 140),
            containerView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        containerView.addSubview(searchController.searchBar)
        NSLayoutConstraint.activate([
            searchController.searchBar.topAnchor.constraint(equalTo: containerView.topAnchor),
            searchController.searchBar.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            searchController.searchBar.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -20),
            searchController.searchBar.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
    }
    
    func setupBreweriesTableView() {
        breweriesTableView = UITableView(frame: CGRect(x: 10, y: 200, width: view.frame.width - 20, height: view.frame.height + 200))
        breweriesTableView.backgroundColor = .systemBackground
        view.addSubview(breweriesTableView)
        breweriesTableView.dataSource = self
        breweriesTableView.delegate = self
        breweriesTableView.isScrollEnabled = true
        breweriesTableView.separatorStyle = .none

        breweriesTableView.register(BreweryCell.self, forCellReuseIdentifier: "BreweryCell")
    }
    
    func getBreweriesList(page: Int) {
        guard !isFetching else { return }
        isFetching = true
        
        let url = "https://api.openbrewerydb.org/v1/breweries"
        
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
                        self.breweriesArray.append(brewery)
                        
                        self.currentPage += 1
                        self.isFetching = false // To allow subsequent fetches
                    }
                }
            
            DispatchQueue.main.async {
                self.breweriesTableView.reloadData() // Reload collection view data after breweries are fetched
            }
        }
    }
    
    func calculateDistanceFromBrewery(breweryLatitude: String, breweryLongitude: String) -> String {
        if userLatitude != 0.0 && userLongitude != 0.0 {

            let sourceLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)

            if let latitude = Double(breweryLatitude), let longitude = Double(breweryLongitude) {
                let destinationLocation = CLLocation(latitude: latitude, longitude: longitude)
                let distance = sourceLocation.distance(from: destinationLocation)
                let formattedDistance = String(format: "%.2f", distance / 1000)
                return "\(formattedDistance) km away from you"
            } else {
                return "NO DATA"
            }
        } else {
            return "NO DATA"
        }
        
    }
}
