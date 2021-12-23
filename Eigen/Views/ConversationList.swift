//
// ConversationList.swift
// Eigen
//

import SwiftUI

var listItems = ["Item 1", "Item 2", "Item 3", "Item 4"]
var secondItems = ["Second 1", "Second 2", "Second 3", "Second 4"]

struct ConversationList: View
{
    @State var activeConversation: String? = "Recents"
    @Binding var searchText: String
    
    var body: some View {
        NavigationView {
            List {
//                HStack {
//                     Image(systemName: "magnifyingglass")
//                     TextField("Search", text: $searchText)
//                        .textFieldStyle(PlainTextFieldStyle())
//                        .padding(5)
//                 }
//                    .background(Color(.darkGray))
//                    .cornerRadius(4)
//                    .padding(.bottom, 4)
                NavigationLink(destination: Text("search results"), tag: "Search", selection: $activeConversation) {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                NavigationLink(destination: Text("recent list"), tag: "Recents", selection: $activeConversation) {
                    Image(systemName: "clock")
                    Text("Recents")
                }
                NavigationLink(destination: Text("notifs"), tag: "Notifications", selection: $activeConversation) {
                    Image(systemName: "bell")
                    Text("Inbox")
                }
                
                Section(header: Text("Conversations")) {
                    ForEach((0..<listItems.count), id: \.self) { index in
                        NavigationLink(destination: ConversationDetail(conversationId: listItems[index], messageInputText: .constant("")), tag: listItems[index], selection: $activeConversation) {
                            Image(systemName: "person")
                            Text(listItems[index])
                        }
                    }
                }
                
                Section(header: Text("Channels")) {
                    ForEach((0..<secondItems.count), id: \.self) { index in
                        NavigationLink(destination: ConversationDetail(conversationId: secondItems[index], messageInputText: .constant("")), tag: secondItems[index], selection: $activeConversation) {
                            Image(systemName: "number")
                            Text(secondItems[index])
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle())
        }
        
        .toolbar {
            Button(action: {}) {
                Label("About this conversation", systemImage: "info.circle")
            }
        }
        .navigationTitle("Recent conversations")
    }
}

struct ConversationList_Previews: PreviewProvider {
    static var previews: some View {
        ConversationList(searchText: .constant(""))
    }
}
