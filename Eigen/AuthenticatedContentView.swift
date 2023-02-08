//
// AuthenticatedContentView.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

struct AuthenticatedContentView: View {
    @EnvironmentObject private var matrix: MatrixModel

    func fetch() {
        if matrix.syncStatus != .initialSync {
            matrix.syncStatus = .inProgress
        }
        matrix.session.setStore(matrix.store) { response in
            guard response.isSuccess else { return }

            matrix.session.start { response in
                guard response.isSuccess else { return }

                MXCrypto.check(withMatrixSession: matrix.session) { crypto in
                    if let crypto = crypto {
                        crypto.start {
                            crypto.warnOnUnknowDevices = false
                            matrix.syncStatus = .complete
                        } failure: { e in
                            if let e = e {
                                print(e)
                            }
                        }
                    } else {
                        matrix.session.enableCrypto(true) { _ in
                            matrix.session.crypto.start {
                                matrix.session.crypto.warnOnUnknowDevices = false
                                matrix.syncStatus = .complete
                            } failure: { e in
                                if let e = e {
                                    print(e)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        switch matrix.syncStatus {
        case .initialSync:
            ProgressView()
                .onAppear(perform: fetch)
        default:
            ConversationList()
                .onAppear(perform: fetch)
        }
    }
}

struct AuthenticatedContentView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedContentView()
    }
}
