# Session Native

Session Native is [Session messenger by OXEN](https://getsession.org) open-source client written with performance, design and user experience in mind. It uses native Swift and other native technologies of macOS and aims to run with latest technologies rather to be compatible with all devices, thus it requires at least macOS 14.0 or later.

![screenshot]()

## Getting started

- Download Session Native app from [App Store](https://example.org) 
- Or download redistributable app package from [releases](https://github.com/VityaSchel/session-native/releases)
- Or compile yourself, see [CONTRIBUTING.md](./CONTRIBUTING.md)

## Caveats

- Session isn't entirely native, as its backend is written with my [Session.js](https://sessionjs.github.io/) crossplatform Session framework. It doesn't matter though, because frontend must be reactive and backend can be anything. You won't experience any lags, because data is stored/retrieved using native SwiftData. Moreover, Session.js is written in Bun, which is very fast and comparable to Rust or even low-level languages.
- No onion routing for now, but you can setup onion routing on your network side yourself
- While macOS protects applications data good enough, please be aware that app database is not encrypted, and thus can be accessed if malware has unrestricted access to your filesystem and you allowed it to read apps storage. Mnemonics are stored in keychain, which should make their retrieval harder for malicious actors.