<template>
  <!-- Toast Notification (Global) -->
  <Transition name="toast">
    <div v-if="toastVisible"
      class="fixed bottom-4 left-1/2 -translate-x-1/2 bg-gray-800 text-white px-6 py-3 rounded-lg shadow-lg z-50">
      {{ toastMessage }}
    </div>
  </Transition>

  <div class="flex h-[calc(100vh-64px)] bg-gray-50 font-kanit">
    <!-- Sidebar (Left) -->
    <div class="w-full md:w-80 lg:w-96 bg-white border-r border-gray-200 flex flex-col transition-all duration-300"
      :class="{ 'hidden md:flex': activeChatId && isMobile }">
      <!-- Sidebar Header -->
      <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
        <div class="flex items-center space-x-2">
          <h2 class="text-xl font-bold text-gray-800">Inbox</h2>
          <span v-if="totalChatUnread > 0"
            class="px-2 py-0.5 text-xs font-medium text-white bg-red-500 rounded-full">
            {{ totalChatUnread }} ข้อความใหม่
          </span>
        </div>
        <!-- Settings Icon (Optional) -->
        <button class="text-gray-400 hover:text-gray-600">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
        </button>
      </div>

      <!-- Search Bar -->
      <div class="px-6 py-3">
        <div class="relative">
          <input type="text" placeholder="Search..."
            class="w-full pl-10 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all" />
          <svg class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" fill="none"
            stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
        </div>
      </div>

      <!-- User List -->
      <div class="flex-1 overflow-y-auto custom-scrollbar">
        <!-- Loading State -->
        <div v-if="loading" class="flex justify-center items-center py-12">
          <div class="w-8 h-8 border-2 border-blue-600 border-t-transparent rounded-full animate-spin"></div>
        </div>

        <!-- Empty State -->
        <div v-else-if="chatList.length === 0" class="px-6 py-12 text-center">
          <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
          </div>
          <p class="text-gray-600 mb-2 font-medium">ยังไม่มีแชท</p>
          <p class="text-sm text-gray-400">การสนทนาจะปรากฏที่นี่เมื่อมี incident</p>
        </div>

        <!-- Chat List -->
        <div v-else v-for="chat in chatList" :key="chat.id" @click="selectChat(chat)"
          class="px-6 py-4 flex items-start space-x-4 hover:bg-gray-50 cursor-pointer border-l-4 transition-all duration-200"
          :class="activeChatId === chat.id
            ? 'border-blue-600 bg-blue-50/50'
            : 'border-transparent'
            ">
          <div class="relative flex-shrink-0">
            <img :src="chat.avatar" class="w-12 h-12 rounded-full object-cover shadow-sm" alt="Avatar" />
            <span v-if="chat.online"
              class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></span>
          </div>

          <div class="flex-1 min-w-0">
            <div class="flex items-center justify-between mb-1">
              <h3 class="text-sm font-semibold text-gray-900 truncate"
                :class="{ 'text-blue-600': activeChatId === chat.id }">
                {{ chat.name }}
              </h3>
              <span class="text-xs text-gray-400">{{ chat.lastTime }}</span>
            </div>
            <p class="text-xs text-gray-500 font-medium mb-1">
              {{ chat.role }}
            </p>
            <p class="text-sm text-gray-600 truncate" :class="{ 'font-medium text-gray-900': getRoomUnread(chat) > 0 }">
              {{ chat.lastMessage }}
            </p>
          </div>

          <div v-if="getRoomUnread(chat) > 0" class="flex-shrink-0 self-center ml-2">
            <span
              class="flex items-center justify-center w-5 h-5 text-xs font-bold text-white bg-red-500 rounded-full shadow-sm"
              title="ข้อความใหม่">
              {{ getRoomUnread(chat) }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Chat Area (Right) -->
    <div class="flex-1 flex flex-col bg-gray-50 relative" :class="{ 'hidden md:flex': !activeChatId && isMobile }">
      <!-- Mobile Back Button Header (Only visible on mobile when chat is active) -->
      <div class="md:hidden flex items-center justify-between px-4 py-3 bg-white shadow-sm border-b border-gray-200 z-10">
        <div class="flex items-center min-w-0 flex-1">
          <button @click="activeChatId = null" class="mr-3 p-1 rounded-full hover:bg-gray-100 text-gray-600 flex-shrink-0">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <div class="flex items-center space-x-3 min-w-0">
            <div class="relative flex-shrink-0">
              <img :src="activeChat?.avatar ||
                'https://ui-avatars.com/api/?name=Admin&background=EBF4FF&color=2563EB'
                " class="w-8 h-8 rounded-full shadow-sm" />
              <span v-if="activeChat?.online"
                class="absolute bottom-0 right-0 w-2.5 h-2.5 bg-green-500 border-2 border-white rounded-full"></span>
            </div>
            <div class="min-w-0">
              <h1 class="text-base font-semibold text-gray-800 truncate">
                {{ activeChat?.name || "เลือกแชท" }}
              </h1>
            </div>
          </div>
        </div>
        <button v-if="isAdmin && activeChat && activeChat.status !== 'CLOSED'"
          @click="handleCloseChat"
          :disabled="closeChatLoading"
          class="p-2 text-amber-600 hover:bg-amber-50 rounded-lg text-sm font-medium flex-shrink-0 disabled:opacity-50"
          title="ปิดการสนทนา">
          <svg v-if="closeChatLoading" class="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
          </svg>
          <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Desktop Header -->
      <div
        class="hidden md:flex items-center justify-between px-6 py-4 bg-white shadow-sm border-b border-gray-200 z-10">
        <div class="flex items-center space-x-4">
          <div class="relative">
            <img :src="activeChat?.avatar ||
              'https://ui-avatars.com/api/?name=Admin&background=EBF4FF&color=2563EB'
              " class="w-10 h-10 rounded-full shadow-sm object-cover" />
            <span v-if="activeChat?.online"
              class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></span>
          </div>
          <div>
            <h1 class="text-lg font-bold text-gray-800">
              {{ activeChat?.name || "Welcome" }}
            </h1>
            <p class="text-xs text-green-500 font-medium flex items-center gap-1">
              <span v-if="activeChat?.online" class="w-1.5 h-1.5 bg-green-500 rounded-full"></span>
              {{ activeChat?.online ? "Online" : "Offline" }}
            </p>
          </div>
        </div>
        <button v-if="isAdmin && activeChat && activeChat.status !== 'CLOSED'"
          @click="handleCloseChat"
          :disabled="closeChatLoading"
          class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-red-600 bg-white border border-red-200 rounded-lg hover:bg-red-50 hover:border-red-300 transition shadow-sm disabled:opacity-50">
          <svg v-if="closeChatLoading" class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
          </svg>
          <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
          {{ closeChatLoading ? 'กำลังปิด...' : 'ปิดการสนทนา' }}
        </button>
      </div>

      <!-- Empty State -->
      <div v-if="!activeChatId && !isMobile"
        class="flex-1 flex flex-col items-center justify-center text-center p-8 bg-gray-50">
        <div class="w-24 h-24 bg-blue-100 rounded-full flex items-center justify-center mb-6 animate-pulse">
          <svg class="w-12 h-12 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
          </svg>
        </div>
        <h3 class="text-xl font-bold text-gray-800 mb-2">
          ยินดีต้อนรับสู่ระบบแชท
        </h3>
        <p class="text-gray-500 max-w-sm">
          เลือกรายการแชททางซ้ายมือเพื่อเริ่มสนทนากับแอดมินหรือคนขับรถของคุณ
        </p>
      </div>

      <!-- Socket Connection Warning (6.5) -->
      <div v-if="activeChatId && !connected" class="px-4 py-2 bg-red-50 text-red-700 text-sm text-center border-b border-red-200">
        <span class="flex items-center justify-center gap-2">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
          ⚠️ ไม่ได้เชื่อมต่อ - ข้อความอาจล่าช้า
        </span>
      </div>

      <!-- Chat Content -->
      <template v-if="activeChatId">
        <!-- Messages Area -->
        <div class="flex-1 px-4 md:px-6 py-6 overflow-y-auto custom-scrollbar space-y-6" ref="chatContainer">
          <!-- Loading Messages -->
          <div v-if="messagesLoading" class="flex justify-center items-center py-12">
            <div class="w-8 h-8 border-2 border-blue-600 border-t-transparent rounded-full animate-spin"></div>
          </div>

          <!-- ข้อความต้อนรับเมื่อยังไม่มีข้อความ -->
          <div v-else-if="messages.length === 0"
            class="flex flex-col items-center justify-center py-12 px-4 text-center">
            <div class="max-w-sm px-6 py-5 bg-blue-50 border border-blue-100 rounded-2xl">
              <p class="text-gray-700 leading-relaxed">
                ยินดีต้อนรับเข้าสู่แชทแอดมิน แอดมินจะรีบตอบกลับให้คุณโดยเร็วที่สุด
              </p>
              <p class="mt-2 text-sm text-gray-500">
                ส่งข้อความหรือแนบไฟล์เพื่อเริ่มสนทนา
              </p>
            </div>
          </div>

          <!-- Date Divider (แสดงเมื่อมี messages และไม่ใช่ loading) -->
          <div v-else-if="messages.length > 0 && displayDate" class="flex justify-center my-6">
            <span
              class="px-4 py-1.5 text-xs font-medium text-gray-500 bg-gray-200/60 rounded-full shadow-sm backdrop-blur-sm">{{
                displayDate }}</span>
          </div>

          <!-- Messages Loop -->
          <div v-for="(msg, index) in messages" :key="msg.id || index" class="flex flex-col space-y-1 w-full"
            :class="msg.sender === 'user' ? 'items-end' : 'items-start'">
            <div class="flex items-end max-w-[85%] md:max-w-[65%] gap-3"
              :class="msg.sender === 'user' ? 'flex-row-reverse' : 'flex-row'">
              <!-- Avatar (ใช้ otherAvatar สำหรับข้อความจากอีกฝั่ง) -->
              <img v-if="msg.sender === 'admin'" :src="msg.otherAvatar ||
                activeChat?.avatar ||
                'https://ui-avatars.com/api/?name=Admin&background=EBF4FF&color=2563EB'
                " class="w-8 h-8 rounded-full shadow-sm self-end mb-1 object-cover" alt="Avatar" />

              <!-- Message Bubble -->
              <div class="relative group">
                <div class="px-5 py-3.5 rounded-2xl shadow-sm text-sm md:text-base leading-relaxed break-words" :class="[
                  msg.sender === 'user'
                    ? 'bg-blue-600 text-white rounded-br-sm'
                    : 'bg-white text-gray-800 rounded-bl-sm border border-gray-100',
                ]">
                  <!-- TEXT -->
                  <template v-if="msg.messageType === 'TEXT'">
                    {{ msg.text }}
                  </template>

                  <!-- FILE (รูปภาพ/วิดีโอ/ไฟล์) -->
                  <template v-else-if="msg.messageType === 'FILE'">
                    <div v-if="msg.attachments?.length" class="space-y-2">
                      <template v-for="(url, i) in msg.attachments" :key="i">
                        <img v-if="isImageUrl(url)" :src="url" class="max-w-full max-h-48 rounded-lg object-cover"
                          alt="รูปภาพ" />
                        <video v-else-if="isVideoUrl(url)" :src="url" controls class="max-w-full max-h-64 rounded-lg"
                          preload="metadata">เบราว์เซอร์ไม่รองรับการเล่นวิดีโอ</video>
                        <a v-else :href="url" target="_blank" rel="noopener" class="text-blue-500 underline break-all">
                          เปิดไฟล์
                        </a>
                      </template>
                    </div>
                    <span v-else>{{ msg.text || "📎 ไฟล์แนบ" }}</span>
                  </template>
                  <!-- LOCATION -->
                  <template v-else-if="msg.messageType === 'LOCATION' && msg.location">
                    <div class="location-card rounded-xl overflow-hidden border border-gray-200 shadow-sm">
                      <div class="map-embed w-full h-40">
                        <iframe
                          width="100%"
                          height="100%"
                          frameborder="0"
                          style="border:0"
                          loading="lazy"
                          referrerpolicy="no-referrer-when-downgrade"
                          :src="`https://maps.google.com/maps?q=${msg.location.lat},${msg.location.lng}&z=15&output=embed`"
                          allowfullscreen
                        />
                      </div>
                      <div class="px-3 py-2 bg-gray-50 text-sm">
                        <p v-if="msg.location.address" class="text-gray-700 line-clamp-2 mb-1">
                          {{ msg.location.address }}
                        </p>
                        <a :href="`https://maps.google.com/?q=${msg.location.lat},${msg.location.lng}`"
                          target="_blank" rel="noopener"
                          class="inline-flex items-center gap-1 text-blue-600 hover:underline text-xs font-medium">
                          <span>เปิดใน Google Maps</span>
                          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                          </svg>
                        </a>
                      </div>
                    </div>
                  </template>
                  <template v-else>
                    {{ msg.text }}
                  </template>
                </div>
                <span class="text-[10px] text-gray-400 mt-1 block"
                  :class="msg.sender === 'user' ? 'text-right mr-1' : 'ml-1'">
                  {{ msg.time }}
                </span>
              </div>
            </div>
          </div>

          <!-- Typing Indicator -->
          <div v-if="isTyping" class="flex items-start gap-3">
            <img :src="activeChat?.avatar ||
              'https://ui-avatars.com/api/?name=Admin&background=EBF4FF&color=2563EB'
              " class="w-8 h-8 rounded-full shadow-sm mb-1" />
            <div class="px-4 py-3 bg-white rounded-2xl rounded-bl-sm shadow-sm border border-gray-100">
              <div class="flex space-x-1.5 items-center h-full">
                <div class="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0ms"></div>
                <div class="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 150ms"></div>
                <div class="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 300ms"></div>
              </div>
            </div>
          </div>
        </div>

        <div v-if="isChatClosed" class="px-6 py-3 bg-yellow-50 border-t border-yellow-200 text-center">
          <p class="text-sm text-yellow-800">
            <span class="font-medium">⚠️ การสนทนานี้ถูกปิดแล้ว</span>
            - ไม่สามารถส่งข้อความได้
          </p>
        </div>


        <!-- Input Area -->
        <template v-if="!isChatClosed">
          <div class="p-4 md:p-6 bg-white border-t border-gray-200">
            <form @submit.prevent="sendMessage" class="flex items-end gap-3 max-w-5xl mx-auto">
              <!-- Tools Button (Left Side) -->
              <div class="flex items-center space-x-1 mb-2">
                <button type="button" @click="openFilePicker" :disabled="uploadLoading"
                  class="p-2 text-gray-400 hover:text-blue-600 rounded-full hover:bg-blue-50 transition-colors"
                  :class="{ 'opacity-50 cursor-not-allowed': uploadLoading }" title="แนบไฟล์">
                  <!-- Loading spinner -->
                  <svg v-if="uploadLoading" class="w-6 h-6 animate-spin" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                    </path>
                  </svg>

                  <!-- แนบไฟล์ icon -->
                  <svg v-else class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13" />
                  </svg>
                </button>
                <button type="button" @click="sendLocation"
                  :disabled="!activeChatId || sendMessageLoading || sendLocationLoading || isChatClosed"
                  class="p-2 text-gray-400 hover:text-blue-600 rounded-full hover:bg-blue-50 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                  title="ส่งตำแหน่ง">
                  <svg v-if="sendLocationLoading" class="w-6 h-6 animate-spin" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                    </path>
                  </svg>
                  <svg v-else class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                </button>
                <button type="button"
                  class="p-2 text-gray-400 hover:text-blue-600 rounded-full hover:bg-blue-50 transition-colors md:hidden"
                  title="Emoji">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </button>
              </div>

              <div
                class="flex-1 relative bg-gray-50 rounded-2xl border border-gray-200 focus-within:ring-2 focus-within:ring-blue-500/20 focus-within:border-blue-500 transition-all">
                <textarea v-model="newMessage" :disabled="isChatClosed || sendMessageLoading"
                  :placeholder="isChatClosed ? 'การสนทนานี้ปิดแล้ว' : 'Write a message...'"
                  class="w-full pl-4 pr-12 py-3.5 bg-transparent border-none focus:ring-0 text-gray-700 resize-none max-h-32 min-h-[48px]"
                  @keydown.enter.exact.prevent="sendMessage" @input="handleTyping" style="line-height: 1.5"></textarea>

                <!-- Emoji inside input (Desktop only) -->
                <div class="hidden md:flex absolute right-2 bottom-2 items-center">
                  <button type="submit" :disabled="!newMessage.trim() || sendMessageLoading || isChatClosed"
                    class="p-2 text-gray-400 hover:text-gray-600 rounded-full hover:bg-gray-100 transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </button>
                </div>
              </div>

              <button type="submit" :disabled="!newMessage.trim() || sendMessageLoading"
                class="p-3.5 bg-blue-600 text-white rounded-xl shadow-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed transform active:scale-95 transition-all duration-200 flex-shrink-0 mb-2">
                <svg class="w-5 h-5 translate-x-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7" />
                </svg>
              </button>
            </form>
            <input ref="fileInput" type="file" multiple accept="image/*,video/*,.pdf,.doc,.docx" class="hidden"
              @change="handleFileSelect" />
          </div>
        </template>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick, computed, watch } from "vue";
import { useRoute, useRuntimeConfig, useCookie } from "#app";
import { useChat } from "@/composables/useChat";
import { useSocket } from "@/composables/useSocket";
import { useToast } from "@/composables/useToast";

let typingTimeout = null;

const { user } = useAuth();
const isAdmin = computed(() => user.value?.role === 'ADMIN');

const {
  chatRooms,
  messages,
  loading,
  messagesLoading,
  fetchChatRooms,
  fetchMessages,
  closeChatRoom,
  formatDate,
  transformMessageToUI,
  getLastMessagePreview,
  formatRelativeTime,
  uploadFiles,
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

const route = useRoute();
const chatContainer = ref(null);
const newMessage = ref("");
const isTyping = ref(false);
const activeChatId = ref(null);
const isMobile = ref(false);
const sendMessageLoading = ref(false);
const fileInput = ref(null);
const uploadLoading = ref(false);
const closeChatLoading = ref(false);
const { toast } = useToast();
const toastMessage = ref("");
const toastVisible = ref(false);

// ใช้ chatRooms เป็น chatList ใน template
const chatList = computed(() => chatRooms.value);

// การแจ้งเตือนแชท - แสดง badge แดงว่าห้องไหนมีข้อความใหม่
const chatNotifications = ref([]);
const config = useRuntimeConfig();
async function fetchChatNotifications() {
  try {
    const apiBase = config.public?.apiBase || "http://localhost:3000/api";
    const token = useCookie("token")?.value || (process.client ? localStorage.getItem("token") : "");
    const res = await $fetch("/notifications", {
      baseURL: apiBase,
      headers: { Accept: "application/json", ...(token ? { Authorization: `Bearer ${token}` } : {}) },
      query: { page: 1, limit: 50 },
    });
    const raw = Array.isArray(res?.data) ? res.data : [];
    chatNotifications.value = raw.filter((n) => n.metadata?.chatRoomId);
  } catch {
    chatNotifications.value = [];
  }
}

const unreadByRoomId = computed(() => {
  const m = {};
  for (const n of chatNotifications.value) {
    if (!n.readAt && n.metadata?.chatRoomId) {
      const rid = n.metadata.chatRoomId;
      m[rid] = (m[rid] || 0) + 1;
    }
  }
  return m;
});

const totalChatUnread = computed(() =>
  Object.values(unreadByRoomId.value).reduce((a, b) => a + b, 0)
);

function getRoomUnread(chat) {
  return unreadByRoomId.value[chat.id] ?? chat.unread ?? 0;
}

async function markRoomNotificationsRead(roomId) {
  const toMark = chatNotifications.value.filter(
    (n) => !n.readAt && n.metadata?.chatRoomId === roomId
  );
  if (toMark.length === 0) return;
  const apiBase = config.public?.apiBase || "http://localhost:3000/api";
  const token = useCookie("token")?.value || (process.client ? localStorage.getItem("token") : "");
  for (const n of toMark) {
    try {
      await $fetch(`/notifications/${n.id}/read`, {
        baseURL: apiBase,
        method: "PATCH",
        headers: { Accept: "application/json", ...(token ? { Authorization: `Bearer ${token}` } : {}) },
      });
      n.readAt = new Date().toISOString();
    } catch { /* ignore */ }
  }
}

//toast
const showToast = (message, duration = 3000) => {
  toastMessage.value = message;
  toastVisible.value = true;
  setTimeout(() => {
    toastVisible.value = false;
  }, duration);
};

const activeChat = computed(() =>
  chatList.value.find((c) => c.id === activeChatId.value),
);

const displayDate = computed(() => {
  const first = messages.value[0];
  return first?.createdAt ? formatDate(first.createdAt) : "";
});

// 6.5 - Socket Connection Status
const socketStatus = computed(() => {
  return connected.value ? 'เชื่อมต่อแล้ว' : 'ไม่ได้เชื่อมต่อ';
});

const isChatClosed = computed(() => {
  return activeChat.value?.status === 'CLOSED';
});

const handleCloseChat = async () => {
  if (!activeChatId.value || !isAdmin.value) return;
  if (!confirm('ต้องการปิดการสนทนานี้หรือไม่? หลังปิดแล้วจะไม่สามารถส่งข้อความได้')) return;

  closeChatLoading.value = true;
  try {
    await closeChatRoom(activeChatId.value);
    const room = chatRooms.value.find((c) => c.id === activeChatId.value);
    if (room) room.status = 'CLOSED';
    showToast('ปิดการสนทนาแล้ว');
  } catch (err) {
    console.error('Close chat error:', err);
    showToast(err?.data?.message || err?.statusMessage || 'ปิดการสนทนาไม่สำเร็จ');
  } finally {
    closeChatLoading.value = false;
  }
};

const scrollToBottom = () => {
  nextTick(() => {
    if (chatContainer.value) {
      chatContainer.value.scrollTop = chatContainer.value.scrollHeight;
    }
  });
};

// 6.6 - Retry Mechanism
const retryFetchMessages = async (roomId, maxRetries = 3) => {
  let retries = 0;
  
  while (retries < maxRetries) {
    try {
      await fetchMessages(roomId);
      return; // สำเร็จ
    } catch (err) {
      retries++;
      console.error(`Retry ${retries}/${maxRetries} failed:`, err);
      
      if (retries >= maxRetries) {
        showToast('โหลดข้อความไม่สำเร็จหลังพยายาม 3 ครั้ง');
        throw err;
      }
      // รอ 1 วินาทีก่อนลองใหม่
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }
};

const selectChat = async (chat) => {
  activeChatId.value = chat.id;
  chat.unread = 0;
  await markRoomNotificationsRead(chat.id);

  try {
    // ใช้ retry mechanism
    await retryFetchMessages(chat.id);
    scrollToBottom();

    // Join socket room
    if (connected.value) {
      joinChat(chat.id);
    }
  } catch (err) {
    console.error("Failed to load messages:", err);
    // Toast แสดงแล้วใน retryFetchMessages
  }
};

//อนิทเมชั่นการพิมพ์
const handleTyping = () => {
  if (!activeChatId.value) return;

  emitTyping(activeChatId.value);

  //Clear timeout
  if (typingTimeout) clearTimeout(typingTimeout);

  typingTimeout = setTimeout(() => { }, 3000);
};

const sendMessage = () => {
  if (!newMessage.value.trim() || !activeChatId.value) return;
  if (sendMessageLoading.value) return; //ไม่ให้กดซ้ำ

  const messageText = newMessage.value;
  newMessage.value = ""; //clear อินพุ้ต
  sendMessageLoading.value = true;

  try {
    socketSendMessage({
      chatRoomId: activeChatId.value,
      messageType: 'TEXT',
      content: messageText,
    });
  } catch (err) {
    console.error('Send message error:', err)
    showToast('ส่งข้อความไม่สำเร็จ')
    newMessage.value = messageText // คืนข้อความกลับ
  } finally {
    sendMessageLoading.value = false;
    scrollToBottom();
  }
};

const checkMobile = () => {
  isMobile.value = window.innerWidth < 768;
};

const isImageUrl = (url) => {
  if (!url || typeof url !== "string") return false;
  return (
    /\.(jpg|jpeg|png|gif|webp)(\?|$)/i.test(url) ||
    (url.includes("cloudinary") && !url.includes("/video/")) ||
    url.includes("image")
  );
};

const isVideoUrl = (url) => {
  if (!url || typeof url !== "string") return false;
  return (
    /\.(mp4|webm|ogg|mov|avi|m4v)(\?|$)/i.test(url) ||
    (url.includes("cloudinary") && url.includes("/video/"))
  );
};

const sendLocationLoading = ref(false);

const sendLocation = () => {
  if (!activeChatId.value || sendLocationLoading.value || isChatClosed.value) return;
  if (!navigator.geolocation) {
    showToast('เบราว์เซอร์ไม่รองรับการส่งตำแหน่ง');
    return;
  }

  sendLocationLoading.value = true;
  navigator.geolocation.getCurrentPosition(
    async (position) => {
      const lat = position.coords.latitude;
      const lng = position.coords.longitude;

      // ดึงชื่อสถานที่จาก OpenStreetMap Nominatim (ฟรี ไม่ต้องใช้ API key)
      let address = null;
      try {
        const res = await fetch(
          `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&accept-language=th`,
          { headers: { 'Accept': 'application/json' } }
        );
        const data = await res.json();
        address = data?.display_name || null;
      } catch {
        // ถ้า reverse geocode ล้มเหลว ก็ส่งแค่ lat/lng ได้
      }

      try {
        socketSendMessage({
          chatRoomId: activeChatId.value,
          messageType: 'LOCATION',
          content: '',
          location: { lat, lng, address },
        });
        showToast('ส่งตำแหน่งสำเร็จ');
        scrollToBottom();
      } catch (err) {
        console.error('Send location error:', err);
        showToast('ส่งตำแหน่งไม่สำเร็จ');
      } finally {
        sendLocationLoading.value = false;
      }
    },
    (error) => {
      sendLocationLoading.value = false;
      if (error.code === 1) {
        showToast('คุณไม่อนุญาตให้เข้าถึงตำแหน่ง กรุณาเปิดสิทธิ์ในเบราว์เซอร์');
      } else if (error.code === 2) {
        showToast('ไม่สามารถระบุตำแหน่งได้ กรุณาลองใหม่');
      } else if (error.code === 3) {
        showToast('การรอตำแหน่งใช้เวลานานเกินไป');
      } else {
        showToast('เกิดข้อผิดพลาดในการส่งตำแหน่ง');
      }
    },
    { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
  );
};

const openFilePicker = () => {
  if (uploadLoading.value) return;
  fileInput.value?.click();
};

const handleFileSelect = async (event) => {
  const files = Array.from(event.target.files || []);
  if (!files.length || !activeChatId.value) return;

  // ตรวจสอบจำนวนไฟล์ (max 5)
  if (files.length > 5) {
    alert("สามารถอัปโหลดได้สูงสุด 5 ไฟล์");
    return;
  }

  uploadLoading.value = true;

  try {
    // Upload ไฟล์ไปยัง server
    const urls = await uploadFiles(activeChatId.value, files);
    if (urls && urls.length > 0) {
      // ส่งข้อความ type FILE ผ่าน socket
      socketSendMessage({
        chatRoomId: activeChatId.value,
        messageType: "FILE",
        content: "", // ไม่มี text
        attachments: urls,
      });

      console.log("Files uploaded and sent:", urls);
    }
  } catch (err) {
    console.error("File upload error:", err);
    alert("อัปโหลดไฟล์ไม่สำเร็จ กรุณาลองใหม่");
  } finally {
    uploadLoading.value = false;
    // Clear input
    if (fileInput.value) fileInput.value.value = "";
  }
};

watch(activeChatId, (newChatId, oldChatId) => {
  if (newChatId && connected.value) {
    joinChat(newChatId);
    console.log("Joined chat room:", newChatId);
  }
});

onMounted(async () => {
  scrollToBottom();
  await fetchChatRooms();
  await fetchChatNotifications();
  checkMobile();
  window.addEventListener("resize", checkMobile);

  // ถ้ามี query ?room= (เช่น จาก Admin กด Chat with Reporter) ให้เปิด chat นั้นโดยอัตโนมัติ
  const roomId = route.query?.room;
  if (roomId && chatList.value.length > 0) {
    const chat = chatList.value.find((c) => c.id === roomId);
    if (chat) {
      await selectChat(chat);
    }
  }

  // รับข้อความจาก Socket
  onNewMessage((message) => {
    console.log("Received new message:", message);

    const uiMessage = transformMessageToUI(message);

    // เพิ่มเข้า messages ถ้าอยู่ใน active chat
    if (message.chatRoomId === activeChatId.value) {
      messages.value.push(uiMessage);
      scrollToBottom();
    } else {
      // ข้อความมาห้องอื่น → refetch notifications เพื่ออัปเดต badge แดง
      fetchChatNotifications();
    }

    // อัปเดต lastMessage ใน sidebar
    const chatIndex = chatList.value.findIndex(
      (c) => c.id === message.chatRoomId,
    );
    if (chatIndex !== -1) {
      chatList.value[chatIndex].lastMessage = getLastMessagePreview({
        content: message.content,
        messageType: message.messageType,
        attachments: message.attachments,
      });
      chatList.value[chatIndex].lastTime = "Now";

      // เลื่อน chat นี้ขึ้นมาด้านบน
      const chat = chatList.value.splice(chatIndex, 1)[0];
      chatList.value.unshift(chat);
    }
  });

  // ฟัง typing indicator
  onTyping((data) => {
    console.log("User typing:", data);
    if (data.chatRoomId === activeChatId.value) {
      isTyping.value = true;
      // ซ่อนหลัง 3 วินาที
      setTimeout(() => {
        isTyping.value = false;
      }, 3000);
    }
  });

  if (activeChatId.value && connected.value) {
    joinChat(activeChatId.value);
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

/* Location Map Card */
.location-card {
  max-width: 320px;
  min-width: 200px;
}
.map-embed {
  min-height: 160px;
  background: #e5e7eb;
}
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
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

.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateX(-50%) translateY(20px);
}
</style>
