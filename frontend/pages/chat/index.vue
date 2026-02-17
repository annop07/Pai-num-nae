<template>
  <div class="flex h-[calc(100vh-64px)] bg-gray-50 font-kanit">
    <!-- Sidebar (Left) -->
    <div
      class="w-full md:w-80 lg:w-96 bg-white border-r border-gray-200 flex flex-col transition-all duration-300"
      :class="{ 'hidden md:flex': activeChatId && isMobile }"
    >
      <!-- Sidebar Header -->
      <div
        class="px-6 py-4 border-b border-gray-100 flex items-center justify-between"
      >
        <div class="flex items-center space-x-2">
          <h2 class="text-xl font-bold text-gray-800">Inbox</h2>
          <span
            class="px-2 py-0.5 text-xs font-medium text-blue-600 bg-blue-100 rounded-full"
            >2 New</span
          >
        </div>
        <!-- Settings Icon (Optional) -->
        <button class="text-gray-400 hover:text-gray-600">
          <svg
            class="w-5 h-5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
            />
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
            />
          </svg>
        </button>
      </div>

      <!-- Search Bar -->
      <div class="px-6 py-3">
        <div class="relative">
          <input
            type="text"
            placeholder="Search..."
            class="w-full pl-10 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all"
          />
          <svg
            class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            />
          </svg>
        </div>
      </div>

      <!-- User List -->
      <div class="flex-1 overflow-y-auto custom-scrollbar">
        <div
          v-for="chat in chatList"
          :key="chat.id"
          @click="selectChat(chat)"
          class="px-6 py-4 flex items-start space-x-4 hover:bg-gray-50 cursor-pointer border-l-4 transition-all duration-200"
          :class="
            activeChatId === chat.id
              ? 'border-blue-600 bg-blue-50/50'
              : 'border-transparent'
          "
        >
          <div class="relative flex-shrink-0">
            <img
              :src="chat.avatar"
              class="w-12 h-12 rounded-full object-cover shadow-sm"
              alt="Avatar"
            />
            <span
              v-if="chat.online"
              class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"
            ></span>
          </div>

          <div class="flex-1 min-w-0">
            <div class="flex items-center justify-between mb-1">
              <h3
                class="text-sm font-semibold text-gray-900 truncate"
                :class="{ 'text-blue-600': activeChatId === chat.id }"
              >
                {{ chat.name }}
              </h3>
              <span class="text-xs text-gray-400">{{ chat.lastTime }}</span>
            </div>
            <p class="text-xs text-gray-500 font-medium mb-1">
              {{ chat.role }}
            </p>
            <p
              class="text-sm text-gray-600 truncate"
              :class="{ 'font-medium text-gray-900': chat.unread > 0 }"
            >
              {{ chat.lastMessage }}
            </p>
          </div>

          <div v-if="chat.unread > 0" class="flex-shrink-0 self-center ml-2">
            <span
              class="flex items-center justify-center w-5 h-5 text-xs font-bold text-white bg-red-500 rounded-full shadow-sm"
            >
              {{ chat.unread }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Chat Area (Right) -->
    <div
      class="flex-1 flex flex-col bg-gray-50 relative"
      :class="{ 'hidden md:flex': !activeChatId && isMobile }"
    >
      <!-- Mobile Back Button Header (Only visible on mobile when chat is active) -->
      <div
        class="md:hidden flex items-center px-4 py-3 bg-white shadow-sm border-b border-gray-200 z-10"
      >
        <button
          @click="activeChatId = null"
          class="mr-3 p-1 rounded-full hover:bg-gray-100 text-gray-600"
        >
          <svg
            class="w-6 h-6"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M15 19l-7-7 7-7"
            />
          </svg>
        </button>
        <div class="flex items-center space-x-3">
          <div class="relative">
            <img
              :src="
                activeChat?.avatar ||
                'https://ui-avatars.com/api/?name=Admin&background=EBF4FF&color=2563EB'
              "
              class="w-8 h-8 rounded-full shadow-sm"
            />
            <span
              v-if="activeChat?.online"
              class="absolute bottom-0 right-0 w-2.5 h-2.5 bg-green-500 border-2 border-white rounded-full"
            ></span>
          </div>
          <div>
            <h1 class="text-base font-semibold text-gray-800">
              {{ activeChat?.name || "เลือกแชท" }}
            </h1>
          </div>
        </div>
      </div>

      <!-- Desktop Header -->
      <div
        class="hidden md:flex items-center justify-between px-6 py-4 bg-white shadow-sm border-b border-gray-200 z-10"
      >
        <div class="flex items-center space-x-4">
          <div class="relative">
            <img
              :src="
                activeChat?.avatar ||
                'https://ui-avatars.com/api/?name=Admin&background=EBF4FF&color=2563EB'
              "
              class="w-10 h-10 rounded-full shadow-sm object-cover"
            />
            <span
              v-if="activeChat?.online"
              class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"
            ></span>
          </div>
          <div>
            <h1 class="text-lg font-bold text-gray-800">
              {{ activeChat?.name || "Welcome" }}
            </h1>
            <p
              class="text-xs text-green-500 font-medium flex items-center gap-1"
            >
              <span
                v-if="activeChat?.online"
                class="w-1.5 h-1.5 bg-green-500 rounded-full"
              ></span>
              {{ activeChat?.online ? "Online" : "Offline" }}
            </p>
          </div>
        </div>
        <button class="text-gray-400 hover:text-gray-600">
          <svg
            class="w-6 h-6"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z"
            />
          </svg>
        </button>
      </div>

      <!-- Empty State -->
      <div
        v-if="!activeChatId && !isMobile"
        class="flex-1 flex flex-col items-center justify-center text-center p-8 bg-gray-50"
      >
        <div
          class="w-24 h-24 bg-blue-100 rounded-full flex items-center justify-center mb-6 animate-pulse"
        >
          <svg
            class="w-12 h-12 text-blue-600"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
            />
          </svg>
        </div>
        <h3 class="text-xl font-bold text-gray-800 mb-2">
          ยินดีต้อนรับสู่ระบบแชท
        </h3>
        <p class="text-gray-500 max-w-sm">
          เลือกรายการแชททางซ้ายมือเพื่อเริ่มสนทนากับแอดมินหรือคนขับรถของคุณ
        </p>
      </div>

      <!-- Chat Content -->
      <template v-else>
        <!-- Messages Area -->
        <div
          class="flex-1 px-4 md:px-6 py-6 overflow-y-auto custom-scrollbar space-y-6"
          ref="chatContainer"
        >
          <!-- Loading Messages -->
          <div
            v-if="messagesLoading"
            class="flex justify-center items-center py-12"
          >
            <div
              class="w-8 h-8 border-2 border-blue-600 border-t-transparent rounded-full animate-spin"
            ></div>
          </div>

          <!-- Date Divider (แสดงเมื่อมี messages และไม่ใช่ loading) -->
          <div
            v-else-if="messages.length > 0 && displayDate"
            class="flex justify-center my-6"
          >
            <span
              class="px-4 py-1.5 text-xs font-medium text-gray-500 bg-gray-200/60 rounded-full shadow-sm backdrop-blur-sm"
              >{{ displayDate }}</span
            >
          </div>

          <!-- Messages Loop -->
          <div
            v-for="(msg, index) in messages"
            :key="msg.id || index"
            class="flex flex-col space-y-1 w-full"
            :class="msg.sender === 'user' ? 'items-end' : 'items-start'"
          >
            <div
              class="flex items-end max-w-[85%] md:max-w-[65%] gap-3"
              :class="msg.sender === 'user' ? 'flex-row-reverse' : 'flex-row'"
            >
              <!-- Avatar (ใช้ otherAvatar สำหรับข้อความจากอีกฝั่ง) -->
              <img
                v-if="msg.sender === 'admin'"
                :src="msg.otherAvatar || activeChat?.avatar || 'https://ui-avatars.com/api/?name=Admin&background=EBF4FF&color=2563EB'"
                class="w-8 h-8 rounded-full shadow-sm self-end mb-1 object-cover"
                alt="Avatar"
              />

              <!-- Message Bubble -->
              <div class="relative group">
                <div
                  class="px-5 py-3.5 rounded-2xl shadow-sm text-sm md:text-base leading-relaxed break-words"
                  :class="[
                    msg.sender === 'user'
                      ? 'bg-blue-600 text-white rounded-br-sm'
                      : 'bg-white text-gray-800 rounded-bl-sm border border-gray-100',
                  ]"
                >
                  <!-- TEXT -->
                  <template v-if="msg.messageType === 'TEXT'">
                    {{ msg.text }}
                  </template>
                  <!-- FILE (รูปภาพ/ไฟล์) -->
                  <template v-else-if="msg.messageType === 'FILE'">
                    <div v-if="msg.attachments?.length" class="space-y-2">
                      <template v-for="(url, i) in msg.attachments" :key="i">
                        <img
                          v-if="isImageUrl(url)"
                          :src="url"
                          class="max-w-full max-h-48 rounded-lg object-cover"
                          alt="รูปภาพ"
                        />
                        <a
                          v-else
                          :href="url"
                          target="_blank"
                          rel="noopener"
                          class="text-blue-500 underline break-all"
                        >
                          เปิดไฟล์
                        </a>
                      </template>
                    </div>
                    <span v-else>{{ msg.text || '📎 ไฟล์แนบ' }}</span>
                  </template>
                  <!-- LOCATION -->
                  <template v-else-if="msg.messageType === 'LOCATION' && msg.location">
                    <a
                      :href="`https://maps.google.com/?q=${msg.location.lat},${msg.location.lng}`"
                      target="_blank"
                      rel="noopener"
                      class="inline-flex items-center gap-2 text-blue-500 hover:underline"
                    >
                      <span>📍</span>
                      {{ msg.location.address || 'ดูตำแหน่งบนแผนที่' }}
                    </a>
                  </template>
                  <template v-else>
                    {{ msg.text }}
                  </template>
                </div>
                <span
                  class="text-[10px] text-gray-400 mt-1 block"
                  :class="msg.sender === 'user' ? 'text-right mr-1' : 'ml-1'"
                >
                  {{ msg.time }}
                </span>
              </div>
            </div>
          </div>

          <!-- Typing Indicator -->
          <div v-if="isTyping" class="flex items-start gap-3">
            <img
              :src="
                activeChat?.avatar ||
                'https://ui-avatars.com/api/?name=Admin&background=EBF4FF&color=2563EB'
              "
              class="w-8 h-8 rounded-full shadow-sm mb-1"
            />
            <div
              class="px-4 py-3 bg-white rounded-2xl rounded-bl-sm shadow-sm border border-gray-100"
            >
              <div class="flex space-x-1.5 items-center h-full">
                <div
                  class="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce"
                  style="animation-delay: 0ms"
                ></div>
                <div
                  class="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce"
                  style="animation-delay: 150ms"
                ></div>
                <div
                  class="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce"
                  style="animation-delay: 300ms"
                ></div>
              </div>
            </div>
          </div>
        </div>

        <!-- Input Area -->
        <div class="p-4 md:p-6 bg-white border-t border-gray-200">
          <form
            @submit.prevent="sendMessage"
            class="flex items-end gap-3 max-w-5xl mx-auto"
          >
            <!-- Tools Button (Left Side) -->
            <div class="flex items-center space-x-1 mb-2">
              <button
                type="button"
                class="p-2 text-gray-400 hover:text-blue-600 rounded-full hover:bg-blue-50 transition-colors"
                title="แนบไฟล์"
                <input type = "file" ref="fileInput" @change="handleFileUpload">
              >
                <svg
                  class="w-6 h-6"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13"
                  />
                </svg>
              </button>
              <button
                type="button"
                class="p-2 text-gray-400 hover:text-blue-600 rounded-full hover:bg-blue-50 transition-colors"
                title="ส่งตำแหน่ง"
              >
                <svg
                  class="w-6 h-6"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
                  />
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"
                  />
                </svg>
              </button>
              <button
                type="button"
                class="p-2 text-gray-400 hover:text-blue-600 rounded-full hover:bg-blue-50 transition-colors md:hidden"
                title="Emoji"
              >
                <svg
                  class="w-6 h-6"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
              </button>
            </div>

            <div
              class="flex-1 relative bg-gray-50 rounded-2xl border border-gray-200 focus-within:ring-2 focus-within:ring-blue-500/20 focus-within:border-blue-500 transition-all"
            >
              <textarea
                v-model="newMessage"
                rows="1"
                placeholder="Write a message..."
                class="w-full pl-4 pr-12 py-3.5 bg-transparent border-none focus:ring-0 text-gray-700 resize-none max-h-32 min-h-[48px]"
                @keydown.enter.exact.prevent="sendMessage"
                @input="handleTyping"
                style="line-height: 1.5"
              ></textarea>

              <!-- Emoji inside input (Desktop only) -->
              <div
                class="hidden md:flex absolute right-2 bottom-2 items-center"
              >
                <button
                  type="button"
                  class="p-2 text-gray-400 hover:text-gray-600 rounded-full hover:bg-gray-100 transition-colors"
                >
                  <svg
                    class="w-5 h-5"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                </button>
              </div>
            </div>

            <button
              type="submit"
              :disabled="!newMessage.trim() || sendMessageLoading"
              class="p-3.5 bg-blue-600 text-white rounded-xl shadow-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed transform active:scale-95 transition-all duration-200 flex-shrink-0 mb-2"
            >
              <svg
                class="w-5 h-5 translate-x-0.5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M13 5l7 7-7 7M5 5l7 7-7 7"
                />
              </svg>
            </button>
          </form>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick, computed, watch } from "vue";
import { useChat } from "@/composables/useChat";
import { useSocket } from "@/composables/useSocket";

let typingTimeout = null;

const {
  chatRooms,
  messages,
  loading,
  messagesLoading,
  fetchChatRooms,
  fetchMessages,
  formatDate,
  transformMessageToUI,
  getLastMessagePreview,
  formatRelativeTime,
} = useChat();

const {
  socket,
  connected,
  joinChat,
  sendMessage: socketSendMessage,
  onNewMessage,
  onTyping,
  emitTyping,
} = useSocket();


const chatContainer = ref(null);
const newMessage = ref("");
const isTyping = ref(false);
const activeChatId = ref(null);
const isMobile = ref(false);
const sendMessageLoading = ref(false);
let typingTimeout = null;

// ใช้ chatRooms เป็น chatList ใน template
const chatList = computed(() => chatRooms.value);

const activeChat = computed(() =>
  chatList.value.find((c) => c.id === activeChatId.value),
);

const displayDate = computed(() => {
  const first = messages.value[0];
  return first?.createdAt ? formatDate(first.createdAt) : "";
});

const scrollToBottom = () => {
  nextTick(() => {
    if (chatContainer.value) {
      chatContainer.value.scrollTop = chatContainer.value.scrollHeight;
    }
  });
};

const selectChat = async (chat) => {
  activeChatId.value = chat.id;
  chat.unread = 0;
  await fetchMessages(chat.id);
  scrollToBottom();
};

//อนิทเมชั่นการพิมพ์
const handleTyping = () => {
  if(!activeChatId.value) return;

  emitTyping(activeChatId.value);

  //Clear timeout
  if (typingTimeout) clearTimeout(typingTimeout);

  typingTimeout = setTimeout(() => {
    
  }, 3000);
}

const sendMessage = () => {
  if(!newMessage.value.trim() || !activeChatId.value) return;
  if(sendMessageLoading.value) return; //ไม่ให้กดซ้ำ
  
  const messageText = newMessage.value
  newMessage.value = '' //clear อินพุ้ต
  sendMessageLoading.value = true;

  try{
    //ส่งผ่าน WebSocket
    socketSendMessage({
      chatRoomId: activeChatId.value,
      messageType: 'TEXT',
      content: messageText,
    })
  } catch(error){
    console.error('send Message error:', error);
    newMessage.value = messageText;
  } finally {
    sendMessageLoading.value = false;
    scrollToBottom();
  }
};

const checkMobile = () => {
  isMobile.value = window.innerWidth < 768;
};

const isImageUrl = (url) => {
  if (!url || typeof url !== 'string') return false;
  return /\.(jpg|jpeg|png|gif|webp)(\?|$)/i.test(url) || url.includes('cloudinary') || url.includes('image');
};

watch(activeChatId,(newChatId,oldChatId) => {
  if(newChatId && connected.value){
    joinChat(newChatId);
    console.log('Joined chat room:', newChatId);
  }
})

onMounted(() => {
  scrollToBottom();
  fetchChatRooms();
  checkMobile();
  window.addEventListener("resize", checkMobile);

  // รับข้อความจาก Socket
  onNewMessage((message) => {
    console.log('Received new message:', message);
    
    const uiMessage = transformMessageToUI(message);

    // เพิ่มเข้า messages ถ้าอยู่ใน active chat
    if (message.chatRoomId === activeChatId.value) {
      messages.value.push(uiMessage);
      scrollToBottom();
    }

    // อัปเดต lastMessage ใน sidebar
    const chatIndex = chatList.value.findIndex(c => c.id === message.chatRoomId);
    if (chatIndex !== -1) {
      chatList.value[chatIndex].lastMessage = getLastMessagePreview({
        content: message.content,
        messageType: message.messageType,
        attachments: message.attachments
      });
      chatList.value[chatIndex].lastTime = 'Now';
      
      // เลื่อน chat นี้ขึ้นมาด้านบน
      const chat = chatList.value.splice(chatIndex, 1)[0];
      chatList.value.unshift(chat);
    }
  });

  // ฟัง typing indicator
  onTyping((data) => {
    console.log('User typing:', data);
    if (data.chatRoomId === activeChatId.value) {
      isTyping.value = true;
      // ซ่อนหลัง 3 วินาที
      setTimeout(() => {
        isTyping.value = false;
      }, 3000);
    }
  });

  if (activeChatId.value && connected.value) {
    joinChat(activeChatId.value)
  }
});

definePageMeta({
  middleware: ["auth"],
});
</script>

<style scoped>
.font-kanit {
  font-family: "Kanit", sans-serif;
}

/* Custom Scrollbar */
.custom-scrollbar::-webkit-scrollbar {
  width: 5px;
}

.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}

.custom-scrollbar::-webkit-scrollbar-thumb {
  background-color: #e2e8f0;
  border-radius: 20px;
}

.custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background-color: #cbd5e1;
}
</style>
