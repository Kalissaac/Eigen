//
// MessageEventImageView.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK
import CachedAsyncImage

struct MessageEventImageView: View {
    @EnvironmentObject private var matrix: MatrixModel
    var event: MXEvent
    @State private var imageDownloaded = false
    @State private var imageDownloadPath: String?
    @State private var imageDecrypted = false
    
    var body: some View {
        if event.isEncrypted, let encryptedContentFile = event.getEncryptedContentFiles().first {
            let imageDecryptionPath = "\(IMAGE_CACHE_DIRECTORY)\(event.id).png"

            if FileManager.default.fileExists(atPath: imageDecryptionPath), let img = NSImage(byReferencingFile: imageDecryptionPath) {
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 512, height: 256, alignment: .center)
            } else {
                let mediaLoader = matrix.session.mediaManager.downloadEncryptedMedia(fromMatrixContentFile: encryptedContentFile, mimeType: nil, inFolder: nil) { outputPath in
                    imageDownloaded = true
                    imageDownloadPath = outputPath
                } failure: { err in
                    if let err = err {
                        print(err)
                    }
                }

                if imageDownloaded && mediaLoader != nil {
                    let outputStream = OutputStream(toFileAtPath: imageDecryptionPath, append: false)!
                    let _ = MXEncryptedAttachments.decryptAttachment(event.getEncryptedContentFiles()[0], inputStream: InputStream(fileAtPath: imageDownloadPath ?? mediaLoader!.downloadOutputFilePath), outputStream: outputStream) {
                        imageDecrypted = true
                    } failure: { err in
                        if let err = err {
                            print(err)
                        }
                    }
                    if imageDecrypted, let img = NSImage(byReferencingFile: imageDecryptionPath) {
                        Image(nsImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 512, height: 256, alignment: .center)
                    } else {
                        ProgressView()
                    }
                } else {
                    ProgressView()
                }
            }
        }  else if let imageURL = event.getMediaURLs().first {
            CachedAsyncImage(url: URL(string: matrix.session.mediaManager.url(ofContent: imageURL) ?? "")) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray
            }
                .frame(width: 512, height: 256, alignment: .center)
        }
    }
}

struct MessageEventImageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageEventImageView(event: MXEvent())
    }
}
