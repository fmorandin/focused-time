//
//  NetworkManager.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 27/07/2021.
//

import Foundation

/// Despite it is called network, at this point, the app has no network calls.
/// This is used, for now, only for UserDefault but its ideia is to be an abstraction
/// preparing for a usage of CloudKit or Firebase
struct NetworkManager {

    // MARK: - Private Variables

    private let defaults = UserDefaults.standard

    // MARK: - Methods

    func save(value: Int, for keyName: String) {
        defaults.set(value, forKey: keyName)
    }

    func save(value: String, for keyName: String) {
        defaults.set(value, forKey: keyName)
    }

    func save(value: Bool, for keyName: String) {
        defaults.set(value, forKey: keyName)
    }

    func save(value: Date, for keyName: String) {
        defaults.set(value, forKey: keyName)
    }

    func getValue(for keyName: String) -> Int {
        defaults.integer(forKey: keyName)
    }

    func getValue(for keyName: String) -> String {
        defaults.string(forKey: keyName) ?? ""
    }

    func getValue(for keyName: String) -> Bool {
        defaults.bool(forKey: keyName)
    }

    func getValue(for keyName: String) -> Date? {
        defaults.value(forKey: keyName) as? Date
    }
}
