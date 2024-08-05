import Foundation
import SwiftUI

struct AppearanceSettingsView: View {
  var body: some View {
    VStack(alignment: .leading) {
      Text("App theme")
        .font(.system(size: 12).smallCaps())
        .foregroundStyle(Color.gray.opacity(0.75))
        .padding(.top, 11)
        .padding(.horizontal, 10)
      ScrollView([.horizontal], showsIndicators: true) {
        HStack(alignment: .center, spacing: 10) {
          Button {
            
          } label: {
            VStack {
              Image("LightThemePreview")
                .resizable()
                .scaledToFill()
                .frame(width: 200)
                .cornerRadius(6)
              Text("Light")
            }
            .padding(.bottom, 6)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          Button {
            
          } label: {
            VStack {
              Image("DarkThemePreview")
                .resizable()
                .scaledToFill()
                .frame(width: 200)
                .cornerRadius(6)
              Text("Dark")
                .fontWeight(.semibold)
            }
            .padding(.bottom, 6)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(.blue, lineWidth: 3)
          )
          Button {
            
          } label: {
            VStack {
              Image("AutoThemePreview")
                .resizable()
                .scaledToFill()
                .frame(width: 200)
                .cornerRadius(6)
              Text("Auto")
            }
            .padding(.bottom, 6)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
        }
//          .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minWidth: 0)
        .padding(.all, 10)
        .background(Color.cardBackground)
        .cornerRadius(8)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    // TODO: check light theme
  }
}

#Preview {
  SettingsView_Preview.previewWithTab("appearance")
}
