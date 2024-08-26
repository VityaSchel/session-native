import path from 'path'
import { z } from 'zod'
import { type MessageResponse } from '@/routes'
import { Poller, Session } from '@session.js/client'
import { poller, setSessionObject } from '@/index'
import { FileKeyvalStorage } from '@session.js/file-keyval-storage'

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

  poller?.stopPolling()

  const session = new Session({
    storage: new FileKeyvalStorage({
      filePath: path.join(sessionDataPath, 'session_data_' + Bun.hash(mnemonic).toString())
    })
  })
  session.setMnemonic(mnemonic, displayName || undefined)
  if (avatar) {
    const b = avatar.buffer.slice(avatar.byteOffset, avatar.byteOffset + avatar.byteLength) as ArrayBuffer
    await session.setAvatar(b)
  }

  const newPoller = new Poller()
  session.addPoller(newPoller)

  setSessionObject({
    newSession: session,
    newPoller: newPoller
  })
  
  return { ok: true }
}