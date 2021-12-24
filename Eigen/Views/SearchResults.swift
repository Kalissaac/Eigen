//
// SearchResults.swift
// Eigen
//
        

import SwiftUI
import Combine
import MatrixSDK

struct SearchResults: View {
    @EnvironmentObject var matrix: MatrixModel

    @State private var searchText = ""
    @State private var searchResults: [MXSearchResult] = []
    @State private var isLoading = false

    var body: some View {
        VStack {
            ZStack {
                HStack {
                     Image(systemName: "magnifyingglass")
                     TextField("Search ..", text: $searchText)
                 }
                     .foregroundColor(.gray)
                     .padding(.leading, 13)
             }
                 .frame(height: 40)
                 .cornerRadius(13)
                 .padding()

            List(searchResults, id: \.self) { event in
                if event.result.eventType == .roomMessage {
                    ConversationMessage(message: MessageEvent(id: event.result.eventId, timestamp: event.result.originServerTs, sender: event.result.sender, content: event.result.content["body"] as! String, roomId: event.result.roomId))
                } else {
                    Text(event.result.content["body"] as? String ?? "unknown content of type \(event.result.type ?? "unknown    ")")
                }
            }
            .onChange(of: searchText) { newSearchText in
                matrix.session.matrixRestClient.searchMessages(withPattern: newSearchText, nextBatch: "") { response in
                    switch response {
                    case .success(let searchResponse):
                        if let results = searchResponse.results {
                            searchResults = results.sorted(by: { a, b in
                                a.rank > b.rank
                            })
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        .navigationTitle("Search results")
    }
}

struct SearchResults_Previews: PreviewProvider {
    static var previews: some View {
        SearchResults()
    }
}
