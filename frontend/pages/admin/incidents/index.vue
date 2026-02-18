<template>
  <div>
    <AdminHeader />
    <AdminSidebar />

    <main :class="[
      'admin-wrapper transition-all duration-300',
      collapsed ? 'ml-20' : 'ml-[280px]'
    ]">


      <header class="page-header">
        <div class="title-group">
          <h1 class="main-title">Incident Management</h1>
          <p class="subtitle">จัดการและติดตามสถานะเหตุการณ์ที่ได้รับแจ้ง</p>
        </div>
        <button class="btn-refresh" @click="fetchData">
          <i class="fas fa-sync-alt"></i> Refresh Data
        </button>
      </header>

      <section class="stats-container">
        <div class="kpi-card">
          <div class="kpi-content">
            <span class="kpi-label">Total Incidents</span>
            <span class="kpi-value">{{ incidents.length }}</span>
          </div>
          <div class="kpi-icon blue"><i class="fas fa-file-invoice"></i></div>
        </div>
        <div class="kpi-card border-amber">
          <div class="kpi-content">
            <span class="kpi-label">Pending</span>
            <span class="kpi-value text-amber">{{ pendingCount }}</span>
          </div>
          <div class="kpi-icon amber"><i class="fas fa-clock"></i></div>
        </div>
        <div class="kpi-card border-red">
          <div class="kpi-content">
            <span class="kpi-label">Urgent</span>
            <span class="kpi-value text-red">{{ urgentCount }}</span>
          </div>
          <div class="kpi-icon red"><i class="fas fa-exclamation-circle"></i></div>
        </div>
      </section>

      <div class="content-card filter-section">
        <div class="input-group">
          <label>Search</label>
          <input 
            v-model="searchQuery" 
            type="text" 
            placeholder="ค้นหา Email, ชื่อผู้รายงาน, รายละเอียด..." 
            class="smooth-select"
          />
        </div>
        <div class="input-group">
          <label>Status</label>
          <select v-model="filterStatus" class="smooth-select">
            <option value="">All Status</option>
            <option>PENDING</option>
            <option>INVESTIGATING</option>
            <option>RESOLVED</option>
          </select>
        </div>
        <div class="input-group">
          <label>Priority</label>
          <select v-model="filterPriority" class="smooth-select">
            <option value="">All Priority</option>
            <option>LOW</option>
            <option>NORMAL</option>
            <option>HIGH</option>
            <option>URGENT</option>
          </select>
        </div>
        <button class="btn-link" @click="filterStatus = ''; filterPriority = ''; searchQuery = ''">Clear Filters</button>
      </div>

      <!-- Loading State -->
      <div v-if="isLoading" class="content-card p-12 text-center text-gray-500">
        <i class="fa-solid fa-spinner fa-spin text-3xl mb-3"></i>
        <p>กำลังโหลดข้อมูล...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="loadError" class="content-card p-12 text-center text-red-600">
        <i class="fa-solid fa-circle-exclamation text-3xl mb-3"></i>
        <p>{{ loadError }}</p>
        <button @click="fetchIncidents" class="mt-4 btn-refresh">ลองใหม่</button>
      </div>

      <!-- Empty State -->
      <div v-else-if="!isLoading && incidents.length === 0" class="content-card p-12 text-center text-gray-500">
        <i class="fa-solid fa-inbox text-4xl mb-3"></i>
        <p>ไม่พบข้อมูลเหตุการณ์</p>
      </div>

      <!-- Table -->
      <div v-else class="content-card table-container">
        <table class="smooth-table">
          <thead>
            <tr>
              <th width="120">Username</th>
              <th>Reporter & Target</th>
              <th width="160">Issue Type</th>
              <th width="110">Priority</th>
              <th width="170">Status</th>
              <th class="text-center" width="200">Action</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="incident in filteredIncidents" :key="incident.id" class="table-row">
              <td class="id-cell">{{ incident.reporter?.username || '—' }}</td>
              <td>
                <div class="user-info">
                  <strong>
                    {{ incident.reporter?.email || '—' }}
                  </strong>
                  <span class="target-text">
                    Target: {{ incident.reportedUser?.email || '—' }}
                  </span>
                </div>
              </td>
              <td><span class="type-tag">{{ incident.type.replace('_', ' ') }}</span></td>
              <td>
                <span :class="['badge', incident.priority.toLowerCase()]">{{ incident.priority }}</span>
              </td>
              <td>
                <select v-model="incident.status" @change="updateStatus(incident)" class="status-pill">
                  <option>PENDING</option>
                  <option>INVESTIGATING</option>
                  <option>RESOLVED</option>
                  <option>DISMISSED</option>
                </select>
              </td>
              <td class="text-center">
                <button class="btn-action" @click="openDetail(incident)">View & Take Action</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="!isLoading && incidents.length > 0" class="content-card p-4">
        <div class="flex items-center justify-between">
          <div class="text-sm text-gray-600">
            แสดง {{ ((currentPage - 1) * pageLimit) + 1 }} - 
            {{ Math.min(currentPage * pageLimit, pagination.total) }} 
            จากทั้งหมด {{ pagination.total }} รายการ
          </div>
          <div class="flex gap-2">
            <button 
              @click="prevPage" 
              :disabled="currentPage === 1"
              class="px-3 py-1.5 border border-gray-300 rounded-md text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50">
              <i class="fa-solid fa-chevron-left"></i> Previous
            </button>
            
            <div class="flex gap-1">
              <button 
                v-for="page in Math.min(pagination.totalPages, 5)" 
                :key="page"
                @click="goToPage(page)"
                :class="[
                  'px-3 py-1.5 border rounded-md text-sm',
                  currentPage === page 
                    ? 'bg-blue-600 text-white border-blue-600' 
                    : 'border-gray-300 hover:bg-gray-50'
                ]">
                {{ page }}
              </button>
            </div>
            
            <button 
              @click="nextPage" 
              :disabled="currentPage === pagination.totalPages"
              class="px-3 py-1.5 border border-gray-300 rounded-md text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50">
              Next <i class="fa-solid fa-chevron-right"></i>
            </button>
          </div>
        </div>
      </div>

      <transition name="modal-fade">
        <div v-if="selectedIncident" class="modal-backdrop" @click.self="closeDetail">
          <div class="modal-sheet">
            <div class="modal-head">
              <div class="head-info">
                <span :class="['mini-badge', selectedIncident.priority.toLowerCase()]">{{ selectedIncident.priority
                  }}</span>
                <h3 class="modal-title">{{ selectedIncident.title }}</h3>
              </div>
              <button class="close-icon" @click="closeDetail">×</button>
            </div>

            <div class="modal-scroll-area">
              <div class="desc-section">
                <label>Description</label>
                <p class="desc-text">{{ selectedIncident.description }}</p>
              </div>

              <div class="evidence-section" v-if="selectedIncident.evidenceUrls?.length">
                <label>Media Evidence</label>
                <div class="gallery-grid">
                  <div v-for="(url, idx) in selectedIncident.evidenceUrls" :key="idx" class="img-wrapper">
                    <a :href="url" target="_blank" rel="noopener noreferrer">
                      <img :src="url" :alt="`หลักฐาน ${idx + 1}`">
                    </a>
                  </div>
                </div>
              </div>

              <div class="map-section" v-if="selectedIncident.location">
                <label><i class="fas fa-map-marker-alt"></i> Location</label>
                <div class="map-box">
                  <iframe width="100%" height="180" frameborder="0" loading="lazy"
                    :src="`https://maps.google.com/maps?q=${selectedIncident.location.lat},${selectedIncident.location.lng}&z=15&output=embed`">
                  </iframe>
                </div>
              </div>

              <div class="note-section">
                <label>Admin Resolution Note</label>
                <textarea v-model="selectedIncident.resolution"
                  placeholder="พิมพ์หมายเหตุการจัดการเหตุการณ์..."></textarea>
              </div>
            </div>

            <div class="modal-foot">
              <button class="btn-chat-alt" @click="startChat(selectedIncident)">
                <i class="far fa-comments"></i> Chat with Reporter
              </button>
              <div class="foot-rights">
                <button class="btn-ghost" @click="closeDetail">Cancel</button>
                <button class="btn-submit" @click="resolveIncident">Confirm Resolved</button>
              </div>
            </div>
          </div>
        </div>
      </transition>
    </main>
  </div>
</template>

<style scoped>
.admin-wrapper {
  padding: 32px;
  background: #f4f7fa;
  min-height: 100vh;
  font-family: 'Kanit', sans-serif;
  color: #334155;

  margin-left: 280px;
  /* ขนาด sidebar */
  margin-top: 70px;
  /* เผื่อ header */
}

/* --- Core Layout & Typography --- */
.admin-wrapper {
  padding: 32px;
  background: #f4f7fa;
  min-height: 100vh;
  font-family: 'Kanit', sans-serif;
  color: #334155;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 30px;
}

.main-title {
  font-size: 26px;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
}

.subtitle {
  color: #64748b;
  font-size: 14px;
  margin-top: 4px;
}

/* --- KPI Cards --- */
.stats-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 24px;
  margin-bottom: 30px;
}

.kpi-card {
  background: white;
  padding: 24px;
  border-radius: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
  border: 1px solid #e2e8f0;
}

.kpi-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.08);
}

.kpi-value {
  font-size: 28px;
  font-weight: 700;
  display: block;
  margin-top: 4px;
}

.kpi-label {
  font-size: 14px;
  color: #64748b;
  font-weight: 500;
}

.kpi-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.kpi-icon.blue {
  background: #eff6ff;
  color: #3b82f6;
}

.kpi-icon.amber {
  background: #fff7ed;
  color: #f59e0b;
}

.kpi-icon.red {
  background: #fef2f2;
  color: #ef4444;
}

.text-amber {
  color: #f59e0b;
}

.text-red {
  color: #ef4444;
}

/* --- Filters & Table --- */
.content-card {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
  margin-bottom: 24px;
  border: 1px solid #e2e8f0;
  overflow: hidden;
}

.filter-section {
  padding: 20px 24px;
  display: flex;
  gap: 20px;
  align-items: flex-end;
  background: #fff;
}

.input-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.input-group label {
  font-size: 13px;
  font-weight: 600;
  color: #64748b;
}

.smooth-select {
  padding: 10px 14px;
  border-radius: 10px;
  border: 1px solid #cbd5e1;
  background: #fff;
  outline: none;
  transition: 0.2s;
  font-size: 14px;
  min-width: 160px;
}

.smooth-select:focus {
  border-color: #3b82f6;
  ring: 2px solid #bfdbfe;
}

.btn-link {
  color: #3b82f6;
  background: none;
  border: none;
  font-weight: 500;
  cursor: pointer;
  padding-bottom: 10px;
}

.smooth-table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
}

.smooth-table th {
  background: #f8fafc;
  padding: 16px 20px;
  text-align: left;
  font-size: 13px;
  font-weight: 600;
  color: #475569;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 1px solid #e2e8f0;
}

.smooth-table td {
  padding: 18px 20px;
  border-bottom: 1px solid #f1f5f9;
  vertical-align: middle;
}

.table-row:hover {
  background-color: #f8fafc;
}

.user-info {
  display: flex;
  flex-direction: column;
}

.target-text {
  font-size: 13px;
  color: #94a3b8;
  margin-top: 2px;
}

.id-cell {
  font-weight: 600;
  color: #3b82f6;
}

.type-tag {
  background: #f1f5f9;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
  color: #475569;
}

/* --- Status & Badges --- */
.status-pill {
  border: none;
  background: #f1f5f9;
  font-weight: 600;
  font-size: 12px;
  cursor: pointer;
  padding: 6px 12px;
  border-radius: 20px;
  text-align: center;
  width: 100%;
  max-width: 160px;
}

.badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.urgent {
  background: #fee2e2;
  color: #b91c1c;
}

.high {
  background: #ffedd5;
  color: #c2410c;
}

.normal {
  background: #e0f2fe;
  color: #0369a1;
}

.mini-badge {
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  margin-right: 8px;
}

/* --- Buttons --- */
.btn-refresh {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: white;
  border: 1px solid #cbd5e1;
  border-radius: 10px;
  color: #475569;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-refresh:hover {
  background: #f8fafc;
  border-color: #94a3b8;
  color: #334155;
}

.btn-action {
  color: #3b82f6;
  background: transparent;
  border: none;
  font-weight: 600;
  cursor: pointer;
  padding: 8px 16px;
  border-radius: 8px;
  transition: 0.2s;
  white-space: nowrap;
}

.btn-action:hover {
  background: #eff6ff;
}

/* --- Modal --- */
.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(15, 23, 42, 0.6);
  backdrop-filter: blur(4px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-sheet {
  background: white;
  width: 600px;
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  display: flex;
  flex-direction: column;
  max-height: 90vh;
}

.modal-head {
  padding: 20px 24px;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fff;
}

.head-info {
  display: flex;
  align-items: center;
}

.modal-title {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  color: #1e293b;
}

.close-icon {
  background: none;
  border: none;
  font-size: 24px;
  color: #94a3b8;
  cursor: pointer;
  padding: 0;
  line-height: 1;
}

.close-icon:hover {
  color: #64748b;
}

.modal-scroll-area {
  padding: 24px;
  overflow-y: auto;
  flex-grow: 1;
}

.desc-section label,
.evidence-section label,
.map-section label,
.note-section label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: #64748b;
  margin-bottom: 8px;
}

.desc-text {
  background: #f8fafc;
  padding: 16px;
  border-radius: 12px;
  line-height: 1.6;
  color: #334155;
  border: 1px solid #e2e8f0;
}

.gallery-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  gap: 12px;
}

.img-wrapper img {
  width: 100%;
  height: 100px;
  object-fit: cover;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  transition: 0.2s;
  cursor: zoom-in;
}

.img-wrapper img:hover {
  filter: brightness(0.9);
  border-color: #cbd5e1;
}

.map-box {
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid #e2e8f0;
}

textarea {
  width: 100%;
  border-radius: 12px;
  border: 1px solid #cbd5e1;
  padding: 12px;
  resize: none;
  font-family: inherit;
  font-size: 14px;
  transition: 0.2s;
}

textarea:focus {
  border-color: #3b82f6;
  outline: none;
}

.modal-foot {
  padding: 20px 24px;
  background: #fff;
  border-top: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.foot-rights {
  display: flex;
  gap: 12px;
}

.btn-submit {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: 0.2s;
}

.btn-submit:hover {
  background: #2563eb;
}

.btn-chat-alt {
  background: #0ea5e9;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: 0.2s;
}

.btn-chat-alt:hover {
  background: #0284c7;
}

/* --- FIX: Cancel Button Style --- */
.btn-ghost {
  background: white;
  color: #64748b;
  border: 1px solid #cbd5e1;
  padding: 10px 20px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-ghost:hover {
  background: #f1f5f9;
  border-color: #94a3b8;
  color: #334155;
}

/* --- Transitions --- */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

/* --- Utility Classes --- */
.p-12 {
  padding: 3rem;
}

.text-center {
  text-align: center;
}

.text-gray-500 {
  color: #64748b;
}

.text-red-600 {
  color: #dc2626;
}

.text-3xl {
  font-size: 1.875rem;
  line-height: 2.25rem;
}

.text-4xl {
  font-size: 2.25rem;
  line-height: 2.5rem;
}

.mb-3 {
  margin-bottom: 0.75rem;
}

.mt-4 {
  margin-top: 1rem;
}

.p-4 {
  padding: 1rem;
}

.flex {
  display: flex;
}

.items-center {
  align-items: center;
}

.justify-between {
  justify-content: space-between;
}

.gap-2 {
  gap: 0.5rem;
}

.gap-1 {
  gap: 0.25rem;
}

.text-sm {
  font-size: 0.875rem;
  line-height: 1.25rem;
}

.text-gray-600 {
  color: #475569;
}

.border {
  border-width: 1px;
}

.border-gray-300 {
  border-color: #cbd5e1;
}

.rounded-md {
  border-radius: 0.375rem;
}

.px-3 {
  padding-left: 0.75rem;
  padding-right: 0.75rem;
}

.py-1\.5 {
  padding-top: 0.375rem;
  padding-bottom: 0.375rem;
}

.disabled\:opacity-50:disabled {
  opacity: 0.5;
}

.disabled\:cursor-not-allowed:disabled {
  cursor: not-allowed;
}

.hover\:bg-gray-50:hover:not(:disabled) {
  background-color: #f8fafc;
}

.bg-blue-600 {
  background-color: #2563eb;
}

.text-white {
  color: #ffffff;
}

.border-blue-600 {
  border-color: #2563eb;
}
</style>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useRuntimeConfig, useCookie, navigateTo } from '#app'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'

definePageMeta({
  middleware: ['admin-auth']
})

useHead({
  title: 'Incident Management • Admin',
  link: [{ rel: 'stylesheet', href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css' }]
})

const collapsed = ref(false)
const filterStatus = ref('')
const filterPriority = ref('')
const selectedIncident = ref(null)
const config = useRuntimeConfig()
const isLoading = ref(false)
const loadError = ref('')
const searchQuery = ref('')
const currentPage = ref(1)
const pageLimit = ref(20)
const pagination = ref({
  total: 0,
  totalPages: 0,
  page: 1,
  limit: 20
})

const incidents = ref([])


const filteredIncidents = computed(() => incidents.value)

async function fetchIncidents(page = 1) {
  isLoading.value = true
  loadError.value = ''
  try {
    const token = useCookie('token')?.value || (process.client ?
      localStorage.getItem('token') : '')

    const queryParams = {
      page: currentPage.value,
      limit: pageLimit.value,
      sortBy: 'createdAt',
      sortOrder: 'desc'
    }

    if (filterStatus.value) queryParams.status = filterStatus.value
    if (filterPriority.value) queryParams.priority = filterPriority.value
    if (searchQuery.value.trim()) queryParams.q = searchQuery.value.trim()

    const response = await $fetch('/incidents/admin', {
      baseURL: config.public.apiBase,
      method: 'GET',
      headers: {
        Accept: 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      },
      query: queryParams
    })
    
    incidents.value = response.data || []
    pagination.value = response.pagination || { total: 0, totalPages: 0, page: 1, limit: 20 }

  } catch (err) {
    console.error('Error fetching incidents:', err)
    loadError.value = err?.data?.message || err?.message || 'ไม่สามารถโหลดข้อมูลได้'
    incidents.value = []
  } finally {
    isLoading.value = false
  }
}

const goToPage = (page) => {
  if (page >= 1 && page <= pagination.value.totalPages) {
    currentPage.value = page
    fetchIncidents()
  }
}

const nextPage = () => {
  if (currentPage.value < pagination.value.totalPages) {
    currentPage.value++
    fetchIncidents()
  }
}

const prevPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
    fetchIncidents()
  }
}

const pendingCount = computed(() => {
  return incidents.value.filter(i => i.status === "PENDING").length
})
const urgentCount = computed(() => {
  return incidents.value.filter(i => i.priority === "URGENT").length
})

const openDetail = (incident) => { selectedIncident.value = { ...incident } }
const closeDetail = () => { selectedIncident.value = null }
const startChat = (incident) => {
  const chatRoomId = incident?.chatRoom?.id
  if (chatRoomId) {
    closeDetail()
    navigateTo(`/chat?room=${chatRoomId}`)
  } else {
    alert('ไม่พบห้องแชทสำหรับเหตุการณ์นี้ กรุณาลองใหม่อีกครั้ง')
  }
}
const updateStatus = async (incident) => {
  try {
    const token = useCookie('token')?.value || (process.client ? localStorage.getItem('token') : '')
    
    await $fetch(`/incidents/admin/${incident.id}`, {
      baseURL: config.public.apiBase,
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      },
      body: { status: incident.status }
    })
    
    await fetchIncidents()
  } catch (err) {
    console.error('Error updating status:', err)
    alert('ไม่สามารถอัปเดตสถานะได้: ' + (err?.data?.message || err?.message))
    await fetchIncidents()
  }
}

const resolveIncident = async () => {
  if (!selectedIncident.value) return
  
  try {
    const token = useCookie('token')?.value || (process.client ? localStorage.getItem('token') : '')
    
    await $fetch(`/incidents/admin/${selectedIncident.value.id}`, {
      baseURL: config.public.apiBase,
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      },
      body: {
        status: 'RESOLVED',
        resolution: selectedIncident.value.resolution || 'เหตุการณ์ได้รับการแก้ไขแล้ว'
      }
    })
    
    closeDetail()
    await fetchIncidents()
  } catch (err) {
    console.error('Error resolving incident:', err)
    alert('ไม่สามารถแก้ไขเหตุการณ์ได้: ' + (err?.data?.message || err?.message))
  }
}

const fetchData = () => fetchIncidents()

onMounted(() => {
  fetchIncidents()
})

watch([filterStatus, filterPriority], () => {
  currentPage.value = 1
  fetchIncidents()
})

let searchTimer = null
watch(searchQuery, () => {
  clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    currentPage.value = 1
    fetchIncidents()
  }, 500)
})

</script>