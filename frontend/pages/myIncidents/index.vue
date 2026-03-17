<template>
  <div class="min-h-screen bg-gray-50">
    <div class="px-4 py-8 mx-auto max-w-5xl sm:px-6 lg:px-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900">ติดตามสถานะแจ้งเหตุการณ์</h1>
        <p class="mt-2 text-gray-600">ดูรายการเหตุการณ์ที่คุณแจ้งหรือถูกแจ้ง และติดตามสถานะได้ที่นี่</p>
      </div>

      <!-- Tabs -->
      <div class="mb-6 border-b border-gray-200">
        <nav class="-mb-px flex space-x-8" aria-label="Tabs">
          <button @click="activeTab = 'reported'"
            :class="[
              activeTab === 'reported'
                ? 'border-blue-500 text-blue-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300',
              'whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm transition-colors'
            ]">
            เคสที่ฉันแจ้ง
            <span :class="[
              activeTab === 'reported' ? 'bg-blue-100 text-blue-600' : 'bg-gray-100 text-gray-900',
              'ml-2 py-0.5 px-2.5 rounded-full text-xs font-medium inline-block'
            ]">{{ reportedIncidents.length }}</span>
          </button>

          <button @click="activeTab = 'against'"
            :class="[
              activeTab === 'against'
                ? 'border-amber-500 text-amber-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300',
              'whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm transition-colors'
            ]">
            เคสที่ฉันถูกแจ้ง
            <span :class="[
              activeTab === 'against' ? 'bg-amber-100 text-amber-600' : 'bg-gray-100 text-gray-900',
              'ml-2 py-0.5 px-2.5 rounded-full text-xs font-medium inline-block'
            ]">{{ againstIncidents.length }}</span>
          </button>
        </nav>
      </div>

      <!-- Stats Summary -->
      <div class="grid grid-cols-2 gap-4 mb-6 md:grid-cols-4">
        <div class="p-4 bg-white rounded-xl border border-gray-200 shadow-sm">
          <p class="text-sm font-medium text-gray-500">ทั้งหมดในหมวดนี้</p>
          <p class="mt-1 text-2xl font-bold text-gray-900">{{ currentTabIncidents.length }}</p>
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
      <div v-else-if="filteredIncidents.length === 0"
        class="py-16 text-center bg-white rounded-xl border border-gray-200">
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
                <span v-if="incident.revisionNumber > 1"
                  class="px-2 py-0.5 rounded text-xs font-medium bg-orange-100 text-orange-700">
                  ครั้งที่ {{ incident.revisionNumber }}
                </span>
              </div>
              <h3 class="text-lg font-semibold text-gray-900 truncate">{{ incident.title }}</h3>
              <p class="mt-1 text-sm text-gray-600 line-clamp-2">{{ incident.description }}</p>
              <p class="mt-2 text-xs text-gray-500">{{ getTypeLabel(incident.type) }}</p>
              <p v-if="activeTab === 'reported'" class="mt-1 text-xs text-blue-600">คุณเป็นผู้แจ้ง</p>
              <p v-else class="mt-1 text-xs text-amber-600">คุณเป็นผู้ถูกแจ้ง</p>
            </div>
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
                      <span
                        :class="['px-2.5 py-1 rounded-lg text-xs font-medium', getPriorityClass(selectedIncident.priority)]">
                        {{ getPriorityLabel(selectedIncident.priority) }}
                      </span>
                      <span
                        :class="['px-2.5 py-1 rounded-lg text-xs font-medium', getStatusClass(selectedIncident.status)]">
                        {{ getStatusLabel(selectedIncident.status) }}
                      </span>
                    </div>
                    <h2 class="text-xl font-bold text-gray-900">{{ selectedIncident.title }}</h2>
                    <p v-if="selectedIncident.revisionNumber > 1"
                      class="mt-1 text-xs text-orange-600 font-medium">
                      เคสนี้เปิดใหม่ครั้งที่ {{ selectedIncident.revisionNumber }}
                      (จากเคสเดิมที่ได้รับการแก้ไขแล้ว)
                    </p>
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
                  <p v-if="selectedIncident.evidenceUrls.some(u => isPdf(u))" class="text-xs text-amber-600 mt-1">
                    ถ้า PDF เปิดหรือโหลดไม่ได้: เปิด &quot;Allow delivery of PDF and ZIP files&quot; ใน Cloudinary → Settings → Security
                  </p>
                  <div class="grid grid-cols-2 gap-3 mt-2 md:grid-cols-3">
                    <template v-for="(url, idx) in selectedIncident.evidenceUrls" :key="idx">

                      <!-- PDF -->
                      <div v-if="isPdf(url)"
                        class="flex flex-col items-center justify-center rounded-lg border border-red-200 bg-red-50 h-24 p-2 gap-1">
                        <span class="text-2xl">📄</span>
                        <span class="text-xs text-red-600 font-medium text-center truncate w-full px-1">{{ getFilename(url) }}</span>
                        <div class="flex gap-1 mt-1">
                          <a :href="fixPdfUrl(url)" target="_blank"
                            class="text-xs px-2 py-0.5 rounded bg-red-500 text-white hover:bg-red-600 transition">
                            เปิด
                          </a>
                          <button @click.stop="downloadFile(pdfDownloadUrl(url), getFilename(url))"
                            class="text-xs px-2 py-0.5 rounded bg-white border border-red-400 text-red-600 hover:bg-red-50 transition">
                            ดาวน์โหลด
                          </button>
                        </div>
                      </div>

                      <!-- Video -->
                      <div v-else-if="isVideo(url)"
                        class="relative rounded-lg border border-gray-200 overflow-hidden h-24">
                        <video :src="url" class="w-full h-full object-cover" preload="metadata"></video>
                        <a :href="url" target="_blank"
                          class="absolute inset-0 flex items-center justify-center bg-black/30 hover:bg-black/40 transition">
                          <span class="text-white text-2xl">▶️</span>
                        </a>
                      </div>

                      <!-- Image -->
                      <button v-else
                        class="block overflow-hidden rounded-lg border border-gray-200 h-24 w-full"
                        @click.stop="openLightbox(url)">
                        <img :src="url" :alt="`หลักฐาน ${idx + 1}`"
                          class="object-cover w-full h-full transition hover:opacity-90" />
                      </button>

                    </template>
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
              
              <!-- Status Timeline -->
              <div class="mt-4 pl-4">
                <label class="block text-sm font-medium text-gray-700 mb-3">ประวัติสถานะ</label>

                <div v-if="logsLoading" class="text-sm text-gray-400">กำลังโหลด...</div>

                <div v-else-if="statusLogs.length === 0" class="text-sm text-gray-400">
                  ยังไม่มีการเปลี่ยนแปลงสถานะ
                </div>

                <ol v-else class="relative border-l border-gray-200 ml-2">
                  <li v-for="log in statusLogs" :key="log.id" class="mb-6 ml-4">
                    <div class="absolute w-3 h-3 bg-blue-500 rounded-full -left-1.5 border border-white mt-1"></div>
                    <time class="text-xs text-gray-400">{{ formatDate(log.createdAt) }}</time>
                    <p class="text-sm font-medium text-gray-900 mt-1">
                      <span v-if="log.fromStatus" class="text-gray-500">{{ log.fromStatus }}</span>
                      <span v-if="log.fromStatus" class="mx-1 text-gray-400">→</span>
                      <span class="text-blue-600">{{ log.toStatus }}</span>
                    </p>
                    <p class="text-xs text-gray-500">เหตุผล: {{ getReasonLabel(log.reason) }}</p>
                    <p class="text-sm text-gray-600 mt-1 bg-gray-50 rounded p-2">{{ log.note }}</p>
                    <p class="text-xs text-gray-400 mt-1">
                      โดย {{ log.changedBy?.firstName }} {{ log.changedBy?.lastName }}
                    </p>
                  </li>
                </ol>
              </div>
              <div class="flex justify-end gap-3 p-6 border-t border-gray-200">
                <button @click="closeDetail"
                  class="px-5 py-2.5 font-medium text-gray-700 bg-gray-100 rounded-xl hover:bg-gray-200">
                  ปิด
                </button>
              </div>
            </div>
          </div>
        </div>
      </Transition>

      <!-- Lightbox -->
      <div v-if="lightboxUrl"
        class="fixed inset-0 z-[60] flex items-center justify-center bg-black/80"
        @click.self="closeLightbox">
        <div class="relative max-w-3xl w-full mx-4">
          <button @click="closeLightbox"
            class="absolute -top-10 right-0 text-white text-2xl hover:text-gray-300">✕</button>
          <img :src="lightboxUrl" class="w-full max-h-[80vh] object-contain rounded-lg" />
          <a :href="lightboxUrl" target="_blank"
            class="absolute bottom-3 right-3 text-xs bg-white/90 px-3 py-1.5 rounded-full text-gray-700 hover:bg-white transition">
            เปิดเต็มหน้า
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
const { $api } = useNuxtApp()
const { user } = useAuth()
const config = useRuntimeConfig()
const token = useCookie('token')

definePageMeta({
  middleware: ['auth']
})

const incidents = ref([])
const isLoading = ref(false)
const filterStatus = ref('')
const selectedIncident = ref(null)
const lightboxUrl = ref('')
function openLightbox(url) { lightboxUrl.value = url }
function closeLightbox() { lightboxUrl.value = '' }
function isPdf(url) {
  const lower = url?.toLowerCase() || ''
  return lower.includes('.pdf') || lower.includes('/raw/upload/')
}
function isVideo(url) {
  return /\.(mp4|mov|webm|ogg|avi)$/i.test(url?.split('?')[0] || '')
}
function getFilename(url) {
  try {
    const name = decodeURIComponent(url.split('?')[0]).split('/').pop() || 'ไฟล์'
    if (isPdf(url) && !name.includes('.')) return name + '.pdf'
    return name
  } catch { return 'ไฟล์' }
}
async function downloadFile(url, filename) {
  const apiBase = (config.public?.apiBase || '').replace(/\/$/, '')
  const proxyUrl = apiBase
    ? `${apiBase}/incidents/evidence-proxy?url=${encodeURIComponent(url)}`
    : null

  try {
    if (proxyUrl && token.value) {
      const res = await fetch(proxyUrl, {
        headers: { Authorization: `Bearer ${token.value}` },
      })
      if (!res.ok) {
        const errBody = await res.json().catch(() => ({}))
        const msg = errBody?.message || errBody?.error?.message || `HTTP ${res.status}`
        if (res.status === 502 && msg.includes('Allow delivery of PDF')) {
          alert('ไม่สามารถดาวน์โหลดได้: Cloudinary ยังไม่อนุญาตให้ส่งไฟล์ PDF\n\nกรุณาเปิด "Allow delivery of PDF and ZIP files" ใน Cloudinary Dashboard → Settings → Security')
          return
        }
        throw new Error(msg)
      }
      const blob = await res.blob()
      const blobUrl = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = blobUrl
      a.download = filename || 'file.pdf'
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(blobUrl)
      return
    }
  } catch (e) {
    if (e?.message && e.message.includes('Allow delivery of PDF')) {
      alert('ไม่สามารถดาวน์โหลดได้: กรุณาเปิด "Allow delivery of PDF and ZIP files" ใน Cloudinary → Settings → Security')
      return
    }
  }

  try {
    const res = await fetch(url, { mode: 'cors' })
    if (!res.ok) throw new Error(`HTTP ${res.status}`)
    const blob = await res.blob()
    if (blob.size < 100 && blob.type?.includes('text/html')) throw new Error('Got HTML')
    const blobUrl = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = blobUrl
    a.download = filename || 'file.pdf'
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(blobUrl)
  } catch {
    window.open(url, '_blank', 'noopener')
  }
}
// คืนค่า URL สำหรับเปิด/ดู PDF
// PDF ใหม่: อัปโหลดเป็น raw → URL มี /raw/upload/ อยู่แล้ว
// PDF เก่า: ถ้าเก็บใน image pipeline (/image/upload/) ให้ใช้ตามนั้น (เปลี่ยนเป็น raw จะ 404)
function fixPdfUrl(url) {
  if (!url || !isPdf(url)) return url
  return url
}
// URL สำหรับดาวน์โหลด - เพิ่ม fl_attachment ให้ Cloudinary ส่ง Content-Disposition: attachment
function pdfDownloadUrl(url) {
  if (!url) return url
  const u = fixPdfUrl(url)
  return u + (u.includes('?') ? '&' : '?') + 'fl_attachment'
}
const statusLogs = ref([])
const logsLoading = ref(false)
const activeTab = ref('reported') // 'reported' or 'against'

function isReporter(incident) {
  return user.value?.id === incident.reporterId
}

const reportedIncidents = computed(() => incidents.value.filter(i => isReporter(i)))
const againstIncidents = computed(() => incidents.value.filter(i => !isReporter(i)))

const currentTabIncidents = computed(() => {
  return activeTab.value === 'reported' ? reportedIncidents.value : againstIncidents.value
})

const pendingCount = computed(() => currentTabIncidents.value.filter(i => i.status === 'PENDING').length)
const investigatingCount = computed(() => currentTabIncidents.value.filter(i => i.status === 'INVESTIGATING').length)
const resolvedCount = computed(() =>
  currentTabIncidents.value.filter(i => ['RESOLVED', 'DISMISSED'].includes(i.status)).length
)

const filteredIncidents = computed(() => {
  let list = currentTabIncidents.value
  if (!filterStatus.value) return list
  return list.filter(i => i.status === filterStatus.value)
})

const TYPE_LABELS = {
  SAFETY_CONCERN:         'ปัญหาความปลอดภัย',
  INAPPROPRIATE_BEHAVIOR: 'พฤติกรรมไม่เหมาะสม',
  HARASSMENT:             'การล่วงละเมิด',
  ACCIDENT:               'อุบัติเหตุ',
  VEHICLE_ISSUE:          'ปัญหารถยนต์',
  FRAUD:                  'การฉ้อโกง',
  ROUTE_ISSUE:            'ปัญหาเส้นทาง',
  PAYMENT_DISPUTE:        'ข้อพิพาทการชำระเงิน',
  LOST_ITEM:              'ลืมของ',
  NO_SHOW_DRIVER:         'คนขับไม่มาตามจุดนัด',
  NO_SHOW_PASSENGER:      'ผู้โดยสารไม่มา',
  LICENSE_PLATE_MISMATCH: 'ป้ายทะเบียนรถไม่ตรง',
  OTHER:                  'อื่นๆ',
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

async function openDetail(incident) {
  selectedIncident.value = { ...incident }
  statusLogs.value = []
  logsLoading.value = true
  try {
    const res = await $api(`/incidents/${incident.id}/logs`)
    statusLogs.value = Array.isArray(res) ? res : (res?.data ?? [])
  } catch (e) {
    statusLogs.value = []
  } finally {
    logsLoading.value = false
  }
}

function closeDetail() {
  selectedIncident.value = null
}

const REASON_LABELS = {
  EVIDENCE_REVIEWED: 'ตรวจสอบหลักฐานแล้ว',
  POLICY_VIOLATION: 'ละเมิดนโยบาย',
  INSUFFICIENT_EVIDENCE: 'หลักฐานไม่เพียงพอ',
  FALSE_REPORT: 'รายงานเท็จ',
  MATTER_RESOLVED: 'แก้ไขปัญหาได้แล้ว',
  REQUIRES_ESCALATION: 'ส่งต่อผู้รับผิดชอบ',
  REOPENED: 'เปิดใหม่',
  OTHER: 'อื่นๆ',
}
function getReasonLabel(reason) {
  return REASON_LABELS[reason] || reason
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
