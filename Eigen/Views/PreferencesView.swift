//
// PreferencesView.swift
// Eigen
//
        

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var matrix: MatrixModel

    var body: some View {
        List {
            ProfileSection()
            AppearanceSection()
            DevicesSection()
            EncryptionSection()
        }
        .listStyle(.inset)
        .navigationTitle("Preferences")
    }
}

struct ProfileSection: View {
    @EnvironmentObject private var matrix: MatrixModel

    var body: some View {
        Section("Profile") {
            HStack(spacing: 12) {
                UserAvatarView(user: matrix.session.myUser, height: 48, width: 48)
                    .environmentObject(RoomData())
                VStack(alignment: .leading) {
                    Text(matrix.session.myUser.displayname)
                        .font(.title3)
                        .bold()
                    Text(matrix.session.myUser.userId)
                        .fontWeight(.light)
                        .textSelection(.enabled)
                }
                Spacer()
                Button("Log out") {
                    matrix.logout()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct AppearanceSection: View {
    @EnvironmentObject private var matrix: MatrixModel

    var body: some View {
        Section("Appearance") {
            Toggle("Show room member events", isOn: $matrix.preferences.showRoomMemberEvents)
        }
    }
}

struct DevicesSection: View {
    @EnvironmentObject private var matrix: MatrixModel

    var body: some View {
        Section("Devices") {
            if let crypto = matrix.session.crypto {
                let devices = Array(crypto.devices(forUser: matrix.session.myUserId).values)
                ForEach(devices.sorted(by: { $0.displayName + $0.deviceId < $1.displayName + $1.deviceId }), id: \.deviceId) { device in
                    Text("\(device.displayName) (\(device.deviceId))")
                }
            }
        }
    }
}

struct EncryptionSection: View {
    @EnvironmentObject private var matrix: MatrixModel

    @State private var recoveryKey = ""
    @State private var keysimport = ""
    @State private var keyspass = ""

    var body: some View {
        Section("Encryption") {
            Text("Session ID: \(matrix.session.myDeviceId ?? "Unknown")")
            if let crypto = matrix.session.crypto {
                Text("Cross signing enabled: \(String(crypto.crossSigning.canCrossSign))")
                Text("Recovery enabled: \(String(crypto.recoveryService.hasRecovery()))")
                HStack {
                    SecureField("Recovery key", text: $recoveryKey)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(nsColor: .quaternaryLabelColor))
                        .cornerRadius(8)
                    Button("Restore", action: {
                        do {
                            let privkey = try crypto.recoveryService.privateKey(fromRecoveryKey: recoveryKey)
                            crypto.recoveryService.recoverSecrets(nil, withPrivateKey: privkey, recoverServices: true) { _ in
                            } failure: { err in
                                print(err)
                            }
                        } catch {
                            print("encountered error trying to restore from recovery key")
                        }
                    })
                }
                Button("Backfill messages", action: {
//                        crypto.
                })
                DisclosureGroup("Advanced") {
                    Text("Recovery by passphrase: \(String(crypto.recoveryService.usePassphrase()))")
                    Text("# secrets in recovery: \(crypto.recoveryService.secretsStoredInRecovery().count)")
                    Text("# secrets locally: \(crypto.recoveryService.secretsStoredLocally().count)")
                    Text("Curve25519 key: \(crypto.deviceCurve25519Key ?? "unknown")")
                    Text("Ed25519 key: \(crypto.deviceEd25519Key ?? "unknown")")
                    Text("Key backup enabled: \(String(crypto.backup?.enabled ?? false))")
                    Text("Can send messages to unverified sessions: \(String(!crypto.globalBlacklistUnverifiedDevices))")
                    Spacer()
                    Section("Import keys from export") {
                        TextEditor(text: $keysimport)
                            .foregroundColor(.secondary)
                        SecureField("Password", text: $keyspass)
                        Button("Import", action: {
                            if let keys = keysimport.data(using: .utf8) {
                                crypto.importRoomKeys(keys, withPassword: keyspass) { _, _ in
                                } failure: { err in
                                    print(err)
                                }
                            }
                        })
                    }
                }
            }
        }
    }
}

//struct PreferencesView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreferencesView()
//    }
//}
