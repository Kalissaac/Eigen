//
// LoginView.swift
// Eigen
//


import SwiftUI
import MatrixSDK

struct LoginView: View {
    @EnvironmentObject var matrix: MatrixModel

    @State private var username = ""
    @State private var password = ""
    @State private var homeserver = ""

    var body: some View {
        VStack {
            Text("Log in to Matrix")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
            TextField("Username (@ferris:matrix.org)", text: $username)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            DisclosureGroup("Advanced") {
                TextField("Homeserver (https://matrix.org)", text: $homeserver)
                    .textFieldStyle(.roundedBorder)
            }
            Button("Log in", action: login)
        }
        .padding(.horizontal, 64)
        .padding(.vertical, 96)
        .background(
            Image("Hero")
                .resizable()
                .aspectRatio(contentMode: .fill)
        )
    }

    func login() {
        var homeserverURL = URL(string: "https://matrix.org")!
        if homeserver != "", let url = URL(string: homeserver) {
            homeserverURL = url
        }

        let credentials = MXCredentials(homeServer: homeserverURL.absoluteString, userId: nil, accessToken: nil)
        let restClient = MXRestClient(credentials: credentials, unrecognizedCertificateHandler: nil)
        let session = MXSession(matrixRestClient: restClient)

        session?.matrixRestClient.login(username: username, password: password) { response in
            switch response {
            case .success(let credentials):
                matrix.login(withCredentials: credentials)
                break

            case .failure(let error):
                print(error)
                break
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
