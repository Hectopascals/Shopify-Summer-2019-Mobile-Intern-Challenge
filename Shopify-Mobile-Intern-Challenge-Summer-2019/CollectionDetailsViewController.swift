//
//  CollectionDetailsViewController.swift
//  Shopify-Mobile-Intern-Challenge-Summer-2019
//
//  Created by Henry on 2019-01-18.
//  Copyright © 2019 DxStudios. All rights reserved.
//

import UIKit
import SnapKit

struct ProductInfo {
    let productName: String
    let productInventory: Int
    let productDescription: String
    let collectionTitle: String
    let collectionImageURL: String
    
    init(productName: String,
         productInventory: Int,
         productDescription: String,
         collectionTitle: String,
         collectionImageURL: String
        ) {
        self.productName = productName
        self.productInventory = productInventory
        self.productDescription = productDescription
        self.collectionTitle = collectionTitle
        self.collectionImageURL = collectionImageURL
    }
}

class CollectionDetailsViewController: UIViewController {
    
    private var collectionId: Int = 0
    private var collectionTitle: String = ""
    private var collectionImageSrc: String = ""
    private var products: [ProductInfo] = []
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    init(collectionId: Int, collectionTitle: String, collectionImgSrc: String) {
        self.collectionId = collectionId
        self.collectionTitle = collectionTitle
        self.collectionImageSrc = collectionImgSrc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 300)
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: "collectionViewCell")
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self

        Requests.fetchProductsFromCollects(collectionId: collectionId) { products in
            self.products = products.compactMap({
                ProductInfo(
                    productName: $0.title,
                    productInventory: $0.variants.compactMap({$0.inventory_quantity}).reduce(0, +),
                    productDescription: $0.body_html,
                    collectionTitle: self.collectionTitle,
                    collectionImageURL: $0.image.src)
            })
            
            // Reload data in main thread
            DispatchQueue.main.async {
                collectionView.reloadData()
            }
        }
        view.addSubview(collectionView)
    }
}

extension CollectionDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! ProductCollectionViewCell
        cell.nameLabel.text = products[indexPath.row].productName
        cell.inventoryCountLabel.text = "Inventory: \(String(products[indexPath.row].productInventory))"
        cell.descriptionLabel.text = products[indexPath.row].productDescription
        cell.collectionTitleLabel.text = products[indexPath.row].collectionTitle
        
        // Load image from URL
        if let url = URL(string: products[indexPath.row].collectionImageURL) {
            // dont block the UI thread
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        cell.collectionImageView.contentMode = .scaleAspectFit
                        cell.collectionImageView.image = UIImage(data: data)
                    }
                } catch let dataError {
                    print("Error unwrapping Data of URL:", dataError)
                }
            }
        }
        return cell
    }
}
