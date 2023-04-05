//
//  SearchHistoryManager.swift
//  Pexels
//
//  Created by Zhangali Pernebayev on 13.03.2023.
//

import Foundation

protocol SearchHistoryManagerDelegate {
    func searchHistoryValueChanged()
}

struct SearchHistoryManager {
    
    let savedSearchTextArrayKey: String = "savedSearchTextArrayKey"
    var searchHistory: [String] {
        return fetchSearchHistory()
    }
    var delegate: SearchHistoryManagerDelegate?
    
    func fetchSearchHistory() -> [String] {
        var array: [String] = UserDefaults.standard.stringArray(forKey: savedSearchTextArrayKey) ?? []
        array.reverse()
        return array
    }
    
    func save(searchText: String) {
        var existingSearchHistory: [String] = fetchSearchHistory()
        existingSearchHistory.append(searchText)
        
        UserDefaults.standard.set(existingSearchHistory, forKey: savedSearchTextArrayKey)
        
        // Notify search history change
        delegate?.searchHistoryValueChanged()
    }
}
