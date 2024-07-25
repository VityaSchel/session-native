import Foundation
import SwiftUI

struct SearchField: View {
  @Binding var searchText: String
  
  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass").foregroundColor(.gray)
      TextField("Search", text: $searchText)
    }
    .padding(7)
    .cornerRadius(10)
  }
}
