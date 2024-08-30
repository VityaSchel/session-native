import Foundation
import SwiftUI

struct ConnectionStatusView: View {
  @EnvironmentObject var appViewManager: ViewManager
  @EnvironmentObject var connectionStatusManager: ConnectionStatusManager
  @State private var showConnectionIssuesSheet = false
  
  var body: some View {
    Group {
      if !connectionStatusManager.connected {
        Button() {
          showConnectionIssuesSheet = true
        } label: {
          HStack {
            Spacer()
            Image(systemName: "exclamationmark.circle.fill")
            Text("No connection")
              .fontWeight(.medium)
            Spacer()
          }
          .foregroundStyle(Color(hex: "#443900"))
          .padding(.vertical, 6)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .background(Color(hex: "#FFC107"))
      }
    }
    .sheet(isPresented: $showConnectionIssuesSheet) {
      VStack {
        Text(connectionStatusManager.error)
          .foregroundStyle(Color.red)
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.bottom, 16)
        VStack {
          PrimaryButton("Open proxy settings") {
            showConnectionIssuesSheet = false
            appViewManager.setActiveView(.settings)
            appViewManager.setActiveNavigationSelection("connection")
          }
          PrimaryButton("Dismiss") {
            showConnectionIssuesSheet = false
          }
        }
      }
      .frame(width: 200)
      .padding(20)
    }
  }
}

#Preview {
  ConnectionStatusView()
}
