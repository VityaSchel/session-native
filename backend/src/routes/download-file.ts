import { session } from '@/index'
import type { MessageResponse } from '@/routes'
import { z } from 'zod'

export async function downloadFile(message: unknown): Promise<MessageResponse> {
  const {
    id,
    metadata,
    digest,
    key,
    name
  } = z.object({
    id: z.string(),
    metadata: z.object({
      width: z.number().optional(),
      height: z.number().optional(),
      contentType: z.string().optional()
    }),
    digest: z.string(),
    key: z.string(),
    name: z.string()
  }).parse(message)

  const file = await session?.getFile({
    id,
    metadata,
    _digest: Buffer.from(digest, 'hex'),
    _key: Buffer.from(key, 'hex'),
    name
  })
  return {
    ok: true,
    content: await file?.arrayBuffer(),
    name: file?.name,
    contentType: file?.type
  }
}