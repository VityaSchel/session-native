import type { MessageResponse } from '@/routes'
import { getKeypairFromSeed, generateSeedHex } from '@session.js/keypair'
import { encode } from '@session.js/mnemonic'

export function generateSession(): MessageResponse {
  const seed = generateSeedHex()
  const keypair = getKeypairFromSeed(seed)
  const sessionId = Buffer.from(keypair.x25519.publicKey).toString('hex')
  const mnemonic = encode(seed)
  return { ok: true, sessionId, mnemonic }
}