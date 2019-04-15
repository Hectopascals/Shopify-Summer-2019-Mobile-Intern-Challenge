//
//  Requests.swift
//  Shopify-Mobile-Intern-Challenge-Summer-2019
//
//  Created by Henry on 2019-01-21.
//  Copyright © 2019 DxStudios. All rights reserved.
//

import Foundation

struct Constants {
    static let websitePrefix = "https://shopicruit.myshopify.com/admin/"
    static let websiteSuffix = "&page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
}

// MARK: - Decodable Structs
struct Variant: Decodable {
    let inventory_quantity: Int
}

struct Product: Decodable {
    let title: String
    let body_html: String
    let variants: [Variant]
    let image: Image
}

struct ProductList: Decodable {
    let products: [Product]
}

struct Collects: Decodable {
    let product_id: Int
}

// list of product id's
struct CollectsList: Decodable {
    let collects: [Collects]
}

struct Image: Decodable {
    let src: String
}

struct Collections: Decodable {
    let id: Int
    let title: String
    let image: Image
}

struct CollectionList: Decodable {
    let custom_collections: [Collections]
}

struct Requests {
    // MARK: - Helpers
    static func createURL(typeOfRequest: String, urlBody: String?) -> URL? {
        if let urlBody = urlBody {
            return URL(string: Constants.websitePrefix + typeOfRequest + ".json?" + urlBody + Constants.websiteSuffix)
        } else {
            return URL(string: Constants.websitePrefix + typeOfRequest + ".json?" + Constants.websiteSuffix)
        }
    }
    
    static func getCustomCollections(data: Data) -> [Collections] {
        do {
            let collectionList = try JSONDecoder().decode(CollectionList.self, from: data)
            return (collectionList.custom_collections)
        } catch let jsonErr {
            print("Error serializing JSON for CollectionList:", jsonErr)
            return []
        }
    }
    
    static func getProductIds(data: Data) -> String {
        do {
            let collectList = try JSONDecoder().decode(CollectsList.self, from: data)
            return collectList.collects.compactMap({String($0.product_id)}).joined(separator: ",")
        } catch let jsonErr {
            print("Error serializing JSON for Collects:", jsonErr)
            return ""
        }
    }
    
    static func getProducts(data: Data) -> [Product] {
        do {
            let productList = try JSONDecoder().decode(ProductList.self, from: data)
            return (productList.products)
        } catch let jsonErr {
            print("Error serializing JSON for ProductList:", jsonErr)
            return []
        }
    }
    
    static func responseSuccess(data: Data?, response: URLResponse?, error: Error?) -> Bool {
        if let error = error {
            handleClientError(error:error)
            return false
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode),
            let mimeType = httpResponse.mimeType,
            mimeType == "application/json",
            let _ = data else {
                handleServerError()
                return false
        }
        return true
    }
    
    static func handleClientError(error: Error) {
        print("Transport error occurred", error)
    }
    
    static func handleServerError() {
        print("Server error occurred")
    }
    
    // MARK: - Fetch Functions
    static func fetchCollectionList(completion: @escaping([Collections])->()) {
        guard let url = createURL(typeOfRequest: "custom_collections", urlBody: nil) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if responseSuccess(data: data, response: response, error: error) {
                guard let data = data else {
                    return
                }
                completion(getCustomCollections(data: data))
            }
        }
        task.resume()
    }
    
    static func fetchProductsFromCollects(collectionId: Int, completion: @escaping([Product])->()) {
        guard let url = createURL(typeOfRequest: "collects", urlBody: "collection_id=" + String(collectionId)) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if responseSuccess(data: data, response: response, error: error) {
                guard let data = data else {
                    return
                }
                
                // Fetch a list of Products given product id's (as data)
                fetchProducts(productIds: getProductIds(data: data)) { products in
                    completion(products)
                }
            }
        }
        task.resume()
    }
    
    // Fetches a list of products, implicitly called via fetchProductsFromCollects
    static func fetchProducts(productIds: String, completion: @escaping([Product])->()) {
        guard let url = createURL(typeOfRequest: "products", urlBody: "ids=" + productIds) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if responseSuccess(data: data, response: response, error: error) {
                guard let data = data else {
                    return
                }
                completion(getProducts(data: data))
            }
        }
        task.resume()
    }
}
