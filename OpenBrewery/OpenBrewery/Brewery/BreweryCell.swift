//
//  BreweryCell.swift
//  OpenBrewery
//
//  Created by Megi Sila on 5.7.23.
//

import UIKit

class BreweryCell: UITableViewCell {
    static let cellId = "BreweryCell"
    let padding: CGFloat = 10
    var brewery: Brewery!
    
    let cellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(cellView)
        cellView.addSubview(nameLabel)
        cellView.addSubview(locationLabel)
        cellView.addSubview(distanceLabel)
        
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            
            nameLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: padding),
            nameLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: padding),
            nameLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -padding),
            nameLabel.heightAnchor.constraint(equalToConstant: 25),
            
            locationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2 * padding),
            locationLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: padding),
            locationLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -padding),
            locationLabel.heightAnchor.constraint(equalToConstant: 25),
            
            distanceLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: padding),
            distanceLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: padding),
            distanceLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -padding),
            distanceLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
        
    }
}
