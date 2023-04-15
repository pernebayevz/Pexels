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
    let savedSearchTextArrayKey: String = "savedSearchTextArrayKey"
    var searchTextArray: [String] = [] {
        didSet {
            searchHistoryCollectionView.reloadData()
        }
    }
    
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
        
        // Обращаемся к свойству 'delegate' у 'searchHistoryCollectionView' и присваеваем обьект текущего класса, а именно экземпляр класса MainViewController. Иными словами, перенимаем ответственность, которая находится в протоколе UICollectionViewDelegate. Делается это с целью получения обратной связи, в нашем случае для обнаружения выбора ячейки.
        searchHistoryCollectionView.delegate = self
        
        // Теперь для переопределения значения свойства 'searchTextArray' вызываем метод resetSearchTextArray
        resetSearchTextArray()
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
        save(searchText: searchText)
        
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
    
    func save(searchText: String) {
        var existingArray: [String] = getSavedSearchTextArray()
        existingArray.append(searchText)
        
        UserDefaults.standard.set(existingArray, forKey: savedSearchTextArrayKey)
        
        // Теперь после добавления нового поискового текста вызываем метод resetSearchTextArray(), который извлекает сохраненный список текстовых запросов и присваевает значение свойству 'searchTextArray'
        resetSearchTextArray()
    }
    
    func getSavedSearchTextArray() -> [String] {
        let array: [String] = UserDefaults.standard.stringArray(forKey: savedSearchTextArrayKey) ?? []
        return array
    }
    
    // Новый метод, который вызывает метод getSavedSearchTextArray() для извлечения массива сохраненных текстов и возвращает тот же массив НО уже в обратном порядке
    func getSortedSearchTextArray() -> [String] {
        let savedSearchTextArray: [String] = getSavedSearchTextArray()
        let reversedSavedSearchTextArray: [String] = savedSearchTextArray.reversed()
        return reversedSavedSearchTextArray
    }
    
    // Новый метод, который переопределеяет значение свойства 'searchTextArray' путем присваения полученного значения метода getSortedSearchTextArray()
    func resetSearchTextArray() {
        // Теперь вместо значения метода getSortedSearchTextArray() присваевается значение другого метода getUniqueSearchTextArray()
        self.searchTextArray = getUniqueSearchTextArray()
    }
    
    // Новый метод, который возвращает массив из уникальных текстовых запросов на основе полученного массива с помощью метода getSortedSearchTextArray()
    func getUniqueSearchTextArray() -> [String] {
        
        // Создается константа и устанавливается начальное значение, где присваевается возвращаемое значение методом getSortedSearchTextArray()
        let sortedSearchTextArray: [String] = getSortedSearchTextArray()
        
        // Создается пустая переменная для хранения уникальных текстовых запросов
        var sortedSearchTextArrayWithUniqueValues: [String] = []
        
        // Идет итерация по каждомоу элементу массива 'sortedSearchTextArray'
        sortedSearchTextArray.forEach { searchText in
            
            // Идет проверка на отсутствия элемента в массиве 'sortedSearchTextArrayWithUniqueValues'
            // Метод 'contains' возвращает TRUE если 'searchText' уже содержится в массиве 'sortedSearchTextArrayWithUniqueValues'
            if !sortedSearchTextArrayWithUniqueValues.contains(searchText) {
                sortedSearchTextArrayWithUniqueValues.append(searchText)
            }
        }
        // Возвращает массив с уникальныеми текстами
        return sortedSearchTextArrayWithUniqueValues
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
            return searchTextArray.count
            
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
            cell.set(title: searchTextArray[indexPath.item])
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
        // Теперь отделяем обработку выбора ячейки для соответвующего обьекта UICollectionView, а именно параметра 'collectionView'
        switch collectionView {
        
        case imageCollectionView:
            let photo = self.photos[indexPath.item]
            let url = photo.src.large2X
            
            let vc = ImageScrollViewController(imageURL: url)
            self.navigationController?.pushViewController(vc, animated: true)
            
        case searchHistoryCollectionView:
            // Извлекаем текст из массива 'searchTextArray' c соответсвтующим индексом
            let searchText: String = searchTextArray[indexPath.item]
            // Для свойства 'text' у 'searchBar' присваеваем ранее извлеченный текст
            searchBar.text = searchText
            // Вызываем метод search(), который отправляет запрос для поиска изображений по тексту в поисковой панели
            search()
            
        default:
            ()
        }
    }
}
