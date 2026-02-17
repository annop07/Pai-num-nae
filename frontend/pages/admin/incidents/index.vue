<template>
  <div class="admin-container">
    <div class="page-header">
      <h1 class="page-title">Incident Management</h1>
      <button class="btn-refresh" @click="fetchData">
        <i class="fas fa-sync"></i> Refresh Data
      </button>
    </div>

    <div class="summary-grid">
      <div class="stat-card">
        <div class="stat-info">
          <span class="stat-label">Total Incidents</span>
          <span class="stat-value">{{ incidents.length }}</span>
        </div>
        <div class="stat-icon total"><i class="fas fa-clipboard-list"></i></div>
      </div>
      
      <div class="stat-card border-pending">
        <div class="stat-info">
          <span class="stat-label">Pending</span>
          <span class="stat-value text-pending">{{ pendingCount }}</span>
        </div>
        <div class="stat-icon pending"><i class="fas fa-clock"></i></div>
      </div>

      <div class="stat-card border-urgent">
        <div class="stat-info">
          <span class="stat-label">Urgent</span>
          <span class="stat-value text-urgent">{{ urgentCount }}</span>
        </div>
        <div class="stat-icon urgent"><i class="fas fa-exclamation-triangle"></i></div>
      </div>
    </div>

    <div class="content-card filter-bar">
      <div class="filter-group">
        <label>Status</label>
        <select v-model="filterStatus" class="custom-select">
          <option value="">All Status</option>
          <option>PENDING</option>
          <option>INVESTIGATING</option>
          <option>RESOLVED</option>
          <option>DISMISSED</option>
          <option>ESCALATED</option>
        </select>
      </div>

      <div class="filter-group">
        <label>Priority</label>
        <select v-model="filterPriority" class="custom-select">
          <option value="">All Priority</option>
          <option>LOW</option>
          <option>NORMAL</option>
          <option>HIGH</option>
          <option>URGENT</option>
        </select>
      </div>
      
      <button class="btn-clear" @click="filterStatus=''; filterPriority=''">Clear Filter</button>
    </div>

    <div class="content-card table-wrapper">
      <table class="modern-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Reporter</th>
            <th>Reported User</th>
            <th>Type</th>
            <th>Priority</th>
            <th>Status</th>
            <th>Created At</th>
            <th class="text-center">Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="incident in filteredIncidents" :key="incident.id">
            <td class="font-bold">{{ incident.id }}</td>
            <td>{{ incident.reporter }}</td>
            <td>{{ incident.reportedUser }}</td>
            <td><span class="type-text">{{ incident.type }}</span></td>
            <td>
              <span :class="['badge-priority', incident.priority.toLowerCase()]">
                {{ incident.priority }}
              </span>
            </td>
            <td>
              <select 
                v-model="incident.status" 
                @change="updateStatus(incident)"
                class="status-select"
              >
                <option>PENDING</option>
                <option>INVESTIGATING</option>
                <option>RESOLVED</option>
                <option>DISMISSED</option>
                <option>ESCALATED</option>
              </select>
            </td>
            <td class="text-muted">{{ incident.createdAt }}</td>
            <td class="text-center">
              <button class="btn-view" @click="openDetail(incident)">
                View Detail
              </button>
            </td>
          </tr>
          <tr v-if="filteredIncidents.length === 0">
            <td colspan="8" class="empty-state">No incidents found.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <transition name="fade">
      <div v-if="selectedIncident" class="modal-overlay" @click.self="closeDetail">
        <div class="modal-content">
          <div class="modal-header">
            <h2>Incident Detail</h2>
            <button class="close-btn" @click="closeDetail">&times;</button>
          </div>
          <div class="modal-body">
            <div class="detail-row">
                <label>Title</label>
                <p>{{ selectedIncident.title }}</p>
            </div>

            <div class="detail-row">
                <label>Description</label>
                <p>{{ selectedIncident.description }}</p>
            </div>

            <div class="detail-row">
                <label>Resolution Note</label>
                <textarea 
                v-model="selectedIncident.resolution" 
                placeholder="Enter resolution details..."
                rows="4"
                ></textarea>
            </div>

            <div 
                class="detail-row" 
                v-if="selectedIncident?.location"
            >
                <label>Incident Location</label>

                <iframe
                width="100%"
                height="250"
                style="border-radius:12px; border:0"
                loading="lazy"
                allowfullscreen
                :src="`https://www.google.com/maps?q=${selectedIncident.location.lat},${selectedIncident.location.lng}&z=15&output=embed`">
                </iframe>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn-secondary" @click="closeDetail">Cancel</button>
            <button class="btn-primary" @click="resolveIncident">Mark as Resolved</button>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<style scoped>
/* Base Styles */
.admin-container {
  padding: 24px;
  background-color: #f8fafc;
  min-height: 100vh;
  font-family: 'Inter', 'Kanit', sans-serif;
  color: #334155;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.page-title {
  font-size: 24px;
  font-weight: 700;
  color: #1e293b;
}

/* Summary Cards */
.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  padding: 20px;
  border-radius: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  border-left: 4px solid #cbd5e1;
}

.stat-label { color: #64748b; font-size: 14px; display: block; }
.stat-value { font-size: 24px; font-weight: 700; margin-top: 4px; display: block; }

.border-pending { border-left-color: #f59e0b; }
.border-urgent { border-left-color: #ef4444; }
.text-pending { color: #d97706; }
.text-urgent { color: #dc2626; }

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
}
.stat-icon.total { background: #f1f5f9; color: #475569; }
.stat-icon.pending { background: #fffbeb; color: #d97706; }
.stat-icon.urgent { background: #fef2f2; color: #dc2626; }

/* Content Cards */
.content-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  margin-bottom: 24px;
}

.filter-bar {
  padding: 20px;
  display: flex;
  gap: 20px;
  align-items: flex-end;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.filter-group label {
  font-size: 13px;
  font-weight: 600;
  color: #64748b;
}

.custom-select, .status-select {
  padding: 8px 12px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  background-color: #fff;
  min-width: 160px;
  outline: none;
}

.custom-select:focus { border-color: #2563eb; }

/* Table Style */
.table-wrapper { overflow: hidden; }
.modern-table {
  width: 100%;
  border-collapse: collapse;
  text-align: left;
}

.modern-table th {
  background: #f8fafc;
  padding: 16px;
  font-size: 13px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #64748b;
  border-bottom: 1px solid #e2e8f0;
}

.modern-table td {
  padding: 16px;
  border-bottom: 1px solid #f1f5f9;
  font-size: 14px;
}

.modern-table tr:hover { background-color: #fbfcfd; }

.badge-priority {
  padding: 4px 10px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
}
.low { background: #f1f5f9; color: #475569; }
.normal { background: #e0f2fe; color: #0369a1; }
.high { background: #ffedd5; color: #c2410c; }
.urgent { background: #fee2e2; color: #b91c1c; }

/* Buttons */
.btn-view {
  color: #2563eb;
  background: transparent;
  border: 1px solid #2563eb;
  padding: 6px 14px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-view:hover { background: #2563eb; color: white; }

.btn-primary {
  background: #2563eb;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
}

/* Modal Style */
.modal-overlay {
  position: fixed;
  top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(15, 23, 42, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  backdrop-filter: blur(4px);
  z-index: 1000;
}

.modal-content {
  background: white;
  width: 500px;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
}

.modal-header {
  padding: 20px;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-body { padding: 20px; }
.detail-row { margin-bottom: 16px; }
.detail-row label { display: block; font-weight: 600; margin-bottom: 4px; color: #64748b; }
.detail-row p { color: #1e293b; line-height: 1.5; }

textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  resize: none;
}

.modal-footer {
  padding: 16px 20px;
  background: #f8fafc;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* Transitions */
.fade-enter-active, .fade-leave-active { transition: opacity 0.3s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>

<script setup>
import { ref, computed } from 'vue'

/* ---------------------------
   STATE (Reactive Variables)
----------------------------*/
const filterStatus = ref('')
const filterPriority = ref('')
const selectedIncident = ref(null)

const incidents = ref([
  {
    id: "INC-001",
    reporter: "Passenger A",
    reportedUser: "Driver Somchai",
    type: "SAFETY_CONCERN",
    priority: "HIGH",
    status: "PENDING",
    title: "Speeding",
    description: "Driver was driving over speed limit.",
    resolution: "",
    createdAt: "2026-02-16 10:30",
    location: {
      lat: 13.7563,
      lng: 100.5018
    }
  }
])


/* ---------------------------
   COMPUTED KPI + FILTER
----------------------------*/
const filteredIncidents = computed(() => {
  return incidents.value.filter(i => {
    const statusMatch =
      !filterStatus.value || i.status === filterStatus.value
    const priorityMatch =
      !filterPriority.value || i.priority === filterPriority.value
    return statusMatch && priorityMatch
  })
})

const pendingCount = computed(() =>
  incidents.value.filter(i => i.status === "PENDING").length
)

const urgentCount = computed(() =>
  incidents.value.filter(i => i.priority === "URGENT").length
)

/* ---------------------------
   ACTIONS
----------------------------*/
const updateStatus = (incident) => {
  console.log("Status updated:", incident.id, incident.status)
}

const openDetail = (incident) => {
  selectedIncident.value = { ...incident }
}

const closeDetail = () => {
  selectedIncident.value = null
}

const resolveIncident = () => {
  if (!selectedIncident.value) return

  const index = incidents.value.findIndex(
    i => i.id === selectedIncident.value.id
  )

  if (index !== -1) {
    incidents.value[index].status = "RESOLVED"
    incidents.value[index].resolution =
      selectedIncident.value.resolution
  }

  closeDetail()
}

const fetchData = () => {
  console.log("Mock refresh triggered")
}
</script>
