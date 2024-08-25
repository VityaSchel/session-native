import { z } from 'zod'
import { type MessageResponse } from '@/routes'
import { session } from '@/index'

export async function sendMessage(message: unknown): Promise<MessageResponse> {
  const {
    recipient,
    body,
    replyTo
  } = z.object({
    recipient: z.string(),
    body: z.string(),
    replyTo: z.object({
      author: z.string(),
      timestamp: z.number(),
      text: z.string()
    }).optional()
  }).parse(message)

  if(session === null) {
    return { ok: false, error: 'Backend instance not authorized' }
  }

  console.log('sending message to', body, recipient)

  const response = await session.sendMessage({
    to: recipient,
    text: body,
    ...(replyTo && {
      replyToMessage: {
        author: replyTo.author,
        timestamp: replyTo.timestamp,
        text: replyTo.text,
      }
    })
  })

  return { ok: true, hash: response.messageHash, timestamp: response.timestamp }
}