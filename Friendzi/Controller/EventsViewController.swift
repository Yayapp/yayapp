//
//  EventsViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 27.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
protocol EventChangeDelegate : NSObjectProtocol {
    func eventCreated(event:Event)
    func eventChanged(event:Event)
    func eventRemoved(event:Event)
}

class EventsViewController: UIViewController, EventChangeDelegate {
    var eventsData:[Event]=[]

    weak var delegate:ListEventsDelegate?

    func reloadAll(events:[Event]) {
    }
 
    func eventCreated(event: Event) {
    }

    func eventChanged(event:Event) {
    }

    func eventRemoved(event:Event) {
    }
}
