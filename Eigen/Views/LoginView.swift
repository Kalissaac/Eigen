//
// LoginView.swift
// Eigen
//


import SwiftUI
import MatrixSDK

enum LoginMethod {
    case usernamePassword
    case SSO
    case accessToken
}

struct LoginView: View {
    @EnvironmentObject var matrix: MatrixModel

    @State private var username = ""
    @State private var password = ""
    @State private var homeserver = ""
    @State private var accessToken = ""

    var body: some View {
        VStack {
            Text("Log in to Matrix")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
            TextField("Username (@ferris:matrix.org)", text: $username)
                .textFieldStyle(.roundedBorder)
                .background(.black)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .background(.black)
            DisclosureGroup("Advanced") {
                TextField("Homeserver (https://matrix.org)", text: $homeserver)
                    .textFieldStyle(.roundedBorder)
                    .background(.black)
                Button("Log in with SSO") {
                    login(withMethod: .SSO)
                }
                    .disabled(homeserver == "")
                SecureField("Access Token", text: $accessToken)
                    .textFieldStyle(.roundedBorder)
                    .background(.black)
                Button("Log in with Access Token") {
                    login(withMethod: .accessToken)
                }
                    .disabled(username == "" || accessToken == "")
            }
            Button("Log in") {
                login(withMethod: .usernamePassword)
            }
        }
        .padding(.horizontal, 128)
        .frame(width: 800, height: 400, alignment: .center)
        .background(
            Image("Hero")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .preferredColorScheme(.light)
        )
        .preferredColorScheme(.dark)
    }

    func login(withMethod method: LoginMethod) {
        var homeserverURL = URL(string: "https://matrix.org")!
        if homeserver != "", let url = URL(string: homeserver) {
            homeserverURL = url
        }

        let credentials = MXCredentials(homeServer: homeserverURL.absoluteString, userId: nil, accessToken: nil)
        let restClient = MXRestClient(credentials: credentials, unrecognizedCertificateHandler: nil)
        let session = MXSession(matrixRestClient: restClient)


        switch method {
        case .usernamePassword:
            session?.matrixRestClient.login(username: username, password: password) { response in
                switch response {
                case .success(let credentials):
                    matrix.login(withCredentials: credentials, savingToKeychain: true)
                    break

                case .failure(let error):
                    print(error)
                    break
                }
            }
            break
        case .SSO:
            session?.matrixRestClient.getLoginSession(completion: { response in
                guard response.value != nil else { return }
                let authenticationSession = response.value!
                print(authenticationSession.flows)
                if let ssoFlow = authenticationSession.flows.first(where: { $0.type == kMXLoginFlowTypeSSO }) {
                    ssoFlow.stages
                }
            })

            if let loginURL = session?.matrixRestClient.loginFallbackURL {
                NSWorkspace.shared.open(loginURL)
            }
        case .accessToken:
            let credentials = MXCredentials(homeServer: homeserverURL.absoluteString, userId: username, accessToken: accessToken)
            matrix.login(withCredentials: credentials, savingToKeychain: true)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
