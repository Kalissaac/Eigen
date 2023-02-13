//
// ConversationDetailInfo.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

struct ConversationDetailInfo: View {
    @EnvironmentObject private var matrix: MatrixModel
    
    let channel: MXRoom
    @State private var devices: [MXDeviceInfo] = []

    var body: some View {
        List {
            Section("Conversation ID") {
                Text(channel.roomId)
            }
            if devices.count > 0 {
                Section("Devices") {
                    ForEach(devices, id: \.deviceId) { device in
                        HStack {
                            Text(device.displayName ?? device.deviceId)
                            Spacer()
                            if !device.trustLevel.isVerified {
                                Button("Trust") {
                                    matrix.session.crypto.setDeviceVerification(.verified, forDevice: device.deviceId, ofUser: channel.directUserId) {}
                                    failure: { e in
                                        print(e as Any)
                                    }

                                }
                            }
                        }

                    }
                }
            }
        }
        .frame(width: 250, height: 400)
        .padding()
        .onAppear {
            if channel.directUserId != nil, let directUserDevices = matrix.session.crypto.devices(forUser: channel.directUserId) {
                devices = Array(directUserDevices.values)
            }
        }
    }
}

//struct ConversationDetailInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationDetailInfo()
//    }c
//}
