//
// MatrixModel.swift
// Eigen
//
        

import Foundation
import SwiftUI
import MatrixSDK

class MatrixModel: ObservableObject {
    @Published var session: MXSession
    @Published var store: MXFileStore
    
    init() {
        let credentials = MXCredentials(homeServer: "", userId: "", accessToken: "")
        let restClient = MXRestClient(credentials: credentials, unrecognizedCertificateHandler: nil)
        session = MXSession(matrixRestClient: restClient)!
        store = MXFileStore()
    }
}
