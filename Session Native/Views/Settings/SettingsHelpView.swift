import Foundation
import SwiftUI

struct HelpView: View {
  @State var expanded: Bool = false
  
  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        DisclosureGroup("What is Session?") {
          VStack(alignment: .leading) {
            Text("Session is a decentralized messenger network named after its core principle of sessions — disposable one-time inboxes — instead of accounts. To interact with it, you have to use a client, for example, Session Native or Session Web. It connects to decentralized network of nodes that operate the messenger. Session isn't owned by centralized entity, but mostly controlled and developed by Oxen Foundation, which is funded by non-profit OPTF organization.")
          }
        }
        .disclosureGroupStyle(AccordionStyle())
        Divider()
        DisclosureGroup("What is Session Native?") {
          VStack(alignment: .leading) {
            Text("There are some official and some unofficial clients in terms of being developed by Oxen Foundation — creators of Session, or community. They have the same possible capabilities, because Session network does not distinguish between clients and it's up to developer which features their client will support and how they deal with users privacy. Session Native is unofficial client developed by Viktor Shchelochkov aka hloth, not affiliated in any way with Oxen or OPTF.")
          }
        }
        .disclosureGroupStyle(AccordionStyle())
        Divider()
        DisclosureGroup("How to protect my account?") {
          VStack(alignment: .leading) {
            (Text("As there are no accounts in Session, you don't own your Session. The philosophy of sessions is that they're disposable and should be used shortly and then deleted to not leak your identity behind Session ID. All data stored on remote storage servers is deleted after 14 days, so you don't have to worry about it, if someone will ever use the same Session. And if you want to erase all your traces, make sure to check «Delete data remotely» toggle when logging out. The only thing that Session uses to authentificate and authorize you is your 13 words mnemonic, so ") + Text("do not share your mnemonic/seed phrase with anyone").fontWeight(.bold) + Text("."))
          }
        }
        .disclosureGroupStyle(AccordionStyle())
        Divider()
        DisclosureGroup("I want to report content in conversation") {
          VStack(alignment: .leading) {
            Text("Session was built with anonymity and privacy as its priorities: it does not require any personal information or verification for registration and efficiently protects you from spam by generating random Session ID address. \n\nUnlike traditional centralized messengers, such as Telegram or WhatsApp, which has moderation and ability to ban user or take legal action against them, Session is decentralized, meaning there is no central supervisory authority that can take actions. All requests from client to server are onion routed (passing through a series of proxies in Session network) to hide user's IP. \n\nFinally, conversations between you and your recipient are end-to-end encrypted, and unlike Telegram and WhatsApp, the encryption key is generated and stored on your device and never leaves it, which makes it impossible for anyone to read conversations content. Even if there was a way to ban a recipient, the person who was using it, will create new one in less than a second and keep doing malicious things. \n\nThe best you can do is either block locally the recipient who makes you trouble, and if they continue from other Session IDs, switch your own account. You can use export/import feature to transfer all your dialogs and ask your recipients to do the same thing in corresponding conversations. \n\nOtherwise, if you want to stick to the current Session ID, try to use contacts list and enable autoarchive feature in 􀍟 Settings 􀄫 􀎠 Privacy to automatically mute & move to archive new conversations.")
          }
        }
        .disclosureGroupStyle(AccordionStyle())
        Divider()
        DisclosureGroup("Is there an alternative to Session ID?") {
          VStack(alignment: .leading) {
            Text("Session IDs are hard to remember, but its complexity is its benefit: no one knows it and it's impossible to spam to you unless you share it publicly.\n\nYou can buy ONS mapping with any 1-64 latin characters that resolves to selected Session ID. To buy it for any cryptocurrency, go to [ons.sessionbots.directory](https://ons.sessionbots.directory) created by author of Session Native. You can also register it directly in blockchain for Session cryptocurrency using official app")
          }
        }
        .disclosureGroupStyle(AccordionStyle())
        Divider()
        DisclosureGroup("How to help?") {
          VStack(alignment: .leading) {
            Text("There are multiple ways you can help Session grow.\n")
            Text("• [Run your own node](https://docs.oxen.io/oxen-docs/about-the-oxen-blockchain/oxen-service-nodes)")
            Text("Running Session node requires some significant investment and deposit to decrease chance of sybil attack, but you receive Session cryptocurrency in return for running it along with increased privacy and resistance of Session network.\n")
            Text("• [Contribute to Session](https://github.com/VityaSchel/session-native)")
            Text("If you have developer skills, make a contribution to one of open-source Session clients.\n")
            Text("• [Contribute to contributors](https://hloth.dev/donate)")
            Text("If you have money, donate it to Session nodes operators, contibutors who help Session (such as author of this client) or OPTF organization that created and manages Session messenger.\n")
            Text("• [Develop 3rd party tools and bots](https://sessionjs.github.io/)")
            Text("If you have developer skills, create some unique tool or useful bot that brings existing things from other messengers to Session.\n")
            Text("• [Invite your friends](https://docs.oxen.io/oxen-docs/about-the-oxen-blockchain/oxen-service-nodes)")
            Text("If you have friends or colleagues, invite them to Session. The more people use it — the more secure and great Session becomes. At least until we invent quantum computers and the whole encryption breaks... So help delay AI takeover of world and quantum calculations!!!\n")
          }
        }
        .disclosureGroupStyle(AccordionStyle())
      }
      .padding()
    }
  }
}

#Preview {
  SettingsView_Preview.previewWithTab("help")
}
