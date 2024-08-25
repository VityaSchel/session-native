import { ready } from '@session.js/client'
import { z } from 'zod'
import { mnemonicToSessionId } from '@/routes/mnemonic-to-session-id'
import { generateSession } from '@/routes/generate-session'
import { resolveONS } from '@/routes/resolve-ons'
import { setSession } from '@/routes/set-session'
import { logoutSession } from '@/routes/logout-session'
import { sendMessage } from '@/routes/send-message'
import { setTypingIndicator } from '@/routes/set-typing-indicator'
import { markAsRead } from '@/routes/mark-as-read'
import { deleteMessages } from '@/routes/delete-messages'
import { poller } from '@/index'
await ready

enum MessageType {
  Ping = 'ping',
  MnemonicToSessionId = 'mnemonic_to_session_id',
  GenerateSession = 'generate_session',
  ResolveONS = 'resolve_ons',
  SetSession = 'set_session',
  LogoutSession = 'logout_session',
  SendMessage = 'send_message',
  SetTypingIndicator = 'set_typing_indicator',
  MarkAsRead = 'mark_as_read',
  DeleteMessages = 'delete_messages',
  StartPolling = 'start_polling',
  StopPolling = 'stop_polling',
}

export type MessageResponse = {
  ok: true
  [key: string]: any
} | {
  ok: false
  error: string
}

export async function processMessage(message: unknown): Promise<MessageResponse> {
  const { type } = await z.object({
    type: z.nativeEnum(MessageType),
  }).parse(message)
  switch(type) {
    case MessageType.Ping:
      return { ok: true }
    case MessageType.MnemonicToSessionId:
      return mnemonicToSessionId(message)
    case MessageType.GenerateSession:
      return generateSession()
    case MessageType.ResolveONS:
      return resolveONS(message)
    case MessageType.SetSession:
      return setSession(message)
    case MessageType.LogoutSession:
      return logoutSession()
    case MessageType.SendMessage:
      return sendMessage(message)
    case MessageType.SetTypingIndicator:
      return setTypingIndicator(message)
    case MessageType.MarkAsRead:
      return markAsRead(message)
    case MessageType.DeleteMessages:
      return deleteMessages(message)
    case MessageType.StartPolling:
      if (poller) {
        poller.startPolling()
        return { ok: true }
      } else {
        return { ok: false, error: 'Poller not found' }
      }
    case MessageType.StopPolling:
      if (poller) {
        poller.stopPolling()
        return { ok: true }
      } else {
        return { ok: false, error: 'Poller not found' }
      }
  }
}