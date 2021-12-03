//
//  UIUpdatesOnMain.swift
//
//  Created by Ravikant Kumar on 03/12/21.
//

import Foundation

func performUIUpdatesOnMain(updates: @escaping () -> Void) {
    DispatchQueue.main.async() {
        updates()
    }
}
