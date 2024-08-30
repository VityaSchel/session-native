import Foundation
import SwiftUI

struct AttachmentPreviewSend: View {
  var attachment: Attachment
  var onRemove: () -> Void = {}
  
  var body: some View {
    ZStack {
      Group {
        if ["image/png", "image/jpeg", "image/gif", "image/tiff", "image/heic", "image/heif", "image/bmp", "image/x-icon"].contains(attachment.mimeType) {
          if let nsImage = NSImage(data: attachment.data) {
            Image(nsImage: nsImage)
              .resizable()
              .scaledToFill()
          }
        } else {
          VStack(spacing: 4) {
            Text(attachment.name)
              .multilineTextAlignment(.center)
            Text(getFilesizePlaceholder(filesize: attachment.size))
          }
        }
      }
      .padding(20)
      .frame(width: 200, height: 200)
      .background(Color.gray.secondary)
      .cornerRadius(6.0)
      Button {
        onRemove()
      } label: {
        Image(systemName: "xmark.circle.fill")
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
          .foregroundColor(.white)
      }
      .background(Color.gray)
      .cornerRadius(999)
      .buttonStyle(.plain)
      .position(x: 195, y: 5)
    }
    .frame(width: 200, height: 200)
  }
}

#Preview {
  ScrollView([.horizontal]) {
    HStack {
      AttachmentPreviewSend(
        attachment: Attachment(
          id: UUID(),
          name: "image.png",
          size: 1024,
          mimeType: "image/png",
          data: imageMock1
        )
      )
      AttachmentPreviewSend(
        attachment: Attachment(
          id: UUID(),
          name: "nuclear_codes.txt",
          size: 1024,
          mimeType: "text/plain",
          data: "".data(using: .utf8)!
        )
      )
      AttachmentPreviewSend(
        attachment: Attachment(
          id: UUID(),
          name: "image.png",
          size: 1024,
          mimeType: "image/png",
          data: imageMock2
        )
      )
      AttachmentPreviewSend(
        attachment: Attachment(
          id: UUID(),
          name: "image.png",
          size: 1024,
          mimeType: "image/png",
          data: imageMock3
        )
      )
    }
    .padding(.all, 8)
  }
}
