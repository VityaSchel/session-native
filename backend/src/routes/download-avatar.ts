import { session } from '@/index'
import type { MessageResponse } from '@/routes'
import { z } from 'zod'

export async function downloadAvatar(message: unknown): Promise<MessageResponse> {
  const {
    url,
    key
  } = z.object({
    url: z.string(),
    key: z.string()
  }).parse(message)

  const avatar = await session?.downloadAvatar({ url, key: Buffer.from(key, 'hex') })
  return {
    ok: true,
    avatar: avatar && new Uint8Array(avatar)
  }
}