//
//  CollectionListViewController.swift
//  Shopify-Mobile-Intern-Challenge-Summer-2019
//
//  Created by Henry on 2019-01-18.
//  Copyright © 2019 DxStudios. All rights reserved.
//

import UIKit

class CollectionListViewController: UIViewController {
    
    private var tableData : [Collections] = []
    private var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Requests.fetchCollectionList() { collectionList in
            self.tableData = collectionList
            DispatchQueue.main.async { // reload table data in the main thread
                self.tableView.reloadData()
            }
        }
        
        tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInset.top = 10
        
        view.addSubview(tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
}

extension CollectionListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row].title
        return cell
    }
}

extension CollectionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let collectionDetailsVC = CollectionDetailsViewController(
            collectionId: tableData[indexPath.row].id,
            collectionTitle: tableData[indexPath.row].title,
            collectionImgSrc: tableData[indexPath.row].image.src
        )
        navigationController?.pushViewController(collectionDetailsVC, animated: true)
    }
}
