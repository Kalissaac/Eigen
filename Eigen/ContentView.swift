//
// ContentView.swift
// Eigen
//
        

import SwiftUI

struct ContentView: View {
    var body: some View {
        ConversationList(searchText: .constant(""))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
