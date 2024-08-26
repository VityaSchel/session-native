import { z } from 'zod'
import { type MessageResponse } from '@/routes'
import { session } from '@/index'

export async function deleteMessages(message: unknown): Promise<MessageResponse> {
  const {
    conversation,
    messages
  } = z.object({
    conversation: z.string(),
    messages: z.array(z.object({
      hash: z.string(),
      timestamp: z.number()
    }))
  }).parse(message)
  console.log('conversation', conversation, 'messages', messages)

  if (session === null) {
    return { ok: false, error: 'Backend instance not authorized' }
  }

  await session.deleteMessages(messages.map(msg => ({
    to: conversation,
    timestamp: msg.timestamp,
    hash: msg.hash
  })))
  return { ok: true }
}