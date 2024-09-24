import Foundation

func getFilesizePlaceholder(filesize: Int) -> String {
  let filesizeFloat = Double(filesize)
  
  if filesize < 1000 {
    return "\(filesize) B"
  } else if filesize < 1000 * 1000 {
    return String(format: "%.1f KB", filesizeFloat / 1000)
  } else if filesize < 1000 * 1000 * 1000 {
    return String(format: "%.1f MB", filesizeFloat / 1000 / 1000)
  } else {
    return String(format: "%.1f GB", filesizeFloat / 1000 / 1000 / 1000)
  }
}

