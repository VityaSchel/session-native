import { z } from 'zod'
import { type MessageResponse } from '@/routes'
import { session } from '@/index'

export async function sendMessage(message: unknown): Promise<MessageResponse> {
  const {
    recipient,
    body,
    attachments,
    replyTo
  } = z.object({
    recipient: z.string(),
    body: z.string(),
    attachments: z.array(z.object({
      name: z.string(),
      type: z.string(),
      size: z.number(),
      data: z.instanceof(Uint8Array)
    })).optional(),
    replyTo: z.object({
      author: z.string(),
      timestamp: z.number(),
      text: z.string()
    }).optional()
  }).parse(message)

  if(session === null) {
    return { ok: false, error: 'Backend instance not authorized' }
  }

  const attachmentsFiles: File[] = []
  if(attachments) {
    for(const attachment of attachments) {
      const blob = new Blob([attachment.data], { type: attachment.type })
      attachmentsFiles.push(new File([blob], attachment.name))
    }
  }

  const response = await session.sendMessage({
    to: recipient,
    text: body,
    ...(attachmentsFiles.length > 0 && { attachments: attachmentsFiles }),
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