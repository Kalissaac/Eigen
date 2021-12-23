//
// ContentView.swift
// Eigen
//
        

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var matrix: MatrixModel
    
    var body: some View {
        ConversationList()
            .environmentObject(matrix)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
