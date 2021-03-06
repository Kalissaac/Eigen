//
// MatrixModel.swift
// Eigen
//
        

import Foundation
import SwiftUI
import MatrixSDK

enum MatrixCredentialValidationError: Error {
    case invalidHomeserver
    case invalidUsername
    case invalidAccessToken
    case invalidDeviceId
}

enum MatrixAuthenticationStatus {
    case authenticated
    case notAuthenticated
    case loading
    case error
}

class MatrixModel: ObservableObject {
    @Published var session = MXSession()
    @Published var store = MXFileStore()
    @Published var authenticationStatus: MatrixAuthenticationStatus = .loading
    @Published var preferences = MatrixPreferences()

    init(withCredentials credentials: MXCredentials) {
        login(withCredentials: credentials)
    }

    init() {
        if MatrixModel.credentialsAreIntact() {
            login()
        } else {
            authenticationStatus = .notAuthenticated
        }
    }

    func login() {
        let defaults = UserDefaults.standard
        let homeserver = defaults.string(forKey: "homeserver") ?? "https://matrix.org"
        let username = defaults.string(forKey: "username")!
        let accessTokenData = try! Keychain.readPassword(service: homeserver, account: username)
        let accessToken = String(data: accessTokenData, encoding: .utf8)!
        let credentials = MXCredentials(homeServer: homeserver, userId: username, accessToken: accessToken)
        credentials.deviceId = defaults.string(forKey: "deviceId")!
        login(withCredentials: credentials)
    }

    func login(withCredentials credentials: MXCredentials, savingToKeychain saveToKeychain: Bool = false) {
        let restClient = MXRestClient(credentials: credentials, unrecognizedCertificateHandler: nil)
        guard let _session = MXSession(matrixRestClient: restClient) else {
            authenticationStatus = .error
            return
        }
        session = _session
        authenticationStatus = .authenticated

        if saveToKeychain {
            let defaults = UserDefaults.standard
            defaults.set(credentials.homeServer, forKey: "homeserver")
            defaults.set(credentials.userId, forKey: "username")
            try? Keychain.save(password: credentials.accessToken!.data(using: .utf8)!, service: credentials.homeServer!, account: credentials.userId!)
            defaults.set(credentials.deviceId, forKey: "deviceId")
        }
    }

    func logout() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "homeserver")
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: "deviceId")
        if let homeserver = session.credentials.homeServer, let username = session.credentials.userId {
            try? Keychain.deletePassword(service: homeserver, account: username)
        }
        if session.crypto != nil {
            session.crypto.deleteStore { }
        }
        if session.store != nil {
            session.store.deleteAllData()
        }
        session.logout { _ in }
        authenticationStatus = .notAuthenticated
    }

    static func credentialsAreIntact() -> Bool {
        do {
            let defaults = UserDefaults.standard

            guard let homeserver = defaults.string(forKey: "homeserver") else {
                throw MatrixCredentialValidationError.invalidHomeserver
            }

            guard let username = defaults.string(forKey: "username") else {
                throw MatrixCredentialValidationError.invalidUsername
            }

            guard let accessTokenData = try? Keychain.readPassword(service: homeserver, account: username) else {
                throw MatrixCredentialValidationError.invalidAccessToken
            }

            guard String(data: accessTokenData, encoding: .utf8) != nil else {
                throw MatrixCredentialValidationError.invalidAccessToken
            }

            guard defaults.string(forKey: "deviceId") != nil else {
                throw MatrixCredentialValidationError.invalidDeviceId
            }

            return true
        } catch {
            return false
        }
    }
}

struct MatrixPreferences {
    @UserDefaultsStorage(key: "showRoomMemberEvents", defaultValue: true)
    var showRoomMemberEvents: Bool
}
