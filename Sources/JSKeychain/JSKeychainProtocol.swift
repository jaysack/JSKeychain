//
//  JSKeychainProtocol.swift
//  JSKeychain
//
//  Created by Jonathan Sack on 3/14/24.
//

import Foundation

public protocol JSKeychainProtocol: AnyObject {
    func create(_ data: Data, service: String, account: String, class: CFString) throws
    func read(service: String, account: String, class: CFString) throws -> Data?
    func update(_ data: Data, service: String, account: String, class: CFString) throws
    func delete(service: String, account: String, class: CFString) throws
}
