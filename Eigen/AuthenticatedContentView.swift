//
// AuthenticatedContentView.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

struct AuthenticatedContentView: View {
    @EnvironmentObject private var matrix: MatrixModel

    func fetch() {
        matrix.session.setStore(matrix.store) { response in
            guard response.isSuccess else { return }

            matrix.session.start { response in
                guard response.isSuccess else { return }

                MXCrypto.check(withMatrixSession: matrix.session) { crypto in
                    if let crypto = crypto {
                        startCrypto(crypto: crypto)
                    } else {
                        matrix.session.enableCrypto(true) { _ in
                            startCrypto(crypto: matrix.session.crypto)
                        }
                    }
                }
            }
        }
    }

    func startCrypto(crypto: MXCrypto) {
        crypto.start {
            crypto.warnOnUnknowDevices = false
        } failure: { e in
            if let e = e {
                print(e)
            }
        }
    }

    var body: some View {
        ConversationList()
            .onAppear(perform: fetch)
    }
}

struct AuthenticatedContentView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedContentView()
    }
}
