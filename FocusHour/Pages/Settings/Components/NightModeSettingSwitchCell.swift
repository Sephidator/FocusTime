//
//  NightModeSettingSwitchCell.swift
//  FocusHour
//
//  Created by 賴健明 on 2019/6/12.
//  Copyright © 2019 Midrash Elucidator. All rights reserved.
//

import UIKit

class NightModeSettingSwitchCell: SettingSwitchCell {
    
    
    @IBAction override func SwitchMode(_ sender: Any) {
        super.SwitchMode(sender)
        (self.tableViewController as! SettingsVC).handleNightModeChange()
    }
    
}
