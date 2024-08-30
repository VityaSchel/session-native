import Foundation

func getFilesizePlaceholder(filesize: Int) -> String {
  let filesizeFloat = Double(filesize)
  
  if filesize < 1024 {
    return "\(filesize) B"
  } else if filesize < 1024 * 1024 {
    return String(format: "%.1f KB", filesizeFloat / 1024)
  } else if filesize < 1024 * 1024 * 1024 {
    return String(format: "%.1f MB", filesizeFloat / 1024 / 1024)
  } else {
    return String(format: "%.1f GB", filesizeFloat / 1024 / 1024 / 1024)
  }
}

