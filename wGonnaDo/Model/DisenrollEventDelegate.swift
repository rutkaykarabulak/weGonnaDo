//
//  DisenrollEventDelegate.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 24.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
// With this delegate whenever user disenroll hisself from an event, viewDidLoad will trigger.
protocol DisenrollEventDelegate{
    func didTriggerTableViewReload()
}
