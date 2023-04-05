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
    
    var searchPhotosResponse: SearchPhotosResponse? {
        didSet {
            DispatchQueue.main.async {
                self.imageCollectionView.reloadData()
            }
        }
    }
    var photos: [Photo] {
        return searchPhotosResponse?.photos ?? []
    }
    var searchHistoryManager = SearchHistoryManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Pexels"
        
        searchBar.delegate = self
        
        // Image CollectionView SETUP
        imageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        imageCollectionView.register(UINib(nibName: PhotoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.refreshControl = UIRefreshControl()
        imageCollectionView.refreshControl!.addTarget(self, action: #selector(search), for: .valueChanged)
        
        // Search History CollectionView SETUP
        let flowLayout = searchHistoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        searchHistoryCollectionView.register(UINib(nibName: SearchTextCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: SearchTextCollectionViewCell.identifier)
        searchHistoryCollectionView.dataSource = self
        
        searchHistoryManager.delegate = self
    }

    @objc
    func search() {
        self.searchPhotosResponse = nil
        
        guard let searchText = searchBar.text else {
            print("Search bar text is nil")
            return
        }
        guard !searchText.isEmpty else {
            print("Search bar text is empty")
            return
        }
        
        // Save Searching Text
        searchHistoryManager.save(searchText: searchText)
        
        let endpoint: String = "https://api.pexels.com/v1/search"
        guard var urlComponents = URLComponents(string: endpoint) else {
            print("Couldn't create URLComponents instance from endpoint - \(endpoint)")
            return
        }
        
        let parameters = [
            URLQueryItem(name: "query", value: searchText),
            URLQueryItem(name: "per_page", value: "20")
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
        
        if imageCollectionView.refreshControl?.isRefreshing == false {
            imageCollectionView.refreshControl?.beginRefreshing()
        }
        
        let urlSession: URLSession = URLSession(configuration: .default)
        let dataTask: URLSessionDataTask = urlSession.dataTask(with: urlRequest, completionHandler: searchPhotosHandler(data:urlResponse:error:))
        
        dataTask.resume()
//        dataTask.cancel()
    }
    
    func searchPhotosHandler(data: Data?, urlResponse: URLResponse?, error: Error?) {
        print("Method searchPhotosHandler was called")
        
        DispatchQueue.main.async {
            if self.imageCollectionView.refreshControl?.isRefreshing == true {
                self.imageCollectionView.refreshControl?.endRefreshing()
            }
        }
        
        if let error = error {
            
            print("Search Photos endpoint error - \(error.localizedDescription)")
            
        } else if let data = data {
            
            do {
             
//                let jsonObject = try JSONSerialization.jsonObject(with: data)
//                print("Search Photos endpoint jsonObject - \(jsonObject)")
                let searchPhotosResponse = try JSONDecoder().decode(SearchPhotosResponse.self, from: data)
                print("Search Photos endpoint searchPhotosResponse - \(searchPhotosResponse)")
                self.searchPhotosResponse = searchPhotosResponse
                
            } catch let error {
                print("Search Photos endpoint serialization error - \(error.localizedDescription)")
            }
            
        }
        
        if let urlResponse = urlResponse, let httpResponse = urlResponse as? HTTPURLResponse {
            
            print("Search Photos endpoint http response status code - \(httpResponse.statusCode)")
            
        }
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

extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case imageCollectionView:
            return photos.count
            
        case searchHistoryCollectionView:
            return searchHistoryManager.searchHistory.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case imageCollectionView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
            cell.setup(photo: self.photos[indexPath.item])
            return cell
            
        case searchHistoryCollectionView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchTextCollectionViewCell.identifier, for: indexPath) as! SearchTextCollectionViewCell
            let searchText = searchHistoryManager.searchHistory[indexPath.item]
            cell.titleLabel.text = searchText
            cell.set(title: searchText)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout: UICollectionViewFlowLayout?  = collectionViewLayout as? UICollectionViewFlowLayout
        let horizontalSpacing: CGFloat = ( flowLayout?.minimumInteritemSpacing ?? 0 ) + collectionView.contentInset.left + collectionView.contentInset.right
        let width: CGFloat = ( collectionView.frame.width - horizontalSpacing ) / 2
        let height: CGFloat = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photo = self.photos[indexPath.item]
        let url = photo.src.large2X
        
        let vc = ImageScrollViewController(imageURL: url)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainViewController: SearchHistoryManagerDelegate {
    
    func searchHistoryValueChanged() {
        searchHistoryCollectionView.reloadData()
    }
}
