<template>
  <div>
    <AdminHeader />
    <AdminSidebar />

    <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6 min-h-screen">
      <div class="mx-auto max-w-4xl">
        <!-- Back -->
        <div class="mb-6">
          <NuxtLink to="/admin/incidents"
            class="inline-flex items-center gap-2 px-3 py-2 border border-gray-300 rounded-md hover:bg-gray-50 text-sm font-medium text-gray-600">
            <i class="fa-solid fa-arrow-left"></i>
            <span>ย้อนกลับ</span>
          </NuxtLink>
        </div>

        <!-- Title -->
        <div class="mb-6">
          <h1 class="text-2xl font-semibold text-gray-800">สร้าง Incident ใหม่</h1>
          <p class="text-sm text-gray-500 mt-1">บันทึกรายงานเหตุการณ์ใหม่เข้าสู่ระบบ</p>
        </div>

        <!-- Form Card -->
        <div class="bg-white border border-gray-200 rounded-lg shadow-sm overflow-hidden">
          <div class="px-6 py-5 space-y-6">

            <!-- ประเภท & ความเร่งด่วน -->
            <section>
              <h3 class="text-sm font-semibold text-gray-700 mb-3">ประเภทและความเร่งด่วน</h3>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label class="block text-xs font-medium text-gray-600 mb-1">
                    ประเภทเหตุการณ์ <span class="text-red-500">*</span>
                  </label>
                  <select v-model="form.type"
                    class="w-full px-3 py-2.5 border border-gray-300 rounded-md text-sm focus:outline-none focus:border-blue-400">
                    <option value="" disabled>— เลือกประเภท —</option>
                    <option value="SAFETY_CONCERN">SAFETY CONCERN</option>
                    <option value="INAPPROPRIATE_BEHAVIOR">INAPPROPRIATE BEHAVIOR</option>
                    <option value="HARASSMENT">HARASSMENT</option>
                    <option value="ACCIDENT">ACCIDENT</option>
                    <option value="VEHICLE_ISSUE">VEHICLE ISSUE</option>
                    <option value="FRAUD">FRAUD</option>
                    <option value="ROUTE_ISSUE">ROUTE ISSUE</option>
                    <option value="PAYMENT_DISPUTE">PAYMENT DISPUTE</option>
                    <option value="OTHER">OTHER</option>
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
            </section>

            <!-- หัวข้อ & รายละเอียด -->
            <section>
              <h3 class="text-sm font-semibold text-gray-700 mb-3">รายละเอียดเหตุการณ์</h3>
              <div class="space-y-4">
                <div>
                  <label class="block text-xs font-medium text-gray-600 mb-1">
                    หัวข้อ <span class="text-red-500">*</span>
                  </label>
                  <input v-model.trim="form.title" type="text" maxlength="100"
                    placeholder="ระบุหัวข้อสั้นๆ ของเหตุการณ์..."
                    class="w-full px-3 py-2.5 border border-gray-300 rounded-md text-sm focus:outline-none focus:border-blue-400" />
                </div>
                <div>
                  <label class="block text-xs font-medium text-gray-600 mb-1">
                    รายละเอียด <span class="text-red-500">*</span>
                  </label>
                  <textarea v-model.trim="form.description" rows="4"
                    placeholder="อธิบายเหตุการณ์โดยละเอียด..."
                    class="w-full px-3 py-2.5 border border-gray-300 rounded-md text-sm resize-none focus:outline-none focus:border-blue-400">
                  </textarea>
                </div>
              </div>
            </section>

            <!-- ผู้เกี่ยวข้อง -->
            <section>
              <h3 class="text-sm font-semibold text-gray-700 mb-3">ผู้เกี่ยวข้อง (ไม่บังคับ)</h3>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <!-- Reporter search -->
                <div class="relative">
                  <label class="block text-xs font-medium text-gray-600 mb-1">
                    ผู้รายงาน (Reporter)
                  </label>
                  <input v-model="reporterQuery" @input="onSearchReporter" type="text"
                    placeholder="ค้นหาด้วยชื่อหรืออีเมล..."
                    class="w-full px-3 py-2.5 border border-gray-300 rounded-md text-sm focus:outline-none focus:border-blue-400" />
                  <div v-if="showReporterList"
                    class="absolute z-20 w-full mt-1 overflow-auto bg-white border border-gray-200 rounded-md shadow-lg max-h-52">
                    <button v-for="u in reporterResults" :key="u.id" type="button"
                      @click="selectReporter(u)"
                      class="w-full px-3 py-2.5 text-left hover:bg-blue-50 border-b border-gray-50 last:border-0">
                      <div class="text-sm font-medium text-gray-800">{{ u.firstName }} {{ u.lastName }}</div>
                      <div class="text-xs text-gray-500">{{ u.email }} • {{ u.role }}</div>
                    </button>
                    <div v-if="!isSearchingReporter && reporterResults.length === 0"
                      class="px-3 py-2 text-sm text-gray-500">ไม่พบผู้ใช้</div>
                  </div>
                  <p v-if="selectedReporterId" class="mt-1 text-xs text-green-600 truncate">
                    <i class="fa-solid fa-circle-check mr-1"></i>เลือกแล้ว: {{ selectedReporterLabel }}
                  </p>
                </div>

                <!-- Reported User search -->
                <div class="relative">
                  <label class="block text-xs font-medium text-gray-600 mb-1">
                    ผู้ถูกรายงาน (Reported User)
                  </label>
                  <input v-model="reportedQuery" @input="onSearchReported" type="text"
                    placeholder="ค้นหาด้วยชื่อหรืออีเมล..."
                    class="w-full px-3 py-2.5 border border-gray-300 rounded-md text-sm focus:outline-none focus:border-blue-400" />
                  <div v-if="showReportedList"
                    class="absolute z-20 w-full mt-1 overflow-auto bg-white border border-gray-200 rounded-md shadow-lg max-h-52">
                    <button v-for="u in reportedResults" :key="u.id" type="button"
                      @click="selectReported(u)"
                      class="w-full px-3 py-2.5 text-left hover:bg-red-50 border-b border-gray-50 last:border-0">
                      <div class="text-sm font-medium text-gray-800">{{ u.firstName }} {{ u.lastName }}</div>
                      <div class="text-xs text-gray-500">{{ u.email }} • {{ u.role }}</div>
                    </button>
                    <div v-if="!isSearchingReported && reportedResults.length === 0"
                      class="px-3 py-2 text-sm text-gray-500">ไม่พบผู้ใช้</div>
                  </div>
                  <p v-if="selectedReportedId" class="mt-1 text-xs text-green-600 truncate">
                    <i class="fa-solid fa-circle-check mr-1"></i>เลือกแล้ว: {{ selectedReportedLabel }}
                  </p>
                </div>
              </div>
            </section>

            <!-- URL หลักฐาน -->
            <section>
              <h3 class="text-sm font-semibold text-gray-700 mb-3">ลิงก์หลักฐาน (ไม่บังคับ)</h3>
              <div class="space-y-2">
                <div v-for="(url, idx) in form.evidenceUrls" :key="idx" class="flex gap-2">
                  <input v-model="form.evidenceUrls[idx]" type="url" placeholder="https://..."
                    class="flex-1 px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:border-blue-400" />
                  <button type="button" @click="removeEvidence(idx)"
                    class="px-3 py-2 text-red-500 border border-red-200 rounded-md hover:bg-red-50 text-sm">
                    <i class="fa-solid fa-trash"></i>
                  </button>
                </div>
                <button type="button" @click="addEvidence"
                  class="inline-flex items-center gap-1 text-sm text-blue-600 hover:text-blue-700">
                  <i class="fa-solid fa-plus"></i> เพิ่ม URL หลักฐาน
                </button>
              </div>
            </section>

          </div>

          <!-- Actions -->
          <div class="px-6 py-4 bg-gray-50 border-t border-gray-200 flex justify-end gap-3">
            <NuxtLink to="/admin/incidents"
              class="px-5 py-2.5 border border-gray-300 rounded-md text-sm font-medium text-gray-600 hover:bg-gray-100">
              ยกเลิก
            </NuxtLink>
            <button @click="handleCreate" :disabled="!canSubmit || isSubmitting"
              class="px-6 py-2.5 bg-blue-600 text-white rounded-md text-sm font-semibold hover:bg-blue-700 disabled:opacity-60 disabled:cursor-not-allowed flex items-center gap-2">
              <i v-if="isSubmitting" class="fa-solid fa-spinner fa-spin"></i>
              {{ isSubmitting ? 'กำลังบันทึก...' : 'สร้าง Incident' }}
            </button>
          </div>

          <!-- Error Message -->
          <div v-if="errorMsg" class="mx-6 mb-5 text-sm text-red-600 bg-red-50 border border-red-200 rounded-md px-4 py-3">
            <i class="fa-solid fa-circle-xmark mr-1"></i>{{ errorMsg }}
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
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'
import { useRuntimeConfig, useCookie, navigateTo } from '#app'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'

definePageMeta({ middleware: ['admin-auth'] })
useHead({
  title: 'สร้าง Incident • Admin',
  link: [{ rel: 'stylesheet', href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css' }]
})

const config = useRuntimeConfig()

const isSubmitting = ref(false)
const errorMsg = ref('')

const form = reactive({
  type: '',
  priority: 'NORMAL',
  title: '',
  description: '',
  evidenceUrls: []
})

/* ---------- User Search (Reporter) ---------- */
const reporterQuery = ref('')
const selectedReporterId = ref('')
const selectedReporterLabel = ref('')
const reporterResults = ref([])
const isSearchingReporter = ref(false)
let reporterTimer = null
let lastReporterLabel = ''

const showReporterList = computed(() =>
  reporterQuery.value && reporterQuery.value !== lastReporterLabel &&
  (isSearchingReporter.value || reporterResults.value.length > 0)
)

async function onSearchReporter() {
  if (reporterQuery.value !== lastReporterLabel) {
    selectedReporterId.value = ''
    selectedReporterLabel.value = ''
  }
  clearTimeout(reporterTimer)
  const q = reporterQuery.value.trim()
  if (!q) { reporterResults.value = []; return }
  reporterTimer = setTimeout(async () => {
    try {
      isSearchingReporter.value = true
      const token = useCookie('token')?.value || localStorage.getItem('token') || ''
      const res = await $fetch('/users/admin', {
        baseURL: config.public.apiBase,
        headers: { Accept: 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
        query: { q, page: 1, limit: 10 }
      })
      reporterResults.value = res?.data || []
    } catch { reporterResults.value = [] }
    finally { isSearchingReporter.value = false }
  }, 300)
}

function selectReporter(u) {
  selectedReporterId.value = u.id
  const label = `${u.firstName || ''} ${u.lastName || ''} (${u.email || ''})`
  reporterQuery.value = label
  lastReporterLabel = label
  selectedReporterLabel.value = label
  reporterResults.value = []
}

/* ---------- User Search (Reported) ---------- */
const reportedQuery = ref('')
const selectedReportedId = ref('')
const selectedReportedLabel = ref('')
const reportedResults = ref([])
const isSearchingReported = ref(false)
let reportedTimer = null
let lastReportedLabel = ''

const showReportedList = computed(() =>
  reportedQuery.value && reportedQuery.value !== lastReportedLabel &&
  (isSearchingReported.value || reportedResults.value.length > 0)
)

async function onSearchReported() {
  if (reportedQuery.value !== lastReportedLabel) {
    selectedReportedId.value = ''
    selectedReportedLabel.value = ''
  }
  clearTimeout(reportedTimer)
  const q = reportedQuery.value.trim()
  if (!q) { reportedResults.value = []; return }
  reportedTimer = setTimeout(async () => {
    try {
      isSearchingReported.value = true
      const token = useCookie('token')?.value || localStorage.getItem('token') || ''
      const res = await $fetch('/users/admin', {
        baseURL: config.public.apiBase,
        headers: { Accept: 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
        query: { q, page: 1, limit: 10 }
      })
      reportedResults.value = res?.data || []
    } catch { reportedResults.value = [] }
    finally { isSearchingReported.value = false }
  }, 300)
}

function selectReported(u) {
  selectedReportedId.value = u.id
  const label = `${u.firstName || ''} ${u.lastName || ''} (${u.email || ''})`
  reportedQuery.value = label
  lastReportedLabel = label
  selectedReportedLabel.value = label
  reportedResults.value = []
}

/* ---------- Evidence URLs ---------- */
function addEvidence() { form.evidenceUrls.push('') }
function removeEvidence(idx) { form.evidenceUrls.splice(idx, 1) }

/* ---------- Submit ---------- */
const canSubmit = computed(() =>
  !!form.type && form.title.length > 0 && form.description.length > 0
)

async function handleCreate() {
  if (!canSubmit.value) return
  isSubmitting.value = true
  errorMsg.value = ''
  try {
    const token = useCookie('token')?.value || localStorage.getItem('token') || ''
    const validUrls = form.evidenceUrls.filter(u => u.trim().startsWith('http'))
    const payload = {
      type: form.type,
      priority: form.priority,
      title: form.title,
      description: form.description,
      evidenceUrls: validUrls,
      ...(selectedReportedId.value ? { reportedUserId: selectedReportedId.value } : {})
    }
    await $fetch('/incidents', {
      baseURL: config.public.apiBase,
      method: 'POST',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      },
      body: payload
    })
    await navigateTo('/admin/incidents')
  } catch (err) {
    console.error(err)
    errorMsg.value = err?.data?.message || err?.message || 'ไม่สามารถสร้าง incident ได้'
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
onMounted(() => { window.addEventListener('resize', handleResize); handleResize() })
onUnmounted(() => { window.removeEventListener('resize', handleResize) })
</script>

<style scoped>
.main-content { transition: margin-left 0.3s ease; }
</style>
