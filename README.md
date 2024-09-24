# Session Native

Session Native is [Session messenger by OXEN](https://getsession.org) open-source client written with performance, design and user experience in mind. It uses native Swift and other native technologies of macOS and aims to run with latest technologies rather to be compatible with all devices, thus it requires at least macOS 14.0 or later.

![session native screenshot](https://github.com/user-attachments/assets/5e302789-0645-4c19-80ad-e5d705497135)

## Getting started

- Download Session Native app from App Store (waiting for someone to [donate me](https://hloth.dev/donate) 100$)
- Or download redistributable app package from [releases](https://github.com/VityaSchel/session-native/releases)
- Or compile yourself, see [CONTRIBUTING.md](./CONTRIBUTING.md)

## Caveats

- Session isn't entirely native, as its backend is written with my [Session.js](https://sessionjs.github.io/) crossplatform Session framework. It doesn't matter though, because frontend must be reactive and backend can be anything. You won't experience any lags, because data is stored/retrieved using native SwiftData. Moreover, Session.js is written in Bun, which is very fast and comparable to Rust or even low-level languages.
- No onion routing for now, but you can setup onion routing on your network side yourself, also proxy settings are available
- While macOS protects applications data good enough, please be aware that app database is not encrypted, and thus can be accessed if malware has unrestricted access to your filesystem and you allowed it to read apps storage. Mnemonics are stored in keychain, which should make their retrieval harder for malicious actors.
- After you log out, only your mnemonic is deleted from device, your messages are still there in the database, unencrypted, thanks to Apple who managed to fuck up swiftdata enough to make it impossible to delete related objects without crashing the app. If you want to completely nuke all data quickly, click on "settings" icon in navbar with "options" key pressed, which should bring developer section in settings, where you can find "Clear all data" button which effectively clears absolutely everything about this app.

## List of things that I won't add/fix in Session Native

Abandoned because I spent 5+ hours on each and didn't succeed.

- Trying to clear everything after user logout, such as conversations and messages. When Apple fix [.cascade rule or at least inverse rule, I will come back to this issue](https://stackoverflow.com/questions/77559646/swiftdata-cascade-deletion-rule-not-working)
- Adding pull-to-anything, e.g. pull-to-open-archive. Nothing I tried worked and at the same time didn't hurt performance a lot.
