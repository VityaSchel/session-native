import { z } from 'zod'
import { resolve } from '@session.js/ons'
import type { MessageResponse } from '@/routes'

export async function resolveONS(message: unknown): Promise<MessageResponse> {
  const { ons } = z.object({ ons: z.string() }).parse(message)
  const sessionId = await resolve(ons)
  return { ok: true, sessionId }
}