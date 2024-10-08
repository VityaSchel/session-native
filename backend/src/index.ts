import type { Poller, Session } from '@session.js/client'
import { createServer, type Socket } from 'net'
import { join } from 'path'
import { unlinkSync, existsSync, mkdirSync, appendFileSync } from 'fs'
import { decode, encode } from '@msgpack/msgpack'
import { processMessage } from './routes'
import { z } from 'zod'
import { addEventsHandlers, removeEventsHandlers } from '@/events'

// @ts-expect-error Disable ssl check as all security is handled by Signal protocol
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = 0
process.env['NODE_ENV'] = 'development'

const { HOME } = Bun.env

const homeArg = Bun.argv.find(arg => arg === '--home')
const homeDirArg = homeArg ? Bun.argv[Bun.argv.indexOf(homeArg) + 1] : null

let home = HOME || homeDirArg

if (!home) {
  throw new Error('HOME environment variable not set')
}
if (!home?.includes('Library/Containers/dev.hloth.Session-Native/Data')) {
  home = join(home, 'Library/Containers/dev.hloth.Session-Native/Data')
}
const socketPath = join(home, 'tmp/bun_socket')
const logDir = join(home, 'tmp')
const logFile = join(logDir, 'app.log')

if (!existsSync(logDir)) {
  mkdirSync(logDir, { recursive: true })
}

type ProxyOptions = { hostname: string, port: number, username?: string, password?: string, protocol: 'https' | 'http' }

export let unixSocket: Socket

export let session: Session | null = null
export let poller: Poller | null = null
export let pollingIntervalId: Timer | null = null
export let proxy: ProxyOptions | null = null
export const setConnectionProxy = (newProxy: ProxyOptions | null) => {
  proxy = newProxy
}
export const setSessionObject = (objects: {
  newSession: Session,
  newPoller: Poller
} | null) => {
  if (session) {
    removeEventsHandlers(session)
  }
  if (pollingIntervalId !== null) {
    clearInterval(pollingIntervalId)
  }

  session = objects === null ? null : objects.newSession
  poller = objects === null ? null : objects.newPoller
  pollingIntervalId = setInterval(async () => {
    if (poller) {
      await poller.poll()
        .then(() => {
          unixSocket.write(encode({
            event: 'connection_report',
            connected: true,
          }))
        })
        .catch(e => {
          console.error('Polling error:', e instanceof Error ? e.toString() : 'Unknown unhandled error')
          unixSocket.write(encode({
            event: 'connection_report',
            connected: false,
            connectionError: e instanceof Error ? e.toString() : 'Unknown unhandled error',
          }))
        })
    } else {
      clearInterval(pollingIntervalId!)
    }
  }, 2500)

  if (objects?.newSession) {
    addEventsHandlers(objects.newSession)
  }
}

export const log = (...message: unknown[]) => {
  const timestamp = new Date().toLocaleString()
  let logMessage = `[${timestamp}] `
  logMessage += message.map((m) => {
    if (m instanceof Error) {
      return m.message + '\n' + m.stack
    } else if (typeof m === 'object') {
      return JSON.stringify(m)
    } else {
      return m
    }
  }).join(' ')
  appendFileSync(logFile, logMessage + '\n', { encoding: 'utf8' })
}

try {
  log('Started')

  if (existsSync(socketPath)) {
    try {
      log('Removed old socket file')
      unlinkSync(socketPath)
    } catch (err) {
      log('Failed to remove existing socket file:', err)
    }
  }

  const server = createServer((socket) => {
    unixSocket = socket

    let buffers: Buffer[] = []

    socket.on('data', async (data) => {
      log('Received', data.length, 'bytes')

      let concatenatedData: Buffer
      if(data.length > 64 && data.subarray(-64).every(b => b === 0x03)) {
        concatenatedData = Buffer.concat([...buffers, data]).subarray(0, -64)
        buffers = []
      } else {
        buffers.push(data)
        return
      }

      const message = decode(concatenatedData)
      const requestIdData = await z.object({ requestId: z.string() }).safeParseAsync(message)
      let requestId: string | null = null
      if (requestIdData.success) {
        requestId = requestIdData.data.requestId
      }

      let response: object
      try {
        response = await processMessage(message)
      } catch(e) {
        console.error(e)
        response = { ok: false, error: (e instanceof Error ? e.toString() : 'Unknown unhandled error') }
      }

      socket.write(encode({ ...response, requestId }))
    })

    socket.on('error', (err) => {
      console.error('Socket error:', err)
    })
  })

  server.listen(socketPath, () => {
    console.log(`Server listening on ${socketPath}`)
  })

  server.on('error', (err) => {
    log('Server error', err)
    console.error('Server error:', err)
  })
} catch(e) {
  if(e instanceof Error) {
    log(e.toString())
  } else {
    log('Fatal unhandled error')
  }
  throw e
}
