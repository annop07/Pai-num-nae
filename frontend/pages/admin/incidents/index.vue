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
          <input v-model="searchQuery" type="text" placeholder="ค้นหา Email, ชื่อผู้รายงาน, รายละเอียด..."
            class="smooth-select" />
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
        <button class="btn-link" @click="filterStatus = ''; filterPriority = ''; searchQuery = ''">Clear
          Filters</button>
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
                  <span v-if="incident.reporter?.role" :class="['role-badge', incident.reporter.role.toLowerCase()]">
                    {{ incident.reporter.role }}
                  </span>
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
            <button @click="prevPage" :disabled="currentPage === 1"
              class="px-3 py-1.5 border border-gray-300 rounded-md text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50">
              <i class="fa-solid fa-chevron-left"></i> Previous
            </button>

            <div class="flex gap-1">
              <button v-for="page in Math.min(pagination.totalPages, 5)" :key="page" @click="goToPage(page)" :class="[
                'px-3 py-1.5 border rounded-md text-sm',
                currentPage === page
                  ? 'bg-blue-600 text-white border-blue-600'
                  : 'border-gray-300 hover:bg-gray-50'
              ]">
                {{ page }}
              </button>
            </div>

            <button @click="nextPage" :disabled="currentPage === pagination.totalPages"
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

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useRuntimeConfig, useCookie, useRouter } from '#app'
import './index.css'
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
const router = useRouter()
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

const resolveIncident = () => {
  if (!selectedIncident.value) return

  const incidentId = selectedIncident.value.id

  selectedIncident.value = null

  router.push({
    path: '/admin/formChange',
    query: { incidentId }
  })
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