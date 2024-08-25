import { z } from 'zod'
import { getKeypairFromSeed } from '@session.js/keypair'
import { decode } from '@session.js/mnemonic'
import type { MessageResponse } from '@/routes'

export function mnemonicToSessionId(message: unknown): MessageResponse {
  const { mnemonic } = z.object({ mnemonic: z.string() }).parse(message)
  const seed = decode(mnemonic)
  const keypair = getKeypairFromSeed(seed)
  return { ok: true, sessionId: Buffer.from(keypair.x25519.publicKey).toString('hex') }
}