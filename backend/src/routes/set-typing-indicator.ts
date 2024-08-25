import { z } from 'zod'
import { type MessageResponse } from '@/routes'
import { session } from '@/index'

const typingIndicatorCache = new Map<string, { value: boolean, timestamp: number }>()

export async function setTypingIndicator(message: unknown): Promise<MessageResponse> {
  const {
    recipient,
    show
  } = z.object({
    recipient: z.string(),
    show: z.boolean()
  }).parse(message)

  if (session === null) {
    return { ok: false, error: 'Backend instance not authorized' }
  }

  const cache = typingIndicatorCache.get(recipient)
  if (cache && cache.value == show) {
    if(show == false) return { ok: true }
    else {
      if(Date.now() - cache.timestamp < 5000) return { ok: true }
    }
  }

  typingIndicatorCache.set(recipient, { value: show, timestamp: Date.now() })
  if(show) {
    await session.showTypingIndicator({ conversation: recipient })
  } else {
    await session.hideTypingIndicator({ conversation: recipient })
  }
  return { ok: true }
}