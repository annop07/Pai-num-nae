<template>
  <div>
    <AdminHeader />
    <AdminSidebar />

    <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
      <!-- Back -->
      <div class="mb-6">
        <NuxtLink to="/admin/incidents"
          class="inline-flex items-center gap-2 px-3 py-2 border border-gray-300 rounded-md hover:bg-gray-50 text-sm font-medium text-gray-600">
          <i class="fa-solid fa-arrow-left"></i>
          <span>ย้อนกลับ</span>
        </NuxtLink>
      </div>

      <div class="mx-auto max-w-5xl">
        <!-- Title -->
        <div class="flex flex-col gap-2 mb-6 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 class="text-2xl font-semibold text-gray-800">รายละเอียด Incident</h1>
            <p class="text-sm text-gray-500 mt-1">ดูและจัดการรายงานเหตุการณ์</p>
          </div>
        </div>

        <!-- Loading -->
        <div v-if="isLoading" class="bg-white border border-gray-200 rounded-lg p-12 text-center text-gray-500">
          <i class="fa-solid fa-spinner fa-spin text-2xl mb-3"></i>
          <p>กำลังโหลดข้อมูล...</p>
        </div>

        <!-- Error -->
        <div v-else-if="loadError" class="bg-white border border-red-200 rounded-lg p-12 text-center text-red-600">
          <i class="fa-solid fa-circle-exclamation text-2xl mb-3"></i>
          <p>{{ loadError }}</p>
          <button @click="fetchIncident"
            class="mt-4 px-4 py-2 bg-red-50 border border-red-300 rounded-md text-sm text-red-600 hover:bg-red-100">
            ลองใหม่
          </button>
        </div>

        <!-- Content -->
        <div v-else-if="incident" class="space-y-6">

          <!-- Header Card -->
          <div class="bg-white border border-gray-200 rounded-lg shadow-sm overflow-hidden">
            <div class="px-6 py-5 border-b border-gray-100 flex items-center justify-between">
              <div class="flex items-center gap-3">
                <span :class="['inline-flex items-center px-3 py-1 rounded-full text-xs font-bold uppercase', priorityClass(incident.priority)]">
                  {{ incident.priority }}
                </span>
                <h2 class="text-lg font-semibold text-gray-800">{{ incident.title }}</h2>
              </div>
              <span :class="['inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold', statusClass(incident.status)]">
                <i class="mr-1 fa-solid" :class="statusIcon(incident.status)"></i>
                {{ incident.status }}
              </span>
            </div>

            <div class="px-6 py-5 grid grid-cols-1 sm:grid-cols-3 gap-4 text-sm">
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">Incident ID</label>
                <div class="font-mono text-gray-800 text-sm">{{ incident.id }}</div>
              </div>
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">ประเภทเหตุการณ์</label>
                <div class="text-gray-800">{{ formatType(incident.type) }}</div>
              </div>
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">วันที่รายงาน</label>
                <div class="text-gray-800">{{ formatDate(incident.createdAt) }}</div>
              </div>
            </div>
          </div>

          <!-- Description -->
          <div class="bg-white border border-gray-200 rounded-lg shadow-sm">
            <div class="px-6 py-4 border-b border-gray-100">
              <h3 class="font-medium text-gray-700">รายละเอียดเหตุการณ์</h3>
            </div>
            <div class="px-6 py-5">
              <p class="text-gray-700 leading-relaxed bg-gray-50 rounded-lg p-4 border border-gray-100">
                {{ incident.description || '— ไม่มีรายละเอียด —' }}
              </p>
            </div>
          </div>

          <!-- Reporter & Reported User -->
          <div class="bg-white border border-gray-200 rounded-lg shadow-sm">
            <div class="px-6 py-4 border-b border-gray-100">
              <h3 class="font-medium text-gray-700">ผู้เกี่ยวข้อง</h3>
            </div>
            <div class="px-6 py-5 grid grid-cols-1 sm:grid-cols-2 gap-6">
              <!-- Reporter -->
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-2">ผู้รายงาน (Reporter)</label>
                <div class="bg-blue-50 rounded-lg p-4 border border-blue-100">
                  <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-full bg-blue-200 flex items-center justify-center text-blue-700 font-semibold">
                      {{ incident.reporter ? (incident.reporter.firstName?.[0] || '?').toUpperCase() : '?' }}
                    </div>
                    <div>
                      <div class="font-medium text-gray-800">
                        {{ incident.reporter ? `${incident.reporter.firstName || ''} ${incident.reporter.lastName || ''}`.trim() : '—' }}
                      </div>
                      <div class="text-xs text-gray-500">{{ incident.reporter?.email || '—' }}</div>
                      <span class="inline-block text-xs px-2 py-0.5 rounded-full bg-blue-100 text-blue-700 mt-1">
                        {{ incident.reporter?.role || '—' }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
              <!-- Reported User -->
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-2">ผู้ถูกรายงาน (Reported User)</label>
                <div class="bg-red-50 rounded-lg p-4 border border-red-100">
                  <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-full bg-red-200 flex items-center justify-center text-red-700 font-semibold">
                      {{ incident.reportedUser ? (incident.reportedUser.firstName?.[0] || '?').toUpperCase() : '?' }}
                    </div>
                    <div>
                      <div class="font-medium text-gray-800">
                        {{ incident.reportedUser ? `${incident.reportedUser.firstName || ''} ${incident.reportedUser.lastName || ''}`.trim() : '—' }}
                      </div>
                      <div class="text-xs text-gray-500">{{ incident.reportedUser?.email || '—' }}</div>
                      <span v-if="incident.reportedUser?.role"
                        class="inline-block text-xs px-2 py-0.5 rounded-full bg-red-100 text-red-700 mt-1">
                        {{ incident.reportedUser.role }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Evidence Images -->
          <div v-if="incident.evidenceUrls?.length" class="bg-white border border-gray-200 rounded-lg shadow-sm">
            <div class="px-6 py-4 border-b border-gray-100">
              <h3 class="font-medium text-gray-700">หลักฐาน ({{ incident.evidenceUrls.length }} รูป)</h3>
            </div>
            <div class="px-6 py-5">
              <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <a v-for="(url, idx) in incident.evidenceUrls" :key="idx" :href="url" target="_blank"
                  class="block overflow-hidden rounded-lg border border-gray-200 hover:opacity-90 transition">
                  <img :src="url" :alt="`หลักฐาน ${idx + 1}`" class="w-full h-28 object-cover" />
                </a>
              </div>
            </div>
          </div>

          <!-- Location -->
          <div v-if="incident.location" class="bg-white border border-gray-200 rounded-lg shadow-sm">
            <div class="px-6 py-4 border-b border-gray-100">
              <h3 class="font-medium text-gray-700"><i class="fa-solid fa-map-marker-alt mr-1 text-red-500"></i> ตำแหน่งที่เกิดเหตุ</h3>
            </div>
            <div class="px-6 py-5">
              <div class="overflow-hidden rounded-lg border border-gray-200">
                <iframe
                  width="100%" height="280" frameborder="0" loading="lazy"
                  :src="`https://maps.google.com/maps?q=${incident.location.lat},${incident.location.lng}&z=15&output=embed`">
                </iframe>
              </div>
              <p class="mt-2 text-xs text-gray-500">
                พิกัด: {{ incident.location.lat }}, {{ incident.location.lng }}
              </p>
            </div>
          </div>

          <!-- Related Booking/Route -->
          <div v-if="incident.booking || incident.route" class="bg-white border border-gray-200 rounded-lg shadow-sm">
            <div class="px-6 py-4 border-b border-gray-100">
              <h3 class="font-medium text-gray-700">ข้อมูลที่เกี่ยวข้อง</h3>
            </div>
            <div class="px-6 py-5 grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div v-if="incident.booking">
                <label class="block text-xs font-medium text-gray-500 mb-1">Booking ID</label>
                <NuxtLink :to="`/admin/bookings/${incident.booking.id}`"
                  class="inline-flex items-center gap-1 text-blue-600 hover:underline text-sm font-mono">
                  {{ incident.booking.id }}
                  <i class="fa-solid fa-arrow-up-right-from-square text-xs"></i>
                </NuxtLink>
                <div class="text-xs text-gray-500 mt-1">สถานะ: {{ incident.booking.status }} • ที่นั่ง: {{ incident.booking.numberOfSeats }}</div>
              </div>
              <div v-if="incident.route">
                <label class="block text-xs font-medium text-gray-500 mb-1">Route ID</label>
                <div class="font-mono text-sm text-gray-700">{{ incident.route.id }}</div>
                <div class="text-xs text-gray-500 mt-1">
                  {{ formatDate(incident.route.departureTime) }}
                </div>
              </div>
            </div>
          </div>

          <!-- Admin Action Card -->
          <div class="bg-white border border-gray-200 rounded-lg shadow-sm">
            <div class="px-6 py-4 border-b border-gray-100">
              <h3 class="font-medium text-gray-700">จัดการโดย Admin</h3>
            </div>
            <div class="px-6 py-5 space-y-5">
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <!-- Status -->
                <div>
                  <label class="block text-xs font-medium text-gray-600 mb-1">สถานะ</label>
                  <select v-model="form.status"
                    class="w-full px-3 py-2.5 border border-gray-300 rounded-md text-sm focus:outline-none focus:border-blue-400">
                    <option value="PENDING">PENDING</option>
                    <option value="INVESTIGATING">INVESTIGATING</option>
                    <option value="RESOLVED">RESOLVED</option>
                    <option value="DISMISSED">DISMISSED</option>
                  </select>
                </div>
                <!-- Priority -->
                <div>
                  <label class="block text-xs font-medium text-gray-600 mb-1">ระดับความเร่งด่วน</label>
                  <select v-model="form.priority"
                    class="w-full px-3 py-2.5 border border-gray-300 rounded-md text-sm focus:outline-none focus:border-blue-400">
                    <option value="LOW">LOW</option>
                    <option value="NORMAL">NORMAL</option>
                    <option value="HIGH">HIGH</option>
                    <option value="URGENT">URGENT</option>
                  </select>
                </div>
              </div>

              <!-- Resolution Note -->
              <div>
                <label class="block text-xs font-medium text-gray-600 mb-1">หมายเหตุการจัดการ (Resolution Note)</label>
                <textarea v-model="form.resolution" rows="4" placeholder="พิมพ์สรุปผลการจัดการเหตุการณ์..."
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-md text-sm resize-none focus:outline-none focus:border-blue-400">
                </textarea>
              </div>

              <!-- Resolver info -->
              <div v-if="incident.resolver" class="text-xs text-gray-500 bg-gray-50 rounded-md px-3 py-2">
                <i class="fa-solid fa-circle-check text-green-500 mr-1"></i>
                จัดการโดย: {{ incident.resolver.firstName }} {{ incident.resolver.lastName }}
                ({{ incident.resolver.email }})
                {{ incident.resolvedAt ? `• ${formatDate(incident.resolvedAt)}` : '' }}
              </div>

              <!-- Save Button -->
              <div class="flex justify-end gap-3 pt-2">
                <NuxtLink to="/admin/incidents"
                  class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-600 hover:bg-gray-50">
                  ยกเลิก
                </NuxtLink>
                <button @click="saveChanges" :disabled="isSaving"
                  class="px-6 py-2 bg-blue-600 text-white rounded-md text-sm font-medium hover:bg-blue-700 disabled:opacity-60 disabled:cursor-not-allowed flex items-center gap-2">
                  <i v-if="isSaving" class="fa-solid fa-spinner fa-spin"></i>
                  {{ isSaving ? 'กำลังบันทึก...' : 'บันทึกการเปลี่ยนแปลง' }}
                </button>
              </div>

              <!-- Save Result -->
              <div v-if="saveMessage"
                :class="['mt-2 text-sm text-center px-3 py-2 rounded-md', saveSuccess ? 'bg-green-50 text-green-700 border border-green-200' : 'bg-red-50 text-red-700 border border-red-200']">
                <i :class="['fa-solid mr-1', saveSuccess ? 'fa-circle-check' : 'fa-circle-xmark']"></i>
                {{ saveMessage }}
              </div>
            </div>
          </div>

        </div>
      </div>
    </main>

    <!-- Mobile Overlay -->
    <div id="overlay" class="fixed inset-0 z-40 hidden bg-black bg-opacity-50 lg:hidden"
      @click="closeMobileSidebar"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute, useRuntimeConfig, useCookie } from '#app'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'

definePageMeta({ middleware: ['admin-auth'] })
useHead({
  title: 'รายละเอียด Incident • Admin',
  link: [{ rel: 'stylesheet', href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css' }]
})

const route = useRoute()
const config = useRuntimeConfig()

const isLoading = ref(true)
const loadError = ref('')
const incident = ref(null)
const isSaving = ref(false)
const saveMessage = ref('')
const saveSuccess = ref(false)

const form = ref({ status: '', priority: '', resolution: '' })

/* ---------- Helpers ---------- */
function formatDate(iso) {
  if (!iso) return '—'
  return new Date(iso).toLocaleString('th-TH', {
    year: 'numeric', month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}

function formatType(type) {
  if (!type) return '—'
  return type.replace(/_/g, ' ')
}

function priorityClass(p) {
  if (p === 'URGENT') return 'bg-red-100 text-red-700'
  if (p === 'HIGH') return 'bg-orange-100 text-orange-700'
  if (p === 'NORMAL') return 'bg-blue-100 text-blue-700'
  if (p === 'LOW') return 'bg-gray-100 text-gray-600'
  return 'bg-gray-100 text-gray-600'
}

function statusClass(s) {
  if (s === 'PENDING') return 'bg-amber-100 text-amber-700'
  if (s === 'INVESTIGATING') return 'bg-purple-100 text-purple-700'
  if (s === 'RESOLVED') return 'bg-green-100 text-green-700'
  if (s === 'DISMISSED') return 'bg-gray-200 text-gray-600'
  return 'bg-gray-100 text-gray-600'
}

function statusIcon(s) {
  if (s === 'PENDING') return 'fa-clock'
  if (s === 'INVESTIGATING') return 'fa-magnifying-glass'
  if (s === 'RESOLVED') return 'fa-circle-check'
  if (s === 'DISMISSED') return 'fa-circle-xmark'
  return 'fa-circle'
}

/* ---------- Fetch ---------- */
async function fetchIncident() {
  isLoading.value = true
  loadError.value = ''
  try {
    const id = route.params.id
    const apiBase = config.public.apiBase
    const token = useCookie('token')?.value || (process.client ? localStorage.getItem('token') : '')

    const res = await fetch(`${apiBase}/incidents/admin/${id}`, {
      headers: {
        Accept: 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      },
      credentials: 'include'
    })

    let body
    try { body = await res.json() } catch {
      throw new Error('ไม่สามารถอ่านข้อมูลจาก server ได้')
    }

    if (!res.ok) {
      throw new Error(body?.message || `เกิดข้อผิดพลาด (${res.status})`)
    }

    incident.value = body?.data || null
    if (!incident.value) throw new Error('ไม่พบข้อมูล incident')

    form.value = {
      status: incident.value.status || 'PENDING',
      priority: incident.value.priority || 'NORMAL',
      resolution: incident.value.resolution || ''
    }
  } catch (err) {
    console.error(err)
    loadError.value = err?.message || 'ไม่สามารถโหลดข้อมูลได้'
    incident.value = null
  } finally {
    isLoading.value = false
  }
}

/* ---------- Save ---------- */
async function saveChanges() {
  isSaving.value = true
  saveMessage.value = ''
  try {
    const id = route.params.id
    const apiBase = config.public.apiBase
    const token = useCookie('token')?.value || (process.client ? localStorage.getItem('token') : '')

    const res = await fetch(`${apiBase}/incidents/admin/${id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      },
      credentials: 'include',
      body: JSON.stringify({
        status: form.value.status,
        priority: form.value.priority,
        resolution: form.value.resolution || undefined
      })
    })

    let body
    try { body = await res.json() } catch {
      throw new Error('ไม่สามารถอ่านผลลัพธ์จาก server ได้')
    }

    if (!res.ok) {
      throw new Error(body?.message || `บันทึกไม่สำเร็จ (${res.status})`)
    }

    incident.value = body?.data || incident.value
    saveSuccess.value = true
    saveMessage.value = 'บันทึกการเปลี่ยนแปลงสำเร็จ'
  } catch (err) {
    console.error(err)
    saveSuccess.value = false
    saveMessage.value = err?.message || 'เกิดข้อผิดพลาดในการบันทึก'
  } finally {
    isSaving.value = false
    setTimeout(() => { saveMessage.value = '' }, 4000)
  }
}

/* ---------- Layout ---------- */
function closeMobileSidebar() {
  const sidebar = document.getElementById('sidebar')
  const overlay = document.getElementById('overlay')
  if (!sidebar || !overlay) return
  sidebar.classList.remove('mobile-open')
  overlay.classList.add('hidden')
}

function handleResize() {
  const sidebar = document.getElementById('sidebar')
  const mainContent = document.getElementById('main-content')
  const overlay = document.getElementById('overlay')
  if (!sidebar || !mainContent || !overlay) return
  if (window.innerWidth >= 1024) {
    sidebar.classList.remove('mobile-open')
    overlay.classList.add('hidden')
    mainContent.style.marginLeft = sidebar.classList.contains('collapsed') ? '80px' : '280px'
  } else {
    mainContent.style.marginLeft = '0'
  }
}

onMounted(() => {
  window.addEventListener('resize', handleResize)
  handleResize()
  fetchIncident()
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.main-content {
  transition: margin-left 0.3s ease;
}
</style>
