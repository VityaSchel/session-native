import { z } from 'zod'
import { type MessageResponse } from '@/routes'
import { session, setConnectionProxy } from '@/index'
import { setSessionHandler } from '@/routes/set-session'

export async function setProxy(message: unknown): Promise<MessageResponse> {
  const {
    hostname,
    port,
    username,
    password,
    protocol
  } = z.object({
    protocol: z.enum(['https', 'http']),
    hostname: z.string(),
    port: z.number(),
    username: z.string().optional(),
    password: z.string().optional()
  }).parse(message)
  
  const mnemonic = session?.getMnemonic()
  if(!mnemonic) {
    throw new Error('Backend instance not authorized')
  }
    
  let proxyTimeout: Timer | undefined, connectionTester: Worker | undefined
  try {
    await new Promise<void>((resolve, reject) => {
      proxyTimeout = setTimeout(() => {
        reject('Proxy connection timeout')
      }, 5000)
      
      const blob = new Blob(
        [`
          self.addEventListener('message', async (event: MessageEvent) => {
            const request = await fetch('http://seed1.getsession.org/json_rpc', {
              method: 'POST',
              body: JSON.stringify({ 'method': 'get_version' }),
              headers: {'Content-Type': 'application/json'},
              proxy: event.data.proxy,
            }).then(res => res.text())
            try {
              const response = JSON.parse(request)
              postMessage(response['result']['status'] === 'OK')
            } catch(e) {
              throw 'Couldn\\'t parse json: ' + request
            }
          })
        `],
        { type: 'application/typescript' },
      )
      connectionTester = new Worker(URL.createObjectURL(blob))
      connectionTester.postMessage({ 
        proxy: (username && password)
          ? `${protocol}://${username}:${password}@${hostname}:${port}`
          : `${protocol}://${hostname}:${port}`
      })
      connectionTester.addEventListener('message', (event: MessageEvent) => {
        if(event.data === true) {
          resolve()
        } else {
          console.log('failed')
          reject('Proxy connection failed')
        }
      })
      connectionTester.addEventListener('error', (e) => {
        console.log('error in', e)
        reject('Proxy connection failed')
      })
    })
  } catch(e) {
    console.log('error out')
    return { ok: false, error: 'Proxy connection failed' }
  } finally {
    clearTimeout(proxyTimeout)
    connectionTester?.terminate()
  }

  setConnectionProxy({
    protocol: protocol,
    hostname,
    port,
    username: username ? username : undefined,
    password: password ? password : undefined
  })

  await setSessionHandler({
    mnemonic
  })

  return { ok: true }
}