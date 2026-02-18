<template>
  <div class="min-h-screen bg-gray-50">
    <div class="px-4 py-8 mx-auto max-w-5xl sm:px-6 lg:px-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900">ติดตามสถานะแจ้งเหตุการณ์</h1>
        <p class="mt-2 text-gray-600">ดูรายการเหตุการณ์ที่คุณแจ้งหรือถูกแจ้ง และติดตามสถานะได้ที่นี่</p>
      </div>

      <!-- Stats Summary -->
      <div class="grid grid-cols-2 gap-4 mb-6 md:grid-cols-4">
        <div class="p-4 bg-white rounded-xl border border-gray-200 shadow-sm">
          <p class="text-sm font-medium text-gray-500">ทั้งหมด</p>
          <p class="mt-1 text-2xl font-bold text-gray-900">{{ incidents.length }}</p>
        </div>
        <div class="p-4 bg-white rounded-xl border border-amber-200 shadow-sm">
          <p class="text-sm font-medium text-amber-700">รอดำเนินการ</p>
          <p class="mt-1 text-2xl font-bold text-amber-600">{{ pendingCount }}</p>
        </div>
        <div class="p-4 bg-white rounded-xl border border-blue-200 shadow-sm">
          <p class="text-sm font-medium text-blue-700">กำลังตรวจสอบ</p>
          <p class="mt-1 text-2xl font-bold text-blue-600">{{ investigatingCount }}</p>
        </div>
        <div class="p-4 bg-white rounded-xl border border-green-200 shadow-sm">
          <p class="text-sm font-medium text-green-700">แก้ไขแล้ว</p>
          <p class="mt-1 text-2xl font-bold text-green-600">{{ resolvedCount }}</p>
        </div>
      </div>

      <!-- Filter -->
      <div class="p-4 mb-6 bg-white rounded-xl border border-gray-200 shadow-sm">
        <div class="flex flex-wrap gap-3">
          <select v-model="filterStatus"
            class="px-4 py-2 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <option value="">ทุกสถานะ</option>
            <option value="PENDING">รอดำเนินการ</option>
            <option value="INVESTIGATING">กำลังตรวจสอบ</option>
            <option value="RESOLVED">แก้ไขแล้ว</option>
            <option value="DISMISSED">ยกเลิก</option>
            <option value="ESCALATED">ส่งต่อ</option>
          </select>
          <button @click="filterStatus = ''"
            class="px-4 py-2 text-sm font-medium text-gray-600 bg-gray-100 rounded-xl hover:bg-gray-200">
            ล้างตัวกรอง
          </button>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="isLoading" class="flex flex-col items-center justify-center py-16">
        <div class="w-10 h-10 border-2 border-blue-600 border-t-transparent rounded-full animate-spin" />
        <p class="mt-4 text-gray-500">กำลังโหลดข้อมูล...</p>
      </div>

      <!-- Empty State -->
      <div v-else-if="filteredIncidents.length === 0" class="py-16 text-center bg-white rounded-xl border border-gray-200">
        <div class="w-16 h-16 mx-auto mb-4 rounded-full bg-gray-100 flex items-center justify-center">
          <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
        </div>
        <p class="text-gray-600 font-medium">ไม่พบรายการเหตุการณ์</p>
        <p class="mt-1 text-sm text-gray-400">เมื่อคุณแจ้งเหตุการณ์จากหน้าการเดินทาง รายการจะปรากฏที่นี่</p>
      </div>

      <!-- Incident List -->
      <div v-else class="space-y-4">
        <div v-for="incident in filteredIncidents" :key="incident.id"
          class="p-6 bg-white rounded-xl border border-gray-200 shadow-sm hover:shadow-md transition cursor-pointer"
          @click="openDetail(incident)">
          <div class="flex items-start justify-between gap-4">
            <div class="flex-1 min-w-0">
              <div class="flex flex-wrap items-center gap-2 mb-2">
                <span :class="['px-2.5 py-1 rounded-lg text-xs font-medium', getPriorityClass(incident.priority)]">
                  {{ getPriorityLabel(incident.priority) }}
                </span>
                <span :class="['px-2.5 py-1 rounded-lg text-xs font-medium', getStatusClass(incident.status)]">
                  {{ getStatusLabel(incident.status) }}
                </span>
                <span class="text-xs text-gray-400">{{ formatDate(incident.createdAt) }}</span>
              </div>
              <h3 class="text-lg font-semibold text-gray-900 truncate">{{ incident.title }}</h3>
              <p class="mt-1 text-sm text-gray-600 line-clamp-2">{{ incident.description }}</p>
              <p class="mt-2 text-xs text-gray-500">{{ getTypeLabel(incident.type) }}</p>
              <p v-if="isReporter(incident)" class="mt-1 text-xs text-blue-600">คุณเป็นผู้แจ้ง</p>
              <p v-else class="mt-1 text-xs text-amber-600">คุณเป็นผู้ถูกแจ้ง</p>
            </div>
            <button v-if="incident.chatRoom?.id" @click.stop="goToChat(incident)"
              class="flex-shrink-0 inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition">
              <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
              </svg>
              แชทกับ Admin
            </button>
          </div>
        </div>
      </div>

      <!-- Detail Modal -->
      <Transition name="modal">
        <div v-if="selectedIncident" class="fixed inset-0 z-50 overflow-y-auto" aria-modal="true">
          <div class="flex min-h-screen items-center justify-center p-4">
            <div class="fixed inset-0 bg-black/40 transition-opacity" @click="closeDetail" />
            <div class="relative w-full max-w-2xl bg-white rounded-2xl shadow-xl">
              <div class="p-6 border-b border-gray-200">
                <div class="flex items-start justify-between">
                  <div>
                    <div class="flex flex-wrap gap-2 mb-2">
                      <span :class="['px-2.5 py-1 rounded-lg text-xs font-medium', getPriorityClass(selectedIncident.priority)]">
                        {{ getPriorityLabel(selectedIncident.priority) }}
                      </span>
                      <span :class="['px-2.5 py-1 rounded-lg text-xs font-medium', getStatusClass(selectedIncident.status)]">
                        {{ getStatusLabel(selectedIncident.status) }}
                      </span>
                    </div>
                    <h2 class="text-xl font-bold text-gray-900">{{ selectedIncident.title }}</h2>
                    <p class="mt-1 text-sm text-gray-500">{{ formatDate(selectedIncident.createdAt) }}</p>
                  </div>
                  <button @click="closeDetail"
                    class="p-2 text-gray-400 rounded-lg hover:bg-gray-100 hover:text-gray-600">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                </div>
              </div>
              <div class="p-6 space-y-4 max-h-[60vh] overflow-y-auto">
                <div>
                  <label class="block text-sm font-medium text-gray-700">รายละเอียด</label>
                  <p class="mt-1 text-gray-600 whitespace-pre-wrap">{{ selectedIncident.description }}</p>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700">ประเภท</label>
                  <p class="mt-1 text-gray-600">{{ getTypeLabel(selectedIncident.type) }}</p>
                </div>
                <div v-if="selectedIncident.resolution">
                  <label class="block text-sm font-medium text-gray-700">หมายเหตุจาก Admin</label>
                  <p class="mt-1 text-gray-600 whitespace-pre-wrap">{{ selectedIncident.resolution }}</p>
                </div>
                <div v-if="selectedIncident.evidenceUrls?.length">
                  <label class="block text-sm font-medium text-gray-700">หลักฐาน</label>
                  <div class="grid grid-cols-2 gap-3 mt-2 md:grid-cols-3">
                    <a v-for="(url, idx) in selectedIncident.evidenceUrls" :key="idx" :href="url" target="_blank"
                      class="block overflow-hidden rounded-lg border border-gray-200">
                      <img :src="url" :alt="`หลักฐาน ${idx + 1}`"
                        class="object-cover w-full h-24 transition hover:opacity-90" />
                    </a>
                  </div>
                </div>
                <div v-if="selectedIncident.location" class="mt-4">
                  <label class="block text-sm font-medium text-gray-700">ตำแหน่งที่เกิดเหตุ</label>
                  <div class="mt-2 overflow-hidden rounded-lg border border-gray-200">
                    <iframe width="100%" height="180" frameborder="0" loading="lazy"
                      :src="`https://maps.google.com/maps?q=${selectedIncident.location.lat},${selectedIncident.location.lng}&z=15&output=embed`" />
                  </div>
                </div>
              </div>
              <div class="flex justify-end gap-3 p-6 border-t border-gray-200">
                <button @click="closeDetail"
                  class="px-5 py-2.5 font-medium text-gray-700 bg-gray-100 rounded-xl hover:bg-gray-200">
                  ปิด
                </button>
                <button v-if="selectedIncident.chatRoom?.id" @click="goToChatFromModal"
                  class="inline-flex items-center px-5 py-2.5 font-medium text-white bg-blue-600 rounded-xl hover:bg-blue-700">
                  <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                  </svg>
                  แชทกับ Admin
                </button>
              </div>
            </div>
          </div>
        </div>
      </Transition>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { navigateTo } from '#app'

const { $api } = useNuxtApp()
const { user } = useAuth()

definePageMeta({
  middleware: ['auth']
})

const incidents = ref([])
const isLoading = ref(false)
const filterStatus = ref('')
const selectedIncident = ref(null)

const pendingCount = computed(() => incidents.value.filter(i => i.status === 'PENDING').length)
const investigatingCount = computed(() => incidents.value.filter(i => i.status === 'INVESTIGATING').length)
const resolvedCount = computed(() =>
  incidents.value.filter(i => ['RESOLVED', 'DISMISSED'].includes(i.status)).length
)

const filteredIncidents = computed(() => {
  if (!filterStatus.value) return incidents.value
  return incidents.value.filter(i => i.status === filterStatus.value)
})

const TYPE_LABELS = {
  SAFETY_CONCERN: 'ปัญหาความปลอดภัย',
  INAPPROPRIATE_BEHAVIOR: 'พฤติกรรมไม่เหมาะสม',
  HARASSMENT: 'การล่วงละเมิด',
  ACCIDENT: 'อุบัติเหตุ',
  VEHICLE_ISSUE: 'ปัญหารถยนต์',
  FRAUD: 'การฉ้อโกง',
  ROUTE_ISSUE: 'ปัญหาเส้นทาง',
  PAYMENT_DISPUTE: 'ข้อพิพาทการชำระเงิน',
  OTHER: 'อื่นๆ'
}

const STATUS_LABELS = {
  PENDING: 'รอดำเนินการ',
  INVESTIGATING: 'กำลังตรวจสอบ',
  RESOLVED: 'แก้ไขแล้ว',
  DISMISSED: 'ยกเลิก',
  ESCALATED: 'ส่งต่อ'
}

const PRIORITY_LABELS = {
  LOW: 'ไม่เร่งด่วน',
  NORMAL: 'ปกติ',
  HIGH: 'เร่งด่วน',
  URGENT: 'เร่งด่วนมาก'
}

function getTypeLabel(type) {
  return TYPE_LABELS[type] || type
}

function getStatusLabel(status) {
  return STATUS_LABELS[status] || status
}

function getPriorityLabel(priority) {
  return PRIORITY_LABELS[priority] || priority
}

function getStatusClass(status) {
  const map = {
    PENDING: 'bg-amber-100 text-amber-800',
    INVESTIGATING: 'bg-blue-100 text-blue-800',
    RESOLVED: 'bg-green-100 text-green-800',
    DISMISSED: 'bg-gray-100 text-gray-800',
    ESCALATED: 'bg-purple-100 text-purple-800'
  }
  return map[status] || 'bg-gray-100 text-gray-800'
}

function getPriorityClass(priority) {
  const map = {
    LOW: 'bg-gray-100 text-gray-700',
    NORMAL: 'bg-blue-50 text-blue-700',
    HIGH: 'bg-orange-100 text-orange-800',
    URGENT: 'bg-red-100 text-red-800'
  }
  return map[priority] || 'bg-gray-100 text-gray-700'
}

function formatDate(dateStr) {
  if (!dateStr) return '-'
  const d = new Date(dateStr)
  return d.toLocaleDateString('th-TH', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function isReporter(incident) {
  return user.value?.id === incident.reporterId
}

async function fetchIncidents() {
  isLoading.value = true
  try {
    incidents.value = await $api('/incidents/me')
  } catch (err) {
    console.error('Fetch incidents error:', err)
    incidents.value = []
  } finally {
    isLoading.value = false
  }
}

function openDetail(incident) {
  selectedIncident.value = { ...incident }
}

function closeDetail() {
  selectedIncident.value = null
}

function goToChat(incident) {
  const chatRoomId = incident?.chatRoom?.id
  if (chatRoomId) navigateTo(`/chat?room=${chatRoomId}`)
}

function goToChatFromModal() {
  const chatRoomId = selectedIncident.value?.chatRoom?.id
  if (chatRoomId) {
    closeDetail()
    navigateTo(`/chat?room=${chatRoomId}`)
  }
}

onMounted(() => {
  fetchIncidents()
})
</script>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.2s ease;
}
.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}
</style>
