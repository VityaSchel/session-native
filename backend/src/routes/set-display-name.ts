import { z } from 'zod'
import { type MessageResponse } from '@/routes'
import { session } from '@/index'

export async function setDisplayName(message: unknown): Promise<MessageResponse> {
  const {
    displayName
  } = z.object({
    displayName: z.string().max(64)
  }).parse(message)
  if (session === null) {
    return { ok: false, error: 'Backend instance not authorized' }
  }
  await session.setDisplayName(displayName)
  return { ok: true }
}