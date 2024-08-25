import { z } from 'zod'
import { type MessageResponse } from '@/routes'
import { session } from '@/index'

export async function markAsRead(message: unknown): Promise<MessageResponse> {
  const {
    conversation,
    messagesTimestamps
  } = z.object({
    conversation: z.string(),
    messagesTimestamps: z.array(z.number())
  }).parse(message)

  if (session === null) {
    return { ok: false, error: 'Backend instance not authorized' }
  }

  await session.markMessagesAsRead({
    from: conversation,
    messagesTimestamps: messagesTimestamps
  })
  return { ok: true }
}