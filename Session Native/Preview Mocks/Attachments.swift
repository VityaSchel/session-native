import Foundation

let imageAttachmentMock = Attachment(id: UUID(), name: "mypicture.jpg", size: imageMock3.count, mimeType: "image/jpeg", data: imageMock3)

let videoAttachmentMock = Attachment(id: UUID(), name: "roomba.mp4", size: videoMock1.count, mimeType: "video/mp4", data: videoMock1)

let imageAttachmentPreviewMock = AttachmentPreview(id: UUID(), name: imageAttachmentMock.name, size: imageAttachmentMock.size, mimeType: imageAttachmentMock.mimeType)

let videoAttachmentPreviewMock = AttachmentPreview(id: UUID(), name: videoAttachmentMock.name, size: videoAttachmentMock.size, mimeType: videoAttachmentMock.mimeType)

let fileAttachmentMock1 = Attachment(
  id: UUID(),
  name: "nuclear_codes.txt",
  size: 1110,
  mimeType: "text/plain",
  data: "".data(using: .utf8)!
)

let fileAttachmentPreviewMock1 = AttachmentPreview(id: UUID(), name: fileAttachmentMock1.name, size: fileAttachmentMock1.size, mimeType: fileAttachmentMock1.mimeType)

let fileAttachmentMock2 = Attachment(
  id: UUID(),
  name: "document.pdf",
  size: 150912,
  mimeType: "application/pdf",
  data: "".data(using: .utf8)!
)

let fileAttachmentPreviewMock2 = AttachmentPreview(id: UUID(), name: fileAttachmentMock2.name, size: fileAttachmentMock2.size, mimeType: fileAttachmentMock2.mimeType)

let fileAttachmentMock3 = Attachment(
  id: UUID(),
  name: "archive.zip",
  size: 1024,
  mimeType: "application/zip",
  data: "".data(using: .utf8)!
)

let fileAttachmentPreviewMock3 = AttachmentPreview(id: UUID(), name: fileAttachmentMock3.name, size: fileAttachmentMock3.size, mimeType: fileAttachmentMock3.mimeType)
