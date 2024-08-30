import { type MessageResponse } from '@/routes'
import { proxy, session, setConnectionProxy } from '@/index'
import { setSessionHandler } from '@/routes/set-session'

export async function disableProxy(): Promise<MessageResponse> {
  const mnemonic = session?.getMnemonic()
  if (!mnemonic) {
    throw new Error('Backend instance not authorized')
  }

  if(proxy !== null) {
    setConnectionProxy(null)

    await setSessionHandler({
      mnemonic
    })
  }

  return { ok: true }
}