import Foundation
import SwiftUI

struct ConnectionSettingsView: View {
  @State private var proxyEnabled: Bool = UserDefaults.standard.optionalBool(forKey: "proxy_enabled") ?? false
  @State private var proxyType: String = UserDefaults.standard.optionalString(forKey: "proxy_type") ?? "http"
  @State private var proxyHostname: String = UserDefaults.standard.optionalString(forKey: "proxy_hostname") ?? ""
  @State private var proxyPort: String = UserDefaults.standard.optionalString(forKey: "proxy_port") ?? ""
  @State private var proxyUsername: String = UserDefaults.standard.optionalString(forKey: "proxy_username") ?? ""
  @State private var proxyPassword: String = UserDefaults.standard.optionalString(forKey: "proxy_password") ?? ""
  @State private var submitting: Bool = false
  @State private var error: String = ""
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Proxy")
        .font(.system(size: 12).smallCaps())
        .foregroundStyle(Color.gray.opacity(0.75))
        .padding(.top, 11)
        .padding(.horizontal, 10)
      VStack(alignment: .leading) {
        SettingToggle(
          title: "Enable proxy",
          isOn: $proxyEnabled,
          padding: 0
        )
        Divider()
          .padding(.bottom, 8)
        Picker(selection: $proxyType, label: Text("Type:")) {
          Text("HTTP").tag("http")
          Text("HTTPS").tag("https")
        }
          .pickerStyle(RadioGroupPickerStyle())
          .disabled(!proxyEnabled || submitting)
        HStack {
          TextField("IP address", text: $proxyHostname)
            .disabled(!proxyEnabled || submitting)
            .onSubmit { handleSubmit() }
          TextField("Port", text: $proxyPort)
            .disabled(!proxyEnabled || submitting)
            .onSubmit { handleSubmit() }
        }
        TextField("Username (optional)", text: $proxyUsername)
          .disabled(!proxyEnabled || submitting)
          .onSubmit { handleSubmit() }
        TextField("Password (optional)", text: $proxyPassword)
          .disabled(!proxyEnabled || submitting)
          .onSubmit { handleSubmit() }
        Text(error)
          .foregroundStyle(Color.red)
        PrimaryButton("Save", width: 220) {
          handleSubmit()
        }
        .disabled(!proxyEnabled || submitting)
      }
      .frame(width: 220)
      .padding(.all, 10)
      .background(Color.cardBackground)
      .cornerRadius(8)
      .onChange(of: proxyEnabled) {
        if(proxyEnabled == false) {
          UserDefaults.standard.set(false, forKey: "proxy_enabled")
          UserDefaults.standard.removeObject(forKey: "proxy_hostname")
          UserDefaults.standard.removeObject(forKey: "proxy_port")
          UserDefaults.standard.removeObject(forKey: "proxy_type")
          UserDefaults.standard.removeObject(forKey: "proxy_username")
          UserDefaults.standard.removeObject(forKey: "proxy_password")
          request([
            "type": "disable_proxy"
          ], { response in
            if(response["ok"]?.boolValue != true) {
              print("Failed to disable proxy")
            }
          })
        }
      }
      .if(submitting, { view in
        view.overlay(
          ProgressView()
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        )
      })
    }
    .padding()
  }
  
  private func handleSubmit() {
    if let proxyPort = Int64(proxyPort) {
      error = ""
      submitting = true
      request([
        "type": "set_proxy",
        "protocol": .string(proxyType),
        "hostname": .string(proxyHostname),
        "port": .int(proxyPort),
        "username": .string(proxyUsername),
        "password": .string(proxyPassword)
      ], { response in
        submitting = false
        if(response["ok"]?.boolValue == true) {
          UserDefaults.standard.set(true, forKey: "proxy_enabled")
          UserDefaults.standard.set(proxyType, forKey: "proxy_type")
          UserDefaults.standard.set(proxyHostname, forKey: "proxy_hostname")
          UserDefaults.standard.set(String(proxyPort), forKey: "proxy_port")
          UserDefaults.standard.set(proxyUsername, forKey: "proxy_username")
          UserDefaults.standard.set(proxyPassword, forKey: "proxy_password")
        } else {
          print("Failed to enable proxy")
          error = response["error"]?.stringValue ?? "Error while connecting to proxy"
        }
      })
    }
  }
}

#Preview {
  SettingsView_Preview.previewWithTab("connection")
}
