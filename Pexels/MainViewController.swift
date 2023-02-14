//
//  MainViewController.swift
//  Pexels
//
//  Created by Zhangali Pernebayev on 04.01.2023.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchHistoryCollectionView: UICollectionView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Pexels"
        
        searchBar.delegate = self
    }

    func search() {
        guard let searchText = searchBar.text else {
            print("Search bar text is nil")
            return
        }
        guard !searchText.isEmpty else {
            print("Search bar text is empty")
            return
        }
        
        let endpoint: String = "https://api.pexels.com/v1/search"
        guard var urlComponents = URLComponents(string: endpoint) else {
            print("Couldn't create URLComponents instance from endpoint - \(endpoint)")
            return
        }
        
        let parameters = [
            URLQueryItem(name: "query", value: searchText),
            URLQueryItem(name: "per_page", value: "10")
        ]
        urlComponents.queryItems = parameters
        
        guard let url: URL = urlComponents.url else {
            print("URL is nil")
            return
        }
        
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
//        urlRequest.httpMethod = "POST"
        
        let APIKey: String = "eRuBLRfaaqosXXTtvxQJIMBBZOHa9wl2FEWiZzROyfNHdB8glUVqUvtT"
        urlRequest.addValue(APIKey, forHTTPHeaderField: "Authorization")
        
//        let parameters: [String: Any] = [
//            "query": searchText,
//            "per_page": 10
//        ]
//        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let urlSession: URLSession = URLSession(configuration: .default)
        let dataTask: URLSessionDataTask = urlSession.dataTask(with: urlRequest, completionHandler: searchPhotosHandler(data:urlResponse:error:))
        
        dataTask.resume()
//        dataTask.cancel()
    }
    
    func searchPhotosHandler(data: Data?, urlResponse: URLResponse?, error: Error?) {
        print("Method searchPhotosHandler was called")
    }
}

extension MainViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search()
    }
}
