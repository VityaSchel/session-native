import path from 'path'
import { z } from 'zod'
import { type MessageResponse } from '@/routes'
import { Poller, Session } from '@session.js/client'
import { poller, proxy, setSessionObject } from '@/index'
import { FileKeyvalStorage } from '@session.js/file-keyval-storage'
import { BunNetwork } from '@session.js/bun-network'

export const sessionDataPath = path.join(process.env.HOME!, 'Library/Containers/dev.hloth.Session-Native/Data/tmp')

export async function setSession(message: unknown): Promise<MessageResponse> {
  const {
    mnemonic,
    displayName,
    avatar
  } = z.object({
    mnemonic: z.string(),
    displayName: z.string().optional(),
    avatar: z.instanceof(Uint8Array).nullable().optional()
  }).parse(message)

  await setSessionHandler({
    mnemonic: mnemonic,
    displayName: displayName,
    avatar: avatar ?? undefined
  })
  
  return { ok: true }
}

export async function setSessionHandler({ mnemonic, displayName, avatar }: { mnemonic: string, displayName?: string, avatar?: Uint8Array }) {
  poller?.stopPolling()

  const session = new Session({
    storage: new FileKeyvalStorage({
      filePath: path.join(sessionDataPath, 'session_data_' + Bun.hash(mnemonic).toString())
    }),
    network: new BunNetwork({
      proxy: proxy ?? undefined
    })
  })
  session.setMnemonic(mnemonic, displayName || undefined)
  if (avatar) {
    const b = avatar.buffer.slice(avatar.byteOffset, avatar.byteOffset + avatar.byteLength) as ArrayBuffer
    await session.setAvatar(b)
  }

  const newPoller = new Poller({ interval: null })
  session.addPoller(newPoller)

  setSessionObject({
    newSession: session,
    newPoller: newPoller,
  })
}