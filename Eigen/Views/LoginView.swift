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
    case loginToken
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
        .onOpenURL { url in
            print(url)
            guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
                  let path = components.url?.pathComponents,
                  let params = components.queryItems else {
                    print("Invalid URL or action path missing")
                    return
            }

            if let responseHomeserver = URL(string: path[1]) {
                homeserver = responseHomeserver.absoluteString
            }

            if let loginToken = params.first(where: { $0.name == "loginToken" })?.value {
                accessToken = loginToken
                login(withMethod: .loginToken)
            } else {
                print("Login token missing")
            }

        }
    }

    func login(withMethod method: LoginMethod) {
        var homeserverURL = URL(string: "https://matrix.org")!
        if homeserver != "" {
            homeserver = homeserver.replacingOccurrences(of: "http://", with: "https://")
            if !homeserver.starts(with: "https://") {
                homeserver = "https://\(homeserver)"
            }
            if let url = URL(string: homeserver) {
                homeserverURL = url
            }
        }

        let restClient = MXRestClient(homeServer: homeserverURL, unrecognizedCertificateHandler: nil)

        switch method {
        case .usernamePassword:
            restClient.login(username: username, password: password) { response in
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
            var ssoRedirectURLComponents = URLComponents()
            ssoRedirectURLComponents.scheme = homeserverURL.scheme
            ssoRedirectURLComponents.host = homeserverURL.host
            ssoRedirectURLComponents.path = "/_matrix/client/v3/login/redirect"
            ssoRedirectURLComponents.queryItems = [URLQueryItem(name: "redirectUrl", value: "eigen://login/\(homeserverURL.host!)")]

            NSWorkspace.shared.open(ssoRedirectURLComponents.url!)
        case .accessToken:
            let credentials = MXCredentials(homeServer: homeserverURL.absoluteString, userId: username, accessToken: accessToken)
            matrix.login(withCredentials: credentials, savingToKeychain: true)
        case .loginToken:
            restClient.login(parameters: ["type": "m.login.token", "token": accessToken]) { response in
                switch response {
                case .success(let rawLoginResponse):
                    let loginResponse = MXLoginResponse(fromJSON: rawLoginResponse)!
                    let credentials = MXCredentials(loginResponse: loginResponse, andDefaultCredentials: restClient.credentials)
                    matrix.login(withCredentials: credentials, savingToKeychain: true)
                    break

                case .failure(let error):
                    print(error)
                    break
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
