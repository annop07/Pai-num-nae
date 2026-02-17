<template>
  <div>
    <AdminHeader />
    <AdminSidebar />

    <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6 min-h-screen">
      <div class="mx-auto max-w-3xl">
        <!-- Back -->
        <div class="mb-6">
          <NuxtLink :to="`/admin/incidents/${route.params.id}`"
            class="inline-flex items-center gap-2 px-3 py-2 border border-gray-300 rounded-md hover:bg-gray-50 text-sm font-medium text-gray-600">
            <i class="fa-solid fa-arrow-left"></i>
            <span>ย้อนกลับ</span>
          </NuxtLink>
        </div>

        <!-- Title -->
        <div class="mb-6">
          <h1 class="text-2xl font-semibold text-gray-800">แก้ไข Incident</h1>
          <p class="text-sm text-gray-500 mt-1">อัปเดตสถานะ ความเร่งด่วน และบันทึกการจัดการ</p>
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

        <!-- Form -->
        <div v-else-if="incident" class="bg-white border border-gray-200 rounded-lg shadow-sm overflow-hidden">
          <!-- Incident Summary (read-only) -->
          <div class="px-6 py-5 bg-gray-50 border-b border-gray-200">
            <div class="flex items-center gap-3 flex-wrap">
              <span :class="['inline-flex items-center px-3 py-1 rounded-full text-xs font-bold uppercase', priorityClass(incident.priority)]">
                {{ incident.priority }}
              </span>
              <h2 class="text-base font-semibold text-gray-800">{{ incident.title }}</h2>
            </div>
            <p class="mt-1 text-xs text-gray-500">
              ID: {{ incident.id }} •
              ประเภท: {{ incident.type?.replace(/_/g, ' ') }} •
              สร้างเมื่อ: {{ formatDate(incident.createdAt) }}
            </p>
          </div>

          <!-- Edit Fields -->
          <div class="px-6 py-5 space-y-5">
            <!-- Status & Priority -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label class="block text-xs font-medium text-gray-600 mb-1">สถานะ</label>
                <select v-model="form.status"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-md text-sm focus:outline-none focus:border-blue-400">
                  <option value="PENDING">PENDING</option>
                  <option value="INVESTIGATING">INVESTIGATING</option>
                  <option value="RESOLVED">RESOLVED</option>
                  <option value="DISMISSED">DISMISSED</option>
                  <option value="ESCALATED">ESCALATED</option>
                </select>
              </div>
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
              <textarea v-model="form.resolution" rows="5"
                placeholder="พิมพ์สรุปผลการจัดการเหตุการณ์..."
                class="w-full px-3 py-2.5 border border-gray-300 rounded-md text-sm resize-none focus:outline-none focus:border-blue-400">
              </textarea>
            </div>

            <!-- Error Message -->
            <div v-if="errorMsg" class="text-sm text-red-600 bg-red-50 border border-red-200 rounded-md px-4 py-3">
              <i class="fa-solid fa-circle-xmark mr-1"></i>{{ errorMsg }}
            </div>

            <!-- Success Message -->
            <div v-if="successMsg" class="text-sm text-green-600 bg-green-50 border border-green-200 rounded-md px-4 py-3">
              <i class="fa-solid fa-circle-check mr-1"></i>{{ successMsg }}
            </div>
          </div>

          <!-- Actions -->
          <div class="px-6 py-4 bg-gray-50 border-t border-gray-200 flex justify-end gap-3">
            <NuxtLink :to="`/admin/incidents/${route.params.id}`"
              class="px-5 py-2.5 border border-gray-300 rounded-md text-sm font-medium text-gray-600 hover:bg-gray-100">
              ยกเลิก
            </NuxtLink>
            <button @click="handleSave" :disabled="isSubmitting"
              class="px-6 py-2.5 bg-blue-600 text-white rounded-md text-sm font-semibold hover:bg-blue-700 disabled:opacity-60 disabled:cursor-not-allowed flex items-center gap-2">
              <i v-if="isSubmitting" class="fa-solid fa-spinner fa-spin"></i>
              {{ isSubmitting ? 'กำลังบันทึก...' : 'บันทึกการเปลี่ยนแปลง' }}
            </button>
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
import { useRoute, useRuntimeConfig, useCookie, navigateTo } from '#app'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'

definePageMeta({ middleware: ['admin-auth'] })
useHead({
  title: 'แก้ไข Incident • Admin',
  link: [{ rel: 'stylesheet', href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css' }]
})

const route = useRoute()
const config = useRuntimeConfig()

const isLoading = ref(true)
const loadError = ref('')
const isSubmitting = ref(false)
const errorMsg = ref('')
const successMsg = ref('')
const incident = ref(null)
const form = ref({ status: '', priority: '', resolution: '' })

/* ---------- Helpers ---------- */
function formatDate(iso) {
  if (!iso) return '—'
  return new Date(iso).toLocaleString('th-TH', {
    year: 'numeric', month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}
function priorityClass(p) {
  if (p === 'URGENT') return 'bg-red-100 text-red-700'
  if (p === 'HIGH') return 'bg-orange-100 text-orange-700'
  if (p === 'NORMAL') return 'bg-blue-100 text-blue-700'
  return 'bg-gray-100 text-gray-600'
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
    try { body = await res.json() } catch { throw new Error('ไม่สามารถอ่านข้อมูลได้') }
    if (!res.ok) throw new Error(body?.message || `เกิดข้อผิดพลาด (${res.status})`)
    incident.value = body?.data || null
    if (!incident.value) throw new Error('ไม่พบข้อมูล incident')
    form.value = {
      status: incident.value.status || 'PENDING',
      priority: incident.value.priority || 'NORMAL',
      resolution: incident.value.resolution || ''
    }
  } catch (err) {
    loadError.value = err?.message || 'ไม่สามารถโหลดข้อมูลได้'
    incident.value = null
  } finally {
    isLoading.value = false
  }
}

/* ---------- Save ---------- */
async function handleSave() {
  isSubmitting.value = true
  errorMsg.value = ''
  successMsg.value = ''
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
        ...(form.value.resolution.trim() ? { resolution: form.value.resolution.trim() } : {})
      })
    })
    let body
    try { body = await res.json() } catch { throw new Error('ไม่สามารถอ่านผลลัพธ์ได้') }
    if (!res.ok) throw new Error(body?.message || `บันทึกไม่สำเร็จ (${res.status})`)
    successMsg.value = 'บันทึกสำเร็จ กำลังนำทางกลับ...'
    setTimeout(() => navigateTo(`/admin/incidents/${id}`), 1200)
  } catch (err) {
    errorMsg.value = err?.message || 'เกิดข้อผิดพลาดในการบันทึก'
  } finally {
    isSubmitting.value = false
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
  const main = document.getElementById('main-content')
  const overlay = document.getElementById('overlay')
  if (!sidebar || !main || !overlay) return
  if (window.innerWidth >= 1024) {
    sidebar.classList.remove('mobile-open')
    overlay.classList.add('hidden')
    main.style.marginLeft = sidebar.classList.contains('collapsed') ? '80px' : '280px'
  } else {
    main.style.marginLeft = '0'
  }
}
onMounted(() => { window.addEventListener('resize', handleResize); handleResize(); fetchIncident() })
onUnmounted(() => { window.removeEventListener('resize', handleResize) })
</script>

<style scoped>
.main-content { transition: margin-left 0.3s ease; }
</style>
