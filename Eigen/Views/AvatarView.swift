//
// AvatarView.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK
import CachedAsyncImage

struct AvatarView: View {
    @EnvironmentObject private var matrix: MatrixModel
    let url: String?
    let height: CGFloat
    let width: CGFloat

    var body: some View {
        CachedAsyncImage(url: normalizeAvatarURL()) { image in
            image
                .resizable()
        } placeholder: {
            GeometryReader { metrics in
                VStack {
                    HStack {
                        Image(systemName: "person")
                            .resizable()
                            .frame(width: metrics.size.width * 0.5, height: metrics.size.height * 0.5, alignment: .center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.quaternary)
            }
        }
        .frame(width: width, height: height, alignment: .topLeading)
        .clipShape(Circle())
    }

    func normalizeAvatarURL() -> URL? {
        guard let url = url else { return nil }
        guard var normalizedURL = URL(string: url) else { return nil }
        if normalizedURL.scheme == "mxc" {
            if let thumbnailURL = matrix.session.mediaManager.url(
                ofContentThumbnail: normalizedURL.absoluteString,
                toFitViewSize: CGSize(width: width, height: height),
                with: .init(1)
            ) {
                normalizedURL = URL(string: thumbnailURL) ?? normalizedURL
            }
        }
        return normalizedURL
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(url: nil, height: 16.0, width: 16.0)
            .environmentObject(MatrixModel())
    }
}
