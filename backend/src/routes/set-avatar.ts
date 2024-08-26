import { z } from 'zod'
import { type MessageResponse } from '@/routes'
import { session } from '@/index'

export async function setAvatar(message: unknown): Promise<MessageResponse> {
  const {
    avatar
  } = z.object({
    avatar: z.instanceof(Uint8Array)
  }).parse(message)
  if (session === null) {
    return { ok: false, error: 'Backend instance not authorized' }
  }
  const b = avatar.buffer.slice(avatar.byteOffset, avatar.byteOffset + avatar.byteLength) as ArrayBuffer
  await session.setAvatar(b)
  return { ok: true }
}