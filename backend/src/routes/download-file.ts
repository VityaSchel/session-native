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

  if (!session) {
    return {
      ok: false,
      error: 'Backend instance not authorized'
    }
  }

  try {
    const file = await session.getFile({
      id,
      metadata,
      _digest: Buffer.from(digest, 'hex'),
      _key: Buffer.from(key, 'hex'),
      name
    })
    const content = await file.arrayBuffer()
    return {
      ok: true,
      content: new Uint8Array(content),
      name: file.name,
      contentType: file.type
    }
  } catch(e) {
    console.error(e)
    return {
      ok: false,
      error: e instanceof Error ? e.message : 'Unknown error'
    }
  }
}