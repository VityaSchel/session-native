import fs from 'fs/promises'
import path from 'path'
import { type MessageResponse } from '@/routes'
import { poller, session, setSessionObject } from '@/index'
import { sessionDataPath } from '@/routes/set-session'

export async function logoutSession(): Promise<MessageResponse> {
  if(session && poller) {
    poller.stopPolling()
    await fs.rm(path.join(sessionDataPath, 'session_data_' + Bun.hash(session.getMnemonic()!).toString()))
    setSessionObject(null)
  }

  return { ok: true }
}