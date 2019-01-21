//
//  ProductCollectionViewCell.swift
//  Shopify-Mobile-Intern-Challenge-Summer-2019
//
//  Created by Henry on 2019-01-21.
//  Copyright © 2019 DxStudios. All rights reserved.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    
    var nameLabel = UILabel()
    var inventoryCountLabel = UILabel()
    var descriptionLabel = UILabel()
    var collectionTitleLabel = UILabel()
    var collectionImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        descriptionLabel.font = UIFont.italicSystemFont(ofSize: 18)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(inventoryCountLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(collectionTitleLabel)
        contentView.addSubview(collectionImageView)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configure() {
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
        }
        inventoryCountLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel)
            make.trailing.equalToSuperview().offset(-10)
        }
        collectionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(inventoryCountLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(10)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionTitleLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        collectionImageView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom)
            make.centerX.bottom.equalToSuperview()
            make.height.lessThanOrEqualTo(150)
            make.width.lessThanOrEqualTo(150)
        }
    }
}
