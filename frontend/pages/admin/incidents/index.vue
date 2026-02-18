<template>
  <div class="admin-wrapper">
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
      <button class="btn-link" @click="filterStatus=''; filterPriority=''">Clear Filters</button>
    </div>

    <div class="content-card table-container">
      <table class="smooth-table">
        <thead>
          <tr>
            <th width="120">ID</th>
            <th>Reporter & Target</th>
            <th>Issue Type</th>
            <th width="100">Priority</th>
            <th width="150">Status</th>
            <th class="text-center">Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="incident in filteredIncidents" :key="incident.id" class="table-row">
            <td class="id-cell">{{ incident.id }}</td>
            <td>
              <div class="user-info">
                <strong>{{ incident.reporter }}</strong>
                <span class="target-text">Target: {{ incident.reportedUser }}</span>
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

    <transition name="modal-fade">
  <div
    v-if="selectedIncident"
    class="modal-backdrop"
    @click.self="closeDetail"
  >
    <div class="modal-sheet">
      
      <div class="modal-head">
        <div class="head-info">
          <span
            :class="['mini-badge', selectedIncident.priority.toLowerCase()]"
          >
            {{ selectedIncident.priority }}
          </span>
          <h3 class="modal-title">
            {{ selectedIncident.title }}
          </h3>
        </div>
        <button class="close-icon" @click="closeDetail">×</button>
      </div>

      <div class="modal-scroll-area">
        <div class="desc-section">
          <label>Description</label>
          <p class="desc-text">
            {{ selectedIncident.description }}
          </p>
        </div>

        <div
          class="evidence-section"
          v-if="selectedIncident.attachments?.length"
        >
          <label>Media Evidence</label>
          <div class="gallery-grid">
            <div
              v-for="(img, idx) in selectedIncident.attachments"
              :key="idx"
              class="img-wrapper"
            >
              <img :src="img" alt="evidence" />
            </div>
          </div>
        </div>

        <div
          class="map-section"
          v-if="selectedIncident.location"
        >
          <label>
            <i class="fas fa-map-marker-alt"></i> Location
          </label>
          <div class="map-box">
            <iframe
              width="100%"
              height="180"
              frameborder="0"
              loading="lazy"
              :src="`https://maps.google.com/maps?q=${selectedIncident.location.lat},${selectedIncident.location.lng}&z=15&output=embed`"
            >
            </iframe>
          </div>
        </div>

        <div class="note-section">
          <label>Admin Resolution Note</label>
          <textarea
            v-model="selectedIncident.resolution"
            placeholder="พิมพ์หมายเหตุการจัดการเหตุการณ์..."
          ></textarea>
        </div>

        <div
          v-if="selectedIncident.newAttachments?.length"
          class="preview-grid"
        >
          <div
            v-for="(file, idx) in selectedIncident.newAttachments"
            :key="idx"
            class="preview-box"
          >
            <img
              v-if="file.type.startsWith('image')"
              :src="file.preview"
            />
            <video
              v-else
              :src="file.preview"
              controls
            ></video>
          </div>
        </div>
      </div>

      <!-- footer ต้องอยู่ใน modal-sheet -->
      <div class="modal-foot">
        <button
          class="btn-chat-alt"
          @click="startChat(selectedIncident)"
        >
          <i class="far fa-comments"></i>
          Chat with Reporter
        </button>

        <div class="foot-rights">
          <button
            class="btn-ghost"
            @click="closeDetail"
          >
            Cancel
          </button>
          <button
            class="btn-submit"
            @click="resolveIncident"
          >
            Confirm Resolved
          </button>
        </div>
      </div>

    </div>
  </div>
</transition>

  </div>
</template>

<style scoped>
/* --- Core Layout & Typography --- */
.admin-wrapper { padding: 32px; background: #f4f7fa; min-height: 100vh; font-family: 'Kanit', sans-serif; color: #334155; }
.page-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 30px; }
.main-title { font-size: 26px; font-weight: 700; color: #1e293b; margin: 0; }
.subtitle { color: #64748b; font-size: 14px; margin-top: 4px; }

/* --- KPI Cards --- */
.stats-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 24px; margin-bottom: 30px; }
.kpi-card { 
  background: white; padding: 24px; border-radius: 16px; display: flex; 
  justify-content: space-between; align-items: center; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
  transition: all 0.3s ease; border: 1px solid #e2e8f0;
}
.kpi-card:hover { transform: translateY(-3px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.08); }
.kpi-value { font-size: 28px; font-weight: 700; display: block; margin-top: 4px; }
.kpi-label { font-size: 14px; color: #64748b; font-weight: 500; }
.kpi-icon { width: 56px; height: 56px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px; }
.kpi-icon.blue { background: #eff6ff; color: #3b82f6; }
.kpi-icon.amber { background: #fff7ed; color: #f59e0b; }
.kpi-icon.red { background: #fef2f2; color: #ef4444; }
.text-amber { color: #f59e0b; }
.text-red { color: #ef4444; }

/* --- Filters & Table --- */
.content-card { background: white; border-radius: 16px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); margin-bottom: 24px; border: 1px solid #e2e8f0; overflow: hidden; }
.filter-section { padding: 20px 24px; display: flex; gap: 20px; align-items: flex-end; background: #fff; }
.input-group { display: flex; flex-direction: column; gap: 8px; }
.input-group label { font-size: 13px; font-weight: 600; color: #64748b; }
.smooth-select, .status-pill { padding: 10px 14px; border-radius: 10px; border: 1px solid #cbd5e1; background: #fff; outline: none; transition: 0.2s; font-size: 14px; min-width: 160px; }
.smooth-select:focus { border-color: #3b82f6; ring: 2px solid #bfdbfe; }
.btn-link { color: #3b82f6; background: none; border: none; font-weight: 500; cursor: pointer; padding-bottom: 10px; }

.smooth-table { width: 100%; border-collapse: separate; border-spacing: 0; }
.smooth-table th { background: #f8fafc; padding: 16px 20px; text-align: left; font-size: 13px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: 0.05em; border-bottom: 1px solid #e2e8f0; }
.smooth-table td { padding: 18px 20px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
.table-row:hover { background-color: #f8fafc; }
.user-info { display: flex; flex-direction: column; }
.target-text { font-size: 13px; color: #94a3b8; margin-top: 2px; }
.id-cell { font-weight: 600; color: #3b82f6; }
.type-tag { background: #f1f5f9; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 500; color: #475569; }

/* --- Status & Badges --- */
.status-pill { border: none; background: #f1f5f9; font-weight: 600; font-size: 12px; cursor: pointer; padding: 6px 12px; border-radius: 20px; text-align: center; }
.badge { padding: 4px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; }
.urgent { background: #fee2e2; color: #b91c1c; }
.high { background: #ffedd5; color: #c2410c; }
.normal { background: #e0f2fe; color: #0369a1; }
.mini-badge { padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; text-transform: uppercase; margin-right: 8px; }

/* --- Buttons --- */
.btn-refresh { display: flex; align-items: center; gap: 8px; padding: 10px 16px; background: white; border: 1px solid #cbd5e1; border-radius: 10px; color: #475569; font-weight: 600; cursor: pointer; transition: all 0.2s; }
.btn-refresh:hover { background: #f8fafc; border-color: #94a3b8; color: #334155; }
.btn-action { color: #3b82f6; background: transparent; border: none; font-weight: 600; cursor: pointer; padding: 8px 12px; border-radius: 8px; transition: 0.2s; }
.btn-action:hover { background: #eff6ff; }

/* --- Modal --- */
.modal-backdrop { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); display: flex; justify-content: center; align-items: center; z-index: 1000; }
.modal-sheet { background: white; width: 600px; border-radius: 24px; overflow: hidden; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); display: flex; flex-direction: column; max-height: 90vh; }
.modal-head { padding: 20px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; background: #fff; }
.head-info { display: flex; align-items: center; }
.modal-title { margin: 0; font-size: 18px; font-weight: 700; color: #1e293b; }
.close-icon { background: none; border: none; font-size: 24px; color: #94a3b8; cursor: pointer; padding: 0; line-height: 1; }
.close-icon:hover { color: #64748b; }

.modal-scroll-area { padding: 24px; overflow-y: auto; flex-grow: 1; }
.desc-section label, .evidence-section label, .map-section label, .note-section label { display: block; font-size: 13px; font-weight: 600; color: #64748b; margin-bottom: 8px; }
.desc-text { background: #f8fafc; padding: 16px; border-radius: 12px; line-height: 1.6; color: #334155; border: 1px solid #e2e8f0; }
.gallery-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 12px; }
.img-wrapper img { width: 100%; height: 100px; object-fit: cover; border-radius: 12px; border: 1px solid #e2e8f0; transition: 0.2s; cursor: zoom-in; }
.img-wrapper img:hover { filter: brightness(0.9); border-color: #cbd5e1; }
.map-box { border-radius: 16px; overflow: hidden; border: 1px solid #e2e8f0; }
textarea { width: 100%; border-radius: 12px; border: 1px solid #cbd5e1; padding: 12px; resize: none; font-family: inherit; font-size: 14px; transition: 0.2s; }
textarea:focus { border-color: #3b82f6; outline: none; }

.modal-foot { padding: 20px 24px; background: #fff; border-top: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
.foot-rights { display: flex; gap: 12px; }
.btn-submit { background: #3b82f6; color: white; border: none; padding: 10px 20px; border-radius: 10px; font-weight: 600; cursor: pointer; transition: 0.2s; }
.btn-submit:hover { background: #2563eb; }
.btn-chat-alt { background: #0ea5e9; color: white; border: none; padding: 10px 20px; border-radius: 10px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: 0.2s; }
.btn-chat-alt:hover { background: #0284c7; }

.upload-section {
  margin-top: 20px;
}

.error-text {
  color: #dc2626;
  font-size: 13px;
  margin-top: 6px;
}

.preview-grid {
  margin-top: 12px;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 12px;
}

.preview-box img,
.preview-box video {
  width: 100%;
  height: 120px;
  object-fit: cover;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
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
.modal-fade-enter-active, .modal-fade-leave-active { transition: opacity 0.3s ease; }
.modal-fade-enter-from, .modal-fade-leave-to { opacity: 0; }
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
    title: "Driver speeding aggressively",
    description: "คนขับขับเร็วมากและเบรกกะทันหันหลายครั้ง ทำให้รู้สึกไม่ปลอดภัย",
    resolution: "",
    createdAt: "2026-02-16 10:30",
    location: {
      lat: 13.7563,
      lng: 100.5018
    },
    attachments: [
      "https://images.unsplash.com/photo-1502877338535-766e1452684a",
      "https://images.unsplash.com/photo-1511919884226-fd3cad34687c"
    ]
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
