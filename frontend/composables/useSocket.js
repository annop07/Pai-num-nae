import { io } from 'socket.io-client'
import {ref,onMounted,onUnmounted} from 'vue'
import {useAuth} from './useAuth'

export function useSocket() {
    const config = useRuntimeConfig()
    const {token} = useAuth()
    const socket = ref(null)
    const connected = ref(false)

    onMounted(() => {
        if (!token.value) return

        socket.value = io(config.public.apiBase.replace('/api/', ''), {
            auth: {
                token: token.value
            }
        });

        socket.value.on('connect', () => {
            connected.value = true
            console.log('Socket connected')
        });

        socket.value.on('disconnect', () => {
            connected.value = false
            console.log('Socket disconnected')
        });

        socket.value.on('error', (err) => {
            console.error('Socket error:', err)
        });
        
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