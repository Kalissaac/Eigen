//
// PreferencesView.swift
// Eigen
//
        

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var matrix: MatrixModel

    @State private var keysimport = ""
    @State private var keyspass = ""
    @State private var crosssignpass = ""

    var body: some View {
        List {
            Section("Profile") {
                UserAvatarView(user: matrix.session.myUser, height: 32, width: 32)
                    .environmentObject(RoomData())
                Text(matrix.session.myUser.displayname)
                Text(matrix.session.myUser.userId)
                Button("Log out") {
                    matrix.logout()
                }
            }
            Section("Appearance") {
                Toggle("Show room member events", isOn: $matrix.preferences.showRoomMemberEvents)
            }
            Section("Devices") {
                if matrix.session.crypto != nil {
                    ForEach(Array(matrix.session.crypto.devices(forUser: matrix.session.myUserId).values), id: \.deviceId) { device in
                        Text("\(device.displayName) (\(device.deviceId))")
                    }
                }
            }
            Section("Encryption") {
                Text("Session ID: \(matrix.session.myDeviceId ?? "Unknown")")
                if matrix.session.crypto != nil {
                    Text("Cross signing enabled: \(String(matrix.session.crypto.crossSigning.canCrossSign))")
                    Section("Recovery") {
                        Text("Recovery enabled: \(String(matrix.session.crypto.recoveryService.hasRecovery()))")
                        Text("Recovery by passphrase: \(String(matrix.session.crypto.recoveryService.usePassphrase()))")
                        Text("# secrets in recovery: \(matrix.session.crypto.recoveryService.secretsStoredInRecovery().count)")
                        Text("# secrets locally: \(matrix.session.crypto.recoveryService.secretsStoredLocally().count)")
                        SecureField("Recovery password", text: $crosssignpass)
                        Button("Restore from recovery", action: {
                            do {
                                let privkey = try matrix.session.crypto.recoveryService.privateKey(fromRecoveryKey: crosssignpass)
                                matrix.session.crypto.recoveryService.recoverSecrets(nil, withPrivateKey: privkey, recoverServices: true) { recoveryresult in
                                    print(recoveryresult.secrets)
                                } failure: { err in
                                    print(err)
                                }
                            } catch {

                            }
                        })
                    }
                    Text("Curve25519 key: \(matrix.session.crypto.deviceCurve25519Key)")
                    Text("Ed25519 key: \(matrix.session.crypto.deviceEd25519Key)")
                    Text("Key backup enabled: \(String(matrix.session.crypto.backup.enabled))")
                    Text("Can send messages to unverified sessions: \(String(!matrix.session.crypto.globalBlacklistUnverifiedDevices))")
                    Spacer()
                    Section("Import keys") {
                        TextEditor(text: $keysimport)
                            .foregroundColor(.secondary)
                        SecureField("Password", text: $keyspass)
                        Button("Import", action: {
                            matrix.session.crypto.importRoomKeys(keysimport.data(using: .utf8), withPassword: keyspass) { _, _ in
                            } failure: { err in
                                print(err!)
                            }
                        })
                    }
                }
            }
        }
        .listStyle(.inset)
        .navigationTitle("Preferences")
    }
}

//struct PreferencesView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreferencesView()
//    }
//}
