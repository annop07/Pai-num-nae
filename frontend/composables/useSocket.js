import { io } from 'socket.io-client'
import {ref,onMounted,onUnmounted,watch} from 'vue'
import {useAuth} from './useAuth'

export function useSocket() {
    const config = useRuntimeConfig()
    const {token} = useAuth()
    const socket = ref(null)
    const connected = ref(false)

    const initSocket = () => {
        if (!token.value) {
            console.warn('⚠️ Token not found, cannot connect WebSocket')
            return
        }

        if (socket.value?.connected) {
            console.log('✅ Socket already connected')
            return
        }

        const socketUrl = config.public.apiBase.replace('/api', '')
        console.log('🔌 Attempting to connect to WebSocket:', socketUrl)

        socket.value = io(socketUrl, {
            auth: {
                token: token.value
            },
            transports: ['websocket', 'polling'],
            reconnection: true,
            reconnectionDelay: 1000,
            reconnectionDelayMax: 5000,
            reconnectionAttempts: 5
        });

        socket.value.on('connect', () => {
            connected.value = true
            console.log('✅ Socket connected successfully')
        });

        socket.value.on('disconnect', (reason) => {
            connected.value = false
            console.log('❌ Socket disconnected:', reason)
        });

        socket.value.on('connect_error', (err) => {
            connected.value = false
            console.error('❌ Socket connection error:', err.message)
        });

        socket.value.on('error', (err) => {
            console.error('❌ Socket error:', err)
        });
    }

    onMounted(() => {
        initSocket()
    });

    onUnmounted(() => {
        if (socket.value) {
            socket.value.disconnect()
        }
    });

    const joinChat = (chatRoomId) => {
        socket.value?.emit('join_chat', chatRoomId)
    };

    const sendMessage = (data) =>{
        socket.value?.emit('send_message', data)
    };

    const onNewMessage = (callback) => {
        socket.value?.on('new_message', callback)
    };

    const onTyping = (callback) => {
        socket.value?.on('user_typing', callback)
    };

    const emitTyping = (chatRoomId) => {
        socket.value?.emit('typing', chatRoomId)
    };

    return {
        socket,
        connected,
        joinChat,
        sendMessage,
        onNewMessage,
        onTyping,
        emitTyping
    };
}