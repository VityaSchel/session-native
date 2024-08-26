import { ready } from '@session.js/client'
import { z } from 'zod'
import { mnemonicToSessionId } from '@/routes/mnemonic-to-session-id'
import { generateSession } from '@/routes/generate-session'
import { resolveONS } from '@/routes/resolve-ons'
import { setDisplayName } from '@/routes/set-display-name'
import { setAvatar } from '@/routes/set-avatar'
import { setSession } from '@/routes/set-session'
import { logoutSession } from '@/routes/logout-session'
import { sendMessage } from '@/routes/send-message'
import { setTypingIndicator } from '@/routes/set-typing-indicator'
import { markAsRead } from '@/routes/mark-as-read'
import { deleteMessages } from '@/routes/delete-messages'
import { downloadAvatar } from '@/routes/download-avatar'
import { downloadFile } from '@/routes/download-file'
import { poller } from '@/index'
await ready

enum MessageType {
  Ping = 'ping',
  MnemonicToSessionId = 'mnemonic_to_session_id',
  GenerateSession = 'generate_session',
  ResolveONS = 'resolve_ons',
  SetSession = 'set_session',
  SetDisplayName = 'set_display_name',
  SetAvatar = 'set_avatar',
  LogoutSession = 'logout_session',
  SendMessage = 'send_message',
  SetTypingIndicator = 'set_typing_indicator',
  MarkAsRead = 'mark_as_read',
  DeleteMessages = 'delete_messages',
  StartPolling = 'start_polling',
  StopPolling = 'stop_polling',
  DownloadAvatar = 'download_avatar',
  DownloadFile = 'download_file',
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
    case MessageType.SetDisplayName:
      return setDisplayName(message)
    case MessageType.SetAvatar:
      return setAvatar(message)
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
    case MessageType.DownloadAvatar:
      return downloadAvatar(message)
    case MessageType.DownloadFile:
      return downloadFile(message)
  }
}