//
//  SearchViewController.swift
//  Instagram
//
//  Created by Noy Ishai on 10/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    var searchBar=UISearchBar()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self 
//uI searchbar
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.frame.size.width = view.frame.size.width - 60
        
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
    }
}

//searchBar actions
extension SearchViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchBar.text)
    }
}
