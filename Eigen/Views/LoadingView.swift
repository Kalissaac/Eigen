//
// LoadingView.swift
// Eigen
//
        

import SwiftUI

struct LoadingView: View {
    var message = "Loading..."

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                ProgressView()
                Text(message)
            }
        }
            .frame(width: 800, height: 400, alignment: .center)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
