import { ref, computed } from 'vue'

export function useChat() {
  const { $api } = useNuxtApp()
  const { user } = useAuth()

  const chatRooms = ref([])
  const messages = ref([])
  const loading = ref(false)
  const messagesLoading = ref(false)

  const currentUserId = computed(() => {
    const u = user.value
    if (typeof u === 'string') {
      try {
        return JSON.parse(u)?.id
      } catch {
        return null
      }
    }
    return u?.id || null
  })

  const formatTime = (dateStr) => {
    const d = new Date(dateStr)
    return `${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`
  }

  const formatRelativeTime = (dateStr) => {
    const d = new Date(dateStr)
    const now = new Date()
    const diff = now - d
    if (diff < 60000) return 'Now'
    if (diff < 3600000) return `${Math.floor(diff / 60000)}m`
    if (diff < 86400000) return formatTime(dateStr)
    if (diff < 172800000) return 'Yesterday'
    return d.toLocaleDateString()
  }

  const getLastMessagePreview = (lastMsg) => {
    if (!lastMsg) return '-'
    if (lastMsg.messageType === 'FILE') return lastMsg.attachments?.length ? '📎 ส่งรูปภาพ/ไฟล์' : '📎 แนบไฟล์'
    if (lastMsg.messageType === 'LOCATION') return '📍 ส่งตำแหน่ง'
    return lastMsg.content?.trim() || '-'
  }

  const transformRoomToChat = (room) => {
    const admin = room.admin
    const incident = room.incident || {}
    const lastMsg = room.messages?.[0]
    // ChatRoom.incident.title → chat.name
    const name = incident.title || `${admin?.firstName || ''} ${admin?.lastName || ''}`.trim() || 'แชท'
    // ChatRoom.admin → chat.avatar
    const avatar =
      admin?.profilePicture ||
      `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=DBEAFE&color=2563EB`
    // ChatRoom.admin → chat.online (REST API ไม่ส่ง online, เชื่อม Socket.IO แล้วอัปเดตได้)
    const online = false

    return {
      id: room.id,
      name,
      role: admin ? 'Administrator' : 'Incident',
      avatar,
      lastMessage: getLastMessagePreview(lastMsg),
      lastTime: lastMsg ? formatRelativeTime(lastMsg.createdAt) : '-',
      unread: 0,
      online,
      status: room.status,
      admin,
      incident,
    }
  }

  const getMessageDisplayText = (msg) => {
    if (msg.messageType === 'FILE') return msg.attachments?.length ? '📎 รูปภาพ/ไฟล์' : ''
    if (msg.messageType === 'LOCATION') return msg.location?.address || '📍 ตำแหน่ง'
    return msg.content || ''
  }

  const transformMessageToUI = (msg) => {
    // Message.sender → msg.sender (user/admin): เทียบ senderId กับ currentUser
    const isCurrentUser = msg.senderId === currentUserId.value || msg.sender?.id === currentUserId.value
    const sender = isCurrentUser ? 'user' : 'admin'
    const senderInfo = msg.sender
    const nameForAvatar = [senderInfo?.firstName, senderInfo?.lastName].filter(Boolean).join(' ').trim() || 'User'
    const otherAvatar =
      senderInfo?.profilePicture ||
      `https://ui-avatars.com/api/?name=${encodeURIComponent(nameForAvatar)}&background=EBF4FF&color=2563EB`

    return {
      id: msg.id,
      sender,
      text: getMessageDisplayText(msg),
      // Message.createdAt → msg.time (format)
      time: formatTime(msg.createdAt),
      createdAt: msg.createdAt,
      messageType: msg.messageType || 'TEXT',
      attachments: msg.attachments || [],
      location: msg.location,
      senderInfo,
      otherAvatar,
    }
  }

  const formatDate = (dateStr) => {
    const d = new Date(dateStr)
    return d.toLocaleDateString('th-TH', { day: 'numeric', month: 'long', year: 'numeric' })
  }

  const fetchChatRooms = async () => {
    loading.value = true
    try {
      const rooms = await $api('/chat/rooms')
      chatRooms.value = (rooms || []).map(transformRoomToChat)
    } catch (err) {
      console.error('fetchChatRooms error:', err)
    } finally {
      loading.value = false
    }
  }

  const fetchMessages = async (roomId) => {
    if (!roomId) return
    messagesLoading.value = true
    messages.value = []
    try {
      const room = await $api(`/chat/rooms/${roomId}`)
      const msgs = room?.messages || []
      messages.value = msgs.map(transformMessageToUI)
    } catch (err) {
      console.error('fetchMessages error:', err)
    } finally {
      messagesLoading.value = false
    }
  }

  const sendMessageAPI = async (roomId, data) => {
    const res = await $api(`/chat/rooms/${roomId}/messages`, {
      method: 'POST',
      body: {
        messageType: data.messageType || 'TEXT',
        content: data.content,
        attachments: data.attachments,
        location: data.location,
      },
    })
    return res
  }

  const uploadFiles = async (roomId, files) => {
    const formData = new FormData()
    for (const file of files) {
      formData.append('files', file)
    }
    const res = await $api(`/chat/rooms/${roomId}/upload`, {
      method: 'POST',
      body: formData,
    })
    return res?.urls || []
  }

  return {
    chatRooms,
    messages,
    loading,
    messagesLoading,
    fetchChatRooms,
    fetchMessages,
    sendMessageAPI,
    uploadFiles,
    formatTime,
    formatRelativeTime,
    formatDate,
    transformRoomToChat,
    transformMessageToUI,
  }
}
