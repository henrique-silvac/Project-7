//
//  ViewController.swift
//  Project 7
//
//  Created by Henrique Silva on 20/07/21.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "CREDITS", style: .plain, target: self, action: #selector(showCredits))
        let filteredButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterPetition))
        let resetButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(resetList))
        navigationItem.leftBarButtonItems = [filteredButton, resetButton]
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url)  {
                    //we're OK to parse
                    self?.parse(json: data)
                    return
                }
            }
        }
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Data source", message: "These petitions come from the: \nWe The People API of the Whitehouse.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(ac, animated: true)
    }
    
    @objc func filterPetition() {
        let ac = UIAlertController(title: "Search for Petition", message: "Enter your search here.", preferredStyle: .alert)
        ac.addTextField()

        let filterAction = UIAlertAction(title: "Filter", style: .default) {
            [weak self, weak ac] _ in
            guard let filterWord = ac?.textFields?[0].text else { return }
            self?.submit(filterWord)
        }
        
        ac.addAction(filterAction)
        present(ac, animated: true)
    }
    
    @objc func resetList(action: UIAlertAction) {
        filteredPetitions = petitions
        tableView.reloadData()
    }
    
    func submit(_ answer: String) {
        filteredPetitions = filteredPetitions.filter { $0.title.contains(answer) }
        self.tableView.reloadData()
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

