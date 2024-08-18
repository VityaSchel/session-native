import Foundation
import SwiftUI

struct AppearanceSettingsView: View {
  @AppStorage("theme") private var theme: String = "auto"
  
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
            withAnimation {
              theme = "light"
            }
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
          .if(theme == "light") { view in
            view.overlay(
              RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 3)
            )
          }
          Button {
            withAnimation {
              theme = "dark"
            }
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
          .if(theme == "dark") { view in
            view.overlay(
              RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 3)
            )
          }
          Button {
            withAnimation {
              theme = "auto"
            }
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
          .if(theme == "auto") { view in
            view.overlay(
              RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 3)
            )
          }
        }
        .frame(minWidth: 0)
        .padding(.all, 10)
        .background(Color.cardBackground)
        .cornerRadius(8)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
  }
}

#Preview {
  SettingsView_Preview.previewWithTab("appearance")
}
