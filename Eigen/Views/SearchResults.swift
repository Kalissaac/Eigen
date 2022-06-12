//
// SearchResults.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

struct SearchResults: View {
    @EnvironmentObject var matrix: MatrixModel

    @State private var searchText = ""
    @State private var searchResults: [MXSearchResult] = []
    @State private var isLoading = false
    private var searchResultsEvents: Binding<[MXEvent]> { Binding (
        get: { searchResults.map({ $0.result }) },
        set: { _ in }
        )
    }
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            HStack {
                HStack {
                     Image(systemName: "magnifyingglass")
                     TextField("Search ..", text: $searchText)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                 }
                    .padding(6)
                    .background(Color(nsColor: .quaternaryLabelColor))
                    .cornerRadius(8)
            }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                .padding(.bottom, 16)

            EventList(events: searchResultsEvents, shouldLoadMore: .constant(false))
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
                .environmentObject(RoomData())
        }
        .navigationTitle("Search results")
        .background(.background)
        .onAppear {
            isFocused = true
        }
    }
}

struct SearchResults_Previews: PreviewProvider {
    static var previews: some View {
        SearchResults()
    }
}
