//
// InfiniteList.swift
// Eigen
//
// borrowed from https://github.com/niochat/nio/blob/4204f8792cd08024d624b29063daecf030ea82c3/Nio/Shared%20Views/ReverseList.swift
//
        

import SwiftUI

struct IsVisibleKey: PreferenceKey {
    static var defaultValue: Bool = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

struct InfiniteList<Element, Content>: View where Element: Identifiable, Content: View {
    private let items: [Element]
    private let viewForItem: (Element) -> Content

    @Binding private var hasReachedTop: Bool

    init(_ items: [Element], hasReachedTop: Binding<Bool>, viewForItem: @escaping (Element) -> Content) {
        self.items = items
        self._hasReachedTop = hasReachedTop
        self.viewForItem = viewForItem
    }

    var body: some View {
        GeometryReader { contentsGeometry in
            ScrollView {
                LazyVStack(alignment: .leading) {
                    Spacer(minLength: 18)
                    ForEach(items) { item in
                        self.viewForItem(item)
                            .scaleEffect(x: -1, y: 1)
                            .rotationEffect(.degrees(180))
                    }
                }
                    .padding(.horizontal)
                GeometryReader { topViewGeometry in
                    let frame = topViewGeometry.frame(in: .global)
                    let isVisible = contentsGeometry.frame(in: .global).contains(CGPoint(x: frame.midX, y: frame.midY))

                    HStack {
                        Spacer()
                        ProgressView().progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    }
                    .preference(key: IsVisibleKey.self, value: isVisible)
                }
                    .frame(height: 30)
                    .onPreferenceChange(IsVisibleKey.self) {
                        hasReachedTop = $0
                    }
            }
                .scaleEffect(x: -1, y: 1)
                .rotationEffect(.degrees(180))
        }
            .background()
    }
}

//struct InfiniteList_Previews: PreviewProvider {
//    static var previews: some View {
//        InfiniteList(["1", "2", "3"], hasReachedTop: .constant(false)) {
//            Text($0)
//        }
//    }
//}
