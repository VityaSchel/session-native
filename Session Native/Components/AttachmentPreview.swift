import SwiftUI
import Foundation
//import AVKit

private let imageAttachments = [
  "image/png", "image/jpeg", "image/gif", "image/tiff", "image/heic", "image/heif", "image/bmp", "image/x-icon"
]

private let videoAttachment = [
  "video/mp4"
]

enum AttachmentsPreviewStyle {
  case light
  case dark
}

struct AttachmentsPreview: View {
  var attachments: [AttachmentPreview]
  var style: AttachmentsPreviewStyle
  var direction: ChatBubbleShapeDirection
  
  var media: [AttachmentPreview] {
    attachments.filter({ attachment in
      imageAttachments.contains(attachment.mimeType) || videoAttachment.contains(attachment.mimeType)
    })
  }
  
  var unrecognizedFiles: [AttachmentPreview] {
    attachments.filter({ attachment in
      !imageAttachments.contains(attachment.mimeType) && !videoAttachment.contains(attachment.mimeType)
    })
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(String(attachments.count) + " attachment" + (attachments.count > 1 ? "s": ""))
        .font(.system(size: 13, weight: .semibold))
        .foregroundColor(style == .dark ? Color(hex: "#000000") : Color.text)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
      if media.count > 0 {
        ScrollView(.horizontal) {
          HStack(spacing: 12) {
            ForEach(media, id: \.id) { attachment in
              AttachmentPreviewView(attachment: attachment, style: style)
            }
          }
          .padding(direction == .left ? .leading : .trailing, 11)
          .padding(direction == .left ? .trailing : .leading, 8)
          .scrollTargetLayout()
//          .padding(16)
        }
        .scrollTargetBehavior(.viewAligned)
        //      .frame(width: .infinity)
      }
      if unrecognizedFiles.count > 0 {
        VStack(spacing: 6) {
          ForEach(unrecognizedFiles, id: \.id) { attachment in
            AttachmentPreviewView(attachment: attachment, style: style)
          }
        }
        .if(media.count > 0 && unrecognizedFiles.count > 0, { view in
          view.padding(.top, 8)
        })
        .padding(direction == .left ? .leading : .trailing, 11)
        .padding(direction == .left ? .trailing : .leading, 8)
        //      .frame(width: .infinity)
      }
    }
    .padding(.bottom, 20)
    .frame(minWidth: 200)
  }
}

struct AttachmentPreviewView: View {
  @ObservedObject var attachment: AttachmentPreview
  var style: AttachmentsPreviewStyle
  
  var body: some View {
    if(imageAttachments.contains(attachment.mimeType)) {
      Button {
        if let contentURL = attachment.contentURL {
          NSWorkspace.shared.open(contentURL)
        } else {
          downloadAttachment(attachment)
        }
      } label: {
        if let url = attachment.contentURL,
          let nsImage = NSImage(contentsOf: url) {
        Image(nsImage: nsImage)
          .resizable()
          .scaledToFill()
          .frame(width: 200, height: 200)
          .cornerRadius(6.0)
          .onDrag {
            let itemProvider = NSItemProvider(object: nsImage)
            itemProvider.suggestedName = attachment.name
            return itemProvider
          }
        } else {
          VStack {
            Spacer()
            HStack(alignment: .center, spacing: 6) {
              Image(systemName: "photo.fill")
              Text("Image")
            }
            .padding(.bottom, 4)
            Text(attachment.name)
              .font(.caption2)
            Text(getFilesizePlaceholder(filesize: attachment.size))
              .font(.caption)
          }
          .padding(20)
          .frame(width: 200, height: 200)
          .background(Color.gray.gradient)
          .cornerRadius(6.0)
          .overlay {
            Image(systemName: attachment.downloading ? "xmark.circle" : "arrow.down.circle")
              .resizable()
              .scaledToFit()
              .frame(width: 40, height: 40)
              .padding(.bottom, 16)
          }
        }
      }
      .buttonStyle(.plain)
    } else if(videoAttachment.contains(attachment.mimeType)) {
      Button {
        if let contentURL = attachment.contentURL {
          NSWorkspace.shared.open(contentURL)
        } else {
          downloadAttachment(attachment)
        }
      } label: {
        VStack {
          Spacer()
          HStack(alignment: .center, spacing: 6) {
            Image(systemName: "movieclapper.fill")
            Text("Video")
          }
          .padding(.bottom, 4)
          Text(attachment.name)
            .font(.caption2)
          Text(getFilesizePlaceholder(filesize: attachment.size))
            .font(.caption)
        }
        .padding(20)
        .frame(width: 16*200/9, height: 200)
        .background(Color.black.gradient)
        .cornerRadius(6.0)
        .overlay {
          Image(systemName: attachment.contentURL != nil ? "play.circle" : attachment.downloading ? "xmark.circle" : "arrow.down.circle")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .padding(.bottom, 16)
        }
      }
      .buttonStyle(.plain)
    } else {
      Button {
        if let contentURL = attachment.contentURL {
          NSWorkspace.shared.open(contentURL)
        } else {
          downloadAttachment(attachment)
        }
      } label: {
        HStack(alignment: .center, spacing: 14) {
          Image(systemName: attachment.contentURL != nil ? "doc" : attachment.downloading ? "xmark.circle" : "arrow.down.circle")
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .foregroundColor(style == .dark ? Color(hex: "#000000") : Color.text)
          VStack(alignment: .leading, spacing: 4) {
            Text(attachment.name)
              .font(.system(size: 14, weight: .semibold))
              .foregroundColor(style == .dark ? Color(hex: "#000000") : Color.text)
            Text(getFilesizePlaceholder(filesize: attachment.size))
              .font(.system(size: 12))
              .foregroundColor(style == .dark ? Color(hex: "#000000") : Color.text)
          }
          Spacer()
        }
        .padding(16)
        .frame(height: 60)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color.gray)
        .cornerRadius(6.0)
      }
      .buttonStyle(.plain)
      .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  private func downloadAttachment(_ attachment: AttachmentPreview) {
    if let fileserverId = attachment.fileserverId,
       let digest = attachment.digest,
       let attachmentKey = attachment.attachmentKey {
      if(!attachment.downloading) {
        request([
          "type": "download_file",
          "id": .string(fileserverId),
          "metadata": .map([
            "contentType": .string(attachment.mimeType),
          ]),
          "digest": .string(digest),
          "key": .string(attachmentKey),
          "name": .string(attachment.name)
        ], { response in
          if(response["ok"]?.boolValue == true) {
            if let content = response["content"]?.dataValue {
              let contentURL = URL(fileURLWithPath: NSTemporaryDirectory() + attachment.name)
              do {
                try content.write(to: contentURL)
                DispatchQueue.main.async {
                  attachment.contentURL = contentURL
                }
              } catch {
                print("Failed to write to file: \(error)")
              }
            }
          } else {
            DispatchQueue.main.async {
              attachment.downloading = false
              if let error = response["error"]?.stringValue {
                print("Failed to download attachment: \(error)")
              }
            }
          }
        })
      }
      attachment.downloading = !attachment.downloading
    }
  }
}

#Preview {
  AttachmentsPreview(attachments: [
    imageAttachmentPreviewMock,
    imageAttachmentPreviewMock,
    videoAttachmentPreviewMock,
    fileAttachmentPreviewMock1,
    fileAttachmentPreviewMock2,
    fileAttachmentPreviewMock3,
  ], style: .light, direction: .left)
}
