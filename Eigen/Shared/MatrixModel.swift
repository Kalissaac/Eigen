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

enum MatrixSyncStatus {
    case complete
    case inProgress
    case initialSync // initial sync in progress, can take a while
}

let KEYCHAIN_SERVICE = "Eigen"

class MatrixModel: ObservableObject {
    typealias MatrixAccount = [String : String]

    @Published var session = MXSession()
    @Published var store = MXFileStore()
    @Published var authenticationStatus: MatrixAuthenticationStatus = .loading
    @Published var syncStatus: MatrixSyncStatus = .inProgress
    @Published var preferences = MatrixPreferences()

    init(withCredentials credentials: MXCredentials) {
        login(withCredentials: credentials)
    }

    init() {
        MatrixModel.migrateCredentials()
        if MatrixModel.credentialsAreIntact() {
            login()
        } else {
            authenticationStatus = .notAuthenticated
        }
    }

    func login(withUsername username: String? = nil) {
        let defaults = UserDefaults.standard
        guard let accounts = defaults.array(forKey: "accounts") as? [MatrixAccount] else { return }
        guard let username = username ?? defaults.string(forKey: "lastUsername") ?? accounts.first?["username"] else { return }
        guard let accountMetadata = accounts.first(where: { $0["username"] == username }) else { return }
        guard let homeserver = accountMetadata["homeserver"] else { return }
        guard let deviceId = accountMetadata["deviceId"] else { return }
        guard let accessTokenData = try? Keychain.readPassword(service: KEYCHAIN_SERVICE, account: username) else { return }
        guard let accessToken = String(data: accessTokenData, encoding: .utf8) else { return }

        let credentials = MXCredentials(homeServer: homeserver, userId: username, accessToken: accessToken)
        credentials.deviceId = deviceId
        login(withCredentials: credentials)
    }

    func login(withCredentials credentials: MXCredentials, savingToKeychain saveToKeychain: Bool = false) {
        session.close()
        let restClient = MXRestClient(credentials: credentials, unrecognizedCertificateHandler: nil)
        guard let _session = MXSession(matrixRestClient: restClient) else {
            authenticationStatus = .error
            return
        }
        session = _session
        store = MXFileStore(credentials: credentials)
        authenticationStatus = .authenticated

        let defaults = UserDefaults.standard
        defaults.set(credentials.userId, forKey: "lastUsername")

        if saveToKeychain {
            guard let username = credentials.userId else { return }
            guard let homeserver = credentials.homeServer else { return }
            guard let deviceId = credentials.deviceId else { return }

            let accountData = [
                "username": username,
                "homeserver": homeserver,
                "deviceId": deviceId
            ]

            var accounts = defaults.array(forKey: "accounts") as? [MatrixAccount] ?? []
            if let accountIndex = accounts.firstIndex(where: { $0["username"] == username }) {
                accounts[accountIndex] = accountData
            } else {
                accounts.append(accountData)
            }
            defaults.set(accounts, forKey: "accounts")

            try? Keychain.save(password: credentials.accessToken!.data(using: .utf8)!, service: KEYCHAIN_SERVICE, account: username)
        }
    }

    func logout() {
        guard let username = session.credentials.userId else { return }

        self.authenticationStatus = .notAuthenticated

        let defaults = UserDefaults.standard

        try? Keychain.deletePassword(service: KEYCHAIN_SERVICE, account: username)
        var accounts = defaults.array(forKey: "accounts") as? [MatrixAccount] ?? []
        accounts = accounts.filter({ $0["username"] != username })
        defaults.set(accounts, forKey: "accounts")

        session.logout { _ in
            if let account = accounts.first {
                self.login(withUsername: account["username"])
            }
        }
    }

    func switchSession(account: MatrixAccount) {
        login(withUsername: account["username"])
    }

    func addAccount() {
        authenticationStatus = .notAuthenticated
        session.close()
    }

    static func credentialsAreIntact() -> Bool {
        do {
            let defaults = UserDefaults.standard

            guard var accounts = defaults.array(forKey: "accounts") as? [MatrixAccount] else {
                throw MatrixCredentialValidationError.invalidUsername
            }

            if accounts.count == 0 {
                return false
            }

            guard defaults.string(forKey: "lastUsername") != nil else { return false }

            accounts = accounts.filter { account in
                guard let username = account["username"] else { return false }
                guard account["homeserver"] != nil else { return false }
                guard account["deviceId"] != nil else { return false }
                guard let accessTokenData = try? Keychain.readPassword(service: KEYCHAIN_SERVICE, account: username) else { return false }
                guard String(data: accessTokenData, encoding: .utf8) != nil else { return false }
                return true
            }

            defaults.set(accounts, forKey: "accounts")

            return true
        } catch {
            return false
        }
    }

    static func migrateCredentials() {
        let defaults = UserDefaults.standard
        let username = defaults.string(forKey: "username")
        defaults.removeObject(forKey: "username")
        let homeserver = defaults.string(forKey: "homeserver")
        defaults.removeObject(forKey: "homeserver")
        let deviceId = defaults.string(forKey: "deviceId")
        defaults.removeObject(forKey: "deviceId")

        guard let homeserver = homeserver, let username = username else { return }
        guard let accessTokenData = try? Keychain.readPassword(service: homeserver, account: username) else { return }
        if (try? Keychain.save(password: accessTokenData, service: KEYCHAIN_SERVICE, account: username)) != nil {
            try? Keychain.deletePassword(service: homeserver, account: username)
        }
        var accounts = defaults.array(forKey: "accounts") as? [MatrixAccount] ?? []
        accounts.append([
            "username": username,
            "homeserver": homeserver,
            "deviceId": deviceId ?? ""
        ])
        defaults.set(accounts, forKey: "accounts")
        defaults.set(username, forKey: "lastUsername")
    }

    static func getAccounts() -> [MatrixAccount] {
        let defaults = UserDefaults.standard
        return defaults.array(forKey: "accounts") as? [MatrixAccount] ?? []
    }
}

struct MatrixPreferences {
    @UserDefaultsStorage(key: "showRoomMemberEvents", defaultValue: true)
    var showRoomMemberEvents: Bool

    @UserDefaultsStorage(key: "prioritizeRoomsWithActivity", defaultValue: true)
    var prioritizeRoomsWithActivity: Bool

    @UserDefaultsStorage(key: "displayRoomActivityIndicators", defaultValue: true)
    var displayRoomActivityIndicators: Bool

    @UserDefaultsStorage(key: "showRoomIconsInSidebar", defaultValue: false)
    var showRoomIconsInSidebar: Bool
}

struct MatrixAccount {
    let username: String
    let homeserver: String
    let deviceId: String

}
