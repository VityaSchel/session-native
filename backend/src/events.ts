import type { Session } from '@session.js/client'
import { unixSocket } from './index'
import { encode } from '@msgpack/msgpack'
import type { Message, MessageDeleted, MessageReadEvent, MessageTypingIndicator } from 'node_modules/@session.js/client/dist/messages'

const onMessage = (message: Message) => {
  unixSocket.write(encode({
    event: 'new_message',
    message: {
      id: message.id,
      from: message.from,
      author: {
        displayName: message.author.displayName,
        ...(message.author.avatar && {
          avatar: {
            url: message.author.avatar.url,
            key: Buffer.from(message.author.avatar.key).toString('hex')
          }
        })
      },
      text: message.text,
      attachments: message.attachments,
      replyToMessage: message.replyToMessage,
      timestamp: message.timestamp
    }
  }))
}

const onMessageDeleted = (message: MessageDeleted) => {
  console.log('message_deleted', message)
  unixSocket.write(encode({
    event: 'message_deleted',
    message
  }))
}

const onMessageTypingIndicator = (indicator: MessageTypingIndicator) => {
  unixSocket.write(encode({
    event: 'typing_indicator',
    indicator
  }))
}

const onMessageRead = (message: MessageReadEvent) => {
  unixSocket.write(encode({
    event: 'message_read',
    message
  }))
}

export function removeEventsHandlers(session: Session) {
  session.off('message', onMessage)
  session.off('messageDeleted', onMessageDeleted)
  session.off('messageTypingIndicator', onMessageTypingIndicator)
  session.off('messageRead', onMessageRead)
}

export function addEventsHandlers(session: Session) {
  session.on('message', onMessage)
  session.on('messageDeleted', onMessageDeleted)
  session.on('messageTypingIndicator', onMessageTypingIndicator)
  session.on('messageRead', onMessageRead)
}