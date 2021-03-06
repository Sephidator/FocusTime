//
//  SetLanguageCell.swift
//  FocusHour
//
//  Created by Midrash Elucidator on 2019/2/12.
//  Copyright © 2019 Midrash Elucidator. All rights reserved.
//

import UIKit

class SetLanguageVC: UITableViewController {

    var languages: [LanguageKey] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITool.setBackgroundImage(view, random: false)
        navigationItem.title = LocalizationKey.SetLanguage.translate()
        languages = LanguageKey.getKeyList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // change background image
        UITool.setBackgroundImage(tableView, imageName: Theme.getCurrentTheme().backgroundImage)
        self.navigationController?.navigationBar.barTintColor = Theme.getCurrentTheme().themeColor
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SetLanguageCell", for: indexPath) as! SetLanguageCell
        let language = languages[indexPath.row]
        cell.language = language
        cell.setSelected(language.isSystemLanguage())        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        LocalizationTool.setSystemLanguage(languages[indexPath.row])
        self.navigationItem.title = LocalizationKey.SetLanguage.translate()
        for tableCell in self.tableView.visibleCells {
            let cell = tableCell as! SetLanguageCell
            cell.setSelected(cell.language.isSystemLanguage())
        }
    }
}
