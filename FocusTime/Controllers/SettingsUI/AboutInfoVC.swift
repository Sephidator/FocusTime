//
//  AboutInfo.swift
//  FocusTime
//
//  Created by Midrash Elucidator on 2019/2/12.
//  Copyright © 2019 Midrash Elucidator. All rights reserved.
//

import UIKit

class AboutInfoVC: UIViewController {

    @IBOutlet weak var textArea: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        UITool.setBackgroundImage(view, random: false)
        self.navigationItem.title = SettingEnum.About.translate()
        let description = LocalizationKey.Description.translate()
        let aboutMe = LocalizationKey.AboutMe.translate()
        textArea.text = "\(description)\n\n\(aboutMe)"
    }
    

}
