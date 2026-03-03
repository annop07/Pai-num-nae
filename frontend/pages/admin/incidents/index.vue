<template>
  <div>
    <AdminHeader />
    <AdminSidebar />

    <main
      :class="[
        'admin-wrapper transition-all duration-300',
        collapsed ? 'ml-20' : 'ml-[280px]',
      ]"
    >
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
          <div class="kpi-icon red">
            <i class="fas fa-exclamation-circle"></i>
          </div>
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
        <button
          class="btn-link"
          @click="
            filterStatus = '';
            filterPriority = '';
            searchQuery = '';
          "
        >
          Clear Filters
        </button>
      </div>

      <!-- Loading State -->
      <div v-if="isLoading" class="content-card p-12 text-center text-gray-500">
        <i class="fa-solid fa-spinner fa-spin text-3xl mb-3"></i>
        <p>กำลังโหลดข้อมูล...</p>
      </div>

      <!-- Error State -->
      <div
        v-else-if="loadError"
        class="content-card p-12 text-center text-red-600"
      >
        <i class="fa-solid fa-circle-exclamation text-3xl mb-3"></i>
        <p>{{ loadError }}</p>
        <button @click="fetchIncidents" class="mt-4 btn-refresh">
          ลองใหม่
        </button>
      </div>

      <!-- Empty State -->
      <div
        v-else-if="!isLoading && incidents.length === 0"
        class="content-card p-12 text-center text-gray-500"
      >
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
            <tr
              v-for="incident in filteredIncidents"
              :key="incident.id"
              class="table-row"
            >
              <td class="id-cell">{{ incident.reporter?.username || "—" }}</td>
              <td>
                <div class="user-info">
                  <strong>
                    {{ incident.reporter?.email || "—" }}
                  </strong>
                  <span
                    v-if="incident.reporter?.role"
                    :class="[
                      'role-badge',
                      incident.reporter.role.toLowerCase(),
                    ]"
                  >
                    {{ incident.reporter.role }}
                  </span>
                  <span class="target-text">
                    Target: {{ incident.reportedUser?.email || "—" }}
                  </span>
                </div>
              </td>
              <td>
                <span class="type-tag">{{
                  incident.type.replace("_", " ")
                }}</span>
              </td>
              <td>
                <span :class="['badge', incident.priority.toLowerCase()]">{{
                  incident.priority
                }}</span>
              </td>
              <td>
                <span :class="['badge', incident.status.toLowerCase()]">{{
                  incident.status
                }}</span>
              </td>
              <td class="text-center">
                <button class="btn-action" @click="openDetail(incident)">
                  View & Take Action
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="!isLoading && incidents.length > 0" class="content-card p-4">
        <div class="flex items-center justify-between">
          <div class="text-sm text-gray-600">
            แสดง {{ (currentPage - 1) * pageLimit + 1 }} -
            {{ Math.min(currentPage * pageLimit, pagination.total) }}
            จากทั้งหมด {{ pagination.total }} รายการ
          </div>
          <div class="flex gap-2">
            <button
              @click="prevPage"
              :disabled="currentPage === 1"
              class="px-3 py-1.5 border border-gray-300 rounded-md text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
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
                    : 'border-gray-300 hover:bg-gray-50',
                ]"
              >
                {{ page }}
              </button>
            </div>

            <button
              @click="nextPage"
              :disabled="currentPage === pagination.totalPages"
              class="px-3 py-1.5 border border-gray-300 rounded-md text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
              Next <i class="fa-solid fa-chevron-right"></i>
            </button>
          </div>
        </div>
      </div>

      <!-- Success Overlay -->
      <transition name="success-fade">
        <div v-if="showSuccess" class="success-overlay">
          <div class="success-box">
            <div class="success-checkmark">
              <svg viewBox="0 0 52 52" class="checkmark-svg">
                <circle class="checkmark-circle" cx="26" cy="26" r="25" fill="none"/>
                <path class="checkmark-check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
              </svg>
            </div>
            <p class="success-text">บันทึกสำเร็จ</p>
          </div>
        </div>
      </transition>

      <transition name="modal-fade">
        <div v-if="selectedIncident" class="fixed inset-0 z-50 flex items-start justify-center p-4 pt-16 bg-black/50 overflow-y-auto" @click.self="closeDetail">
          <div class="bg-white w-full max-w-2xl mx-auto rounded-2xl flex flex-col shadow-2xl relative mb-16 mt-4">
            
            <!-- Close Button -->
            <button class="absolute top-4 right-4 text-gray-400 hover:text-gray-600 z-10 transition" @click="closeDetail">
              <i class="fa-solid fa-times text-xl"></i>
            </button>

            <!-- Floating Shield/Folder Icon -->
            <div class="absolute -top-8 left-1/2 transform -translate-x-1/2">
              <div class="w-16 h-16 bg-white rounded-full flex items-center justify-center shadow-md border border-gray-100">
                <div class="w-12 h-12 bg-blue-600 rounded-full flex items-center justify-center text-white">
                  <i v-if="['RESOLVED', 'DISMISSED'].includes(selectedIncident.status)" class="fa-solid fa-folder-open text-2xl"></i>
                  <i v-else class="fa-solid fa-shield-halved text-2xl"></i>
                </div>
              </div>
            </div>

            <div class="p-6 pt-10">
              <!-- Header -->
              <div class="text-center mb-5">
                <h3 class="text-lg font-bold text-gray-800">
                  {{ ['RESOLVED', 'DISMISSED'].includes(selectedIncident.status) ? 'แบบฟอร์มเปิดเคสใหม่' : 'แบบฟอร์มดำเนินการและอัปเดตสถานะเหตุการณ์' }}
                </h3>
                <p class="text-xs text-gray-500 mt-1 font-medium">
                  {{ ['RESOLVED', 'DISMISSED'].includes(selectedIncident.status) ? 'แบบฟอร์มบันทึกเปิดเคสใหม่ (Re-Opened)' : 'แบบฟอร์มบันทึกการดำเนินการและเปลี่ยนสถานะ (Admin Only)' }}
                </p>
              </div>
              
              <hr class="border-gray-100 mb-6" />

              <!-- Read-only Details -->
              <div class="space-y-4 mb-6">
                <div>
                  <label class="block text-xs font-bold text-gray-800 mb-1">Incident ID</label>
                  <input type="text" readonly :value="selectedIncident.reporter?.email || selectedIncident.id" class="w-full px-4 py-2.5 border border-gray-200 rounded-xl bg-white text-gray-700 text-sm focus:outline-none" />
                </div>
                
                <div>
                  <label class="block text-xs font-bold text-gray-800 mb-1">Issue Type</label>
                  <input type="text" readonly :value="selectedIncident.type.replace('_', ' ')" class="w-full px-4 py-2.5 border border-gray-200 rounded-xl bg-white text-gray-700 text-sm focus:outline-none" />
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                  <div>
                    <label class="block text-xs font-bold text-gray-800 mb-1 text-center sm:text-left">Priority Level</label>
                    <input type="text" readonly :value="selectedIncident.priority" class="w-full px-4 py-2.5 border border-gray-200 rounded-xl bg-white text-gray-700 text-sm focus:outline-none text-center" />
                  </div>
                  <div>
                    <label class="block text-xs font-bold text-gray-800 mb-1 text-center sm:text-left">Reporter Name</label>
                    <input type="text" readonly :value="selectedIncident.reporter?.firstName || selectedIncident.reporter?.email || 'Unknown'" class="w-full px-4 py-2.5 border border-gray-200 rounded-xl bg-white text-gray-700 text-sm focus:outline-none text-center" />
                  </div>
                  <div>
                    <label class="block text-xs font-bold text-gray-800 mb-1 text-center sm:text-left">Current Status</label>
                    <input type="text" readonly :value="selectedIncident.status" class="w-full px-4 py-2.5 border border-gray-200 rounded-xl bg-white text-gray-700 text-sm focus:outline-none text-center" />
                  </div>
                </div>

                <div class="w-full sm:w-1/3">
                  <label class="block text-xs font-bold text-gray-800 mb-1">Time</label>
                  <input type="text" readonly :value="formatDate(selectedIncident.createdAt)" class="w-full px-4 py-2.5 border border-gray-200 rounded-xl bg-white text-gray-700 text-sm focus:outline-none" />
                </div>
                
                <!-- Original Description -->
                <div>
                  <label class="block text-xs font-bold text-gray-800 mb-1">Incident Description</label>
                  <textarea readonly class="w-full px-4 py-3 border border-gray-200 rounded-xl bg-gray-50 text-gray-700 text-sm focus:outline-none resize-none" rows="3" :value="selectedIncident.description"></textarea>
                </div>

                <!-- Evidence Section -->
                <div v-if="selectedIncident.evidenceUrls?.length" class="mt-4">
                  <label class="block text-xs font-bold text-gray-800 mb-2">Media Evidence</label>
                  <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
                    <template v-for="(url, idx) in selectedIncident.evidenceUrls" :key="idx">
                      <!-- PDF: ใช้ไอคอน + ลิงก์ (ไม่ใช้ img เพื่อให้ Chrome แสดงถูกต้อง) -->
                      <a v-if="isEvidencePdf(url)" :href="url" target="_blank" rel="noopener noreferrer"
                        class="aspect-square flex flex-col items-center justify-center rounded-xl border border-red-200 bg-red-50 hover:border-red-400 transition p-3">
                        <i class="fa-solid fa-file-pdf text-red-500 text-3xl mb-1"></i>
                        <span class="text-xs font-medium text-red-700 text-center">หลักฐาน {{ idx + 1 }}</span>
                        <span class="text-xs text-red-600 mt-0.5">PDF</span>
                      </a>
                      <!-- Video: พรีวิว + ปุ่มเปิด (เล่นในโมดัล) / ดาวน์โหลด -->
                      <div v-else-if="isEvidenceVideo(url)"
                        class="aspect-square rounded-xl overflow-hidden border border-gray-200 hover:border-blue-500 transition relative group shadow-sm">
                        <video :src="url" class="object-cover w-full h-full group-hover:scale-105 transition duration-500" preload="metadata" muted playsinline></video>
                        <!-- ไอคอนเล่นตรงกลาง -->
                        <button type="button" @click.stop="openVideoModal(url)"
                          class="absolute inset-0 w-full h-full flex items-center justify-center bg-black/20 group-hover:bg-black/40 transition duration-300">
                          <i class="fa-solid fa-circle-play text-white/90 group-hover:text-white text-4xl drop-shadow-lg transform group-hover:scale-110 transition duration-300"></i>
                        </button>
                        <!-- แถบเครื่องมือด้านล่าง -->
                        <div class="absolute bottom-0 left-0 right-0 flex gap-2 p-2 bg-gradient-to-t from-black/80 to-transparent opacity-0 group-hover:opacity-100 transition duration-300 translate-y-2 group-hover:translate-y-0">
                          <button type="button" @click.stop="openVideoModal(url)"
                            class="flex-1 flex items-center justify-center gap-1.5 text-xs py-1.5 rounded-lg bg-white/20 hover:bg-white/30 text-white backdrop-blur-sm border border-white/30 transition shadow-sm">
                            <i class="fa-solid fa-play"></i>เปิด
                          </button>
                          <button type="button" @click.stop="downloadEvidenceFile(evidenceVideoDownloadUrl(url), getEvidenceFilename(url))"
                            class="flex-1 flex items-center justify-center gap-1.5 text-xs py-1.5 rounded-lg bg-blue-600/90 hover:bg-blue-500 text-white backdrop-blur-sm border border-blue-400/50 transition shadow-sm">
                            <i class="fa-solid fa-download"></i>โหลด
                          </button>
                        </div>
                      </div>
                      <!-- Image -->
                      <a v-else :href="url" target="_blank" rel="noopener noreferrer"
                        class="aspect-square block rounded-xl overflow-hidden border border-gray-200 hover:border-blue-500 transition relative group">
                        <img :src="url" :alt="`หลักฐาน ${idx + 1}`" class="object-cover w-full h-full group-hover:scale-105 transition duration-300" loading="lazy" />
                        <div class="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition flex items-center justify-center">
                          <i class="fa-solid fa-expand text-white opacity-0 group-hover:opacity-100 drop-shadow-md"></i>
                        </div>
                      </a>
                    </template>
                  </div>
                </div>

                <!-- Map Section -->
                <div v-if="selectedIncident.location" class="mt-4">
                  <label class="block text-xs font-bold text-gray-800 mb-2"><i class="fas fa-map-marker-alt text-red-500 mr-1"></i> Location</label>
                  <div class="rounded-xl overflow-hidden border border-gray-200">
                    <iframe
                      width="100%"
                      height="200"
                      frameborder="0"
                      loading="lazy"
                      :src="`https://maps.google.com/maps?q=${selectedIncident.location.lat},${selectedIncident.location.lng}&z=15&output=embed`"
                    ></iframe>
                  </div>
                </div>
              </div>
              
              <hr class="border-gray-100 my-6" />

              <!-- Action Section -->
              <div v-if="allowedNextStatuses.length > 0" class="space-y-4">
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-xs font-bold text-gray-800 mb-1">New Status <span class="text-red-500">*</span></label>
                    <select v-model="statusForm.newStatus" class="w-full px-4 py-2.5 border border-gray-200 rounded-xl bg-white text-gray-700 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition">
                      <option value="">-- เลือกสถานะใหม่ --</option>
                      <option v-for="s in allowedNextStatuses" :key="s" :value="s">{{ s }}</option>
                    </select>
                  </div>
                  <div>
                    <label class="block text-xs font-bold text-gray-800 mb-1">Reason Category <span class="text-red-500">*</span></label>
                    <select v-model="statusForm.reason" class="w-full px-4 py-2.5 border border-gray-200 rounded-xl bg-white text-gray-700 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition">
                      <option value="">-- เลือกเหตุผล --</option>
                      <option value="EVIDENCE_REVIEWED">ตรวจสอบหลักฐานแล้ว</option>
                      <option value="POLICY_VIOLATION">ละเมิดนโยบาย</option>
                      <option value="INSUFFICIENT_EVIDENCE">หลักฐานไม่เพียงพอ</option>
                      <option value="FALSE_REPORT">รายงานเท็จ</option>
                      <option value="MATTER_RESOLVED">แก้ไขปัญหาได้แล้ว</option>
                      <option value="REQUIRES_ESCALATION">ต้องส่งต่อ</option>
                      <option value="OTHER">อื่นๆ</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label class="block text-xs font-bold text-gray-800 mb-1">Description <span class="text-red-500">*</span></label>
                  <textarea v-model="statusForm.note" class="w-full px-4 py-3 border border-gray-200 rounded-xl bg-white text-gray-700 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition" rows="4" placeholder="โปรดอธิบายสิ่งที่แก้ไข..."></textarea>
                </div>

                <div>
                  <label class="block text-xs font-bold text-gray-800 mb-1">Resolution Note (Internal Only)</label>
                  <textarea v-model="statusForm.resolution" class="w-full px-4 py-2.5 border border-gray-200 rounded-xl bg-gray-50 text-gray-700 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition" rows="2" placeholder="บันทึกภายในสำหรับแอดมิน..."></textarea>
                </div>

                <div class="flex items-center gap-2 mt-2 pt-2">
                  <input type="checkbox" id="confirmCheck" v-model="statusForm.confirmed" class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500" />
                  <label for="confirmCheck" class="text-xs text-gray-600">ฉันทราบว่าการเปลี่ยนสถานะนี้จะถูกบันทึกถาวรและไม่สามารถแก้ไขได้</label>
                </div>
                
                <div class="mt-6 pt-4 border-t border-gray-100">
                  <button 
                    :disabled="!statusForm.newStatus || !statusForm.reason || !statusForm.note || !statusForm.confirmed || submitLoading" 
                    @click="submitStatusUpdate" 
                    class="w-full py-3.5 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl transition duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-sm shadow-md shadow-blue-500/30">
                    {{ submitLoading ? 'กำลังบันทึก...' : 'รายงาน' }}
                  </button>
                </div>
              </div>

              <!-- Reopen Form Section -->
              <div v-else-if="['RESOLVED', 'DISMISSED'].includes(selectedIncident.status)" class="space-y-4">
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-2">
                  <div>
                    <label class="block text-xs font-bold text-gray-800 mb-1 text-center sm:text-left">ผู้ที่ปิดเคส</label>
                    <input type="text" readonly :value="selectedIncident.resolver?.firstName || 'ไม่ระบุ'" class="w-full px-4 py-2.5 border border-gray-200 rounded-xl bg-white text-gray-700 text-sm focus:outline-none text-center" />
                  </div>
                  <div>
                    <div class="flex justify-between items-center mb-1">
                      <label class="block text-xs font-bold text-gray-800 text-center sm:text-left">สรุปผลการแก้ไขครั้งก่อน</label>
                    
                    </div>
                    <input type="text" readonly :value="selectedIncident.resolution || 'ไม่มีการบันทึกสรุปผล'" class="w-full px-4 py-2.5 border border-gray-200 rounded-xl bg-white text-gray-700 text-sm focus:outline-none" />
                  </div>
                </div>

                <div class="mt-4 pt-4">
                  <label class="block text-xs font-bold text-gray-800 mb-2">เหตุผลในการเปิดเคสใหม่ <span class="text-red-500">*</span></label>
                  <select v-model="reopenForm.reason" class="w-full px-4 py-2.5 border border-gray-200 rounded-xl bg-white text-gray-700 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition mb-3">
                    <option value="">-- เลือกหมวดหมู่เหตุผล --</option>
                    <option value="REOPENED">เปิดใหม่ (ข้อมูลเพิ่มเติม)</option>
                    <option value="INSUFFICIENT_EVIDENCE">หลักฐานไม่เพียงพอในครั้งแรก</option>
                    <option value="OTHER">อื่นๆ</option>
                  </select>
                  <textarea v-model="reopenForm.note" class="w-full px-4 py-3 border border-gray-200 rounded-xl bg-white text-gray-700 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition" rows="4" placeholder="โปรดอธิบายทำไมถึงเปิดเคสใหม่"></textarea>
                </div>
                
                <div class="mt-4 pt-4 border-t border-gray-100">
                  <button 
                    :disabled="!reopenForm.reason || !reopenForm.note || reopenLoading" 
                    @click="submitReopen" 
                    class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl transition duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-sm shadow-md shadow-blue-500/30">
                    {{ reopenLoading ? 'กำลังเปิดใหม่...' : 'รายงาน' }}
                  </button>
                </div>
              </div>

            </div>
          </div>
        </div>
      </transition>

      <!-- โมดัลเล่นวิดีโอ (เปิด = เล่นในหน้า ไม่โหลดไฟล์) -->
      <div v-if="videoModalUrl" class="fixed inset-0 z-[100] flex items-center justify-center bg-black/70 p-4" @click.self="videoModalUrl = null">
        <div class="relative w-full max-w-4xl bg-black rounded-xl overflow-hidden shadow-2xl">
          <button type="button" @click="videoModalUrl = null"
            class="absolute top-2 right-2 z-10 w-10 h-10 rounded-full bg-white/20 hover:bg-white/30 text-white flex items-center justify-center">
            <i class="fa-solid fa-xmark text-xl"></i>
          </button>
          <video :src="videoModalUrl" controls autoplay class="w-full max-h-[85vh]"></video>
        </div>
      </div>
    </main>
  </div>
</template>

<style scoped>
.admin-wrapper {
  padding: 32px;
  background: #f4f7fa;
  min-height: 100vh;
  font-family: "Kanit", sans-serif;
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
  font-family: "Kanit", sans-serif;
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

.role-badge {
  display: inline-block;
  width: fit-content;
  font-size: 10px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  padding: 1px 6px;
  border-radius: 6px;
  margin-top: 3px;
}

.role-badge.passenger {
  background: #f3e8ff;
  color: #7e22ce;
}

.role-badge.driver {
  background: #dcfce7;
  color: #15803d;
}

.role-badge.admin {
  background: #fee2e2;
  color: #b91c1c;
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

/* Status badge colors */
.badge.pending { background: #fef3c7; color: #b45309; }
.badge.investigating { background: #e0e7ff; color: #4338ca; }
.badge.resolved { background: #d1fae5; color: #047857; }
.badge.dismissed { background: #f3f4f6; color: #4b5563; }
.badge.escalated { background: #fce7f3; color: #be185d; }

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

.btn-reopen {
  background: #f97316;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: 0.2s;
}
.btn-reopen:hover { background: #ea580c; }
.btn-reopen:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-submit:disabled { opacity: 0.5; cursor: not-allowed; }

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

/* --- Success Overlay --- */
.success-overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(8px);
  background: rgba(255, 255, 255, 0.6);
}

.success-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}

.success-checkmark {
  width: 96px;
  height: 96px;
}

.checkmark-svg {
  width: 100%;
  height: 100%;
}

.checkmark-circle {
  stroke: #22c55e;
  stroke-width: 2;
  stroke-dasharray: 166;
  stroke-dashoffset: 166;
  animation: stroke-circle 0.4s cubic-bezier(0.65, 0, 0.45, 1) forwards;
}

.checkmark-check {
  stroke: #22c55e;
  stroke-width: 3;
  stroke-linecap: round;
  stroke-linejoin: round;
  stroke-dasharray: 48;
  stroke-dashoffset: 48;
  animation: stroke-check 0.3s cubic-bezier(0.65, 0, 0.45, 1) 0.4s forwards;
}

@keyframes stroke-circle {
  100% { stroke-dashoffset: 0; }
}

@keyframes stroke-check {
  100% { stroke-dashoffset: 0; }
}

.success-text {
  font-size: 18px;
  font-weight: 700;
  color: #334155;
  margin: 0;
}

.success-fade-enter-active {
  transition: opacity 0.2s ease;
}
.success-fade-leave-active {
  transition: opacity 0.4s ease;
}
.success-fade-enter-from,
.success-fade-leave-to {
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
import { ref, computed, watch, onMounted } from "vue";
import { useRuntimeConfig, useCookie } from "#app";
import AdminHeader from "~/components/admin/AdminHeader.vue";
import AdminSidebar from "~/components/admin/AdminSidebar.vue";

definePageMeta({
  middleware: ["admin-auth"],
});

useHead({
  title: "Incident Management • Admin",
  link: [
    {
      rel: "stylesheet",
      href: "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css",
    },
  ],
});

const collapsed = ref(false);
const filterStatus = ref("");
const filterPriority = ref("");
const selectedIncident = ref(null);
const config = useRuntimeConfig();
const isLoading = ref(false);
const loadError = ref("");
const searchQuery = ref("");
const currentPage = ref(1);
const pageLimit = ref(20);
const pagination = ref({
  total: 0,
  totalPages: 0,
  page: 1,
  limit: 20,
});

const incidents = ref([]);

// Status update form
const statusForm = ref({ newStatus: '', reason: '', note: '', resolution: '', confirmed: false })
const submitLoading = ref(false)

// Reopen form
const reopenForm = ref({ reason: '', note: '' })
const reopenLoading = ref(false)

// Success overlay
const showSuccess = ref(false)

// โมดัลเล่นวิดีโอ (กดเปิด = เล่นในหน้า ไม่เปิดลิงก์ที่อาจโหลดไฟล์)
const videoModalUrl = ref(null)
function openVideoModal(url) {
  videoModalUrl.value = url
}

function triggerSuccess() {
  showSuccess.value = true
  setTimeout(() => { showSuccess.value = false }, 2000)
}

// Transition map (ตรงกับ backend)
const ALLOWED_TRANSITIONS = {
  PENDING:       ['INVESTIGATING', 'DISMISSED'],
  INVESTIGATING: ['RESOLVED', 'DISMISSED', 'ESCALATED'],
  ESCALATED:     ['RESOLVED', 'DISMISSED'],
  RESOLVED:      [],
  DISMISSED:     [],
}

const allowedNextStatuses = computed(() => {
  if (!selectedIncident.value) return []
  return ALLOWED_TRANSITIONS[selectedIncident.value.status] || []
})

const filteredIncidents = computed(() => incidents.value);

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

function isEvidencePdf(url) {
  const lower = (url || '').toLowerCase()
  return lower.includes('.pdf') || lower.includes('/raw/upload/')
}
function isEvidenceVideo(url) {
  return /\.(mp4|mov|webm|ogg|avi)$/i.test((url || '').split('?')[0] || '')
}
function getEvidenceFilename(url) {
  try {
    const name = decodeURIComponent((url || '').split('?')[0]).split('/').pop() || 'evidence'
    if (isEvidenceVideo(url) && !name.includes('.')) return name + '.mp4'
    return name
  } catch {
    return 'evidence'
  }
}
function evidenceVideoDownloadUrl(url) {
  if (!url || !isEvidenceVideo(url)) return url
  return url + (url.includes('?') ? '&' : '?') + 'fl_attachment'
}
async function downloadEvidenceFile(url, filename) {
  try {
    const res = await fetch(url, { mode: 'cors' })
    if (!res.ok) throw new Error('HTTP ' + res.status)
    const blob = await res.blob()
    if (blob.size < 100 && blob.type?.includes('text/html')) throw new Error('Got HTML')
    const blobUrl = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = blobUrl
    a.download = filename || 'video.mp4'
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(blobUrl)
  } catch {
    window.open(url, '_blank', 'noopener')
  }
}

async function fetchIncidents(page = 1) {
  isLoading.value = true;
  loadError.value = "";
  try {
    const token =
      useCookie("token")?.value ||
      (process.client ? localStorage.getItem("token") : "");

    const queryParams = {
      page: currentPage.value,
      limit: pageLimit.value,
      sortBy: "createdAt",
      sortOrder: "desc",
    };

    if (filterStatus.value) queryParams.status = filterStatus.value;
    if (filterPriority.value) queryParams.priority = filterPriority.value;
    if (searchQuery.value.trim()) queryParams.q = searchQuery.value.trim();

    const response = await $fetch("/incidents/admin", {
      baseURL: config.public.apiBase,
      method: "GET",
      headers: {
        Accept: "application/json",
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      query: queryParams,
    });

    incidents.value = response.data || [];
    pagination.value = response.pagination || {
      total: 0,
      totalPages: 0,
      page: 1,
      limit: 20,
    };
  } catch (err) {
    console.error("Error fetching incidents:", err);
    loadError.value =
      err?.data?.message || err?.message || "ไม่สามารถโหลดข้อมูลได้";
    incidents.value = [];
  } finally {
    isLoading.value = false;
  }
}

const goToPage = (page) => {
  if (page >= 1 && page <= pagination.value.totalPages) {
    currentPage.value = page;
    fetchIncidents();
  }
};

const nextPage = () => {
  if (currentPage.value < pagination.value.totalPages) {
    currentPage.value++;
    fetchIncidents();
  }
};

const prevPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--;
    fetchIncidents();
  }
};

const pendingCount = computed(() => {
  return incidents.value.filter((i) => i.status === "PENDING").length;
});
const urgentCount = computed(() => {
  return incidents.value.filter((i) => i.priority === "URGENT").length;
});

const openDetail = (incident) => {
  selectedIncident.value = { ...incident }
  statusForm.value = { newStatus: '', reason: '', note: '', resolution: '', confirmed: false }
  reopenForm.value = { reason: '', note: '' }
}
const closeDetail = () => {
  selectedIncident.value = null
}

const submitStatusUpdate = async () => {
  if (!selectedIncident.value) return
  submitLoading.value = true
  try {
    const token = useCookie('token')?.value || (process.client ? localStorage.getItem('token') : '')
    await $fetch(`/incidents/admin/${selectedIncident.value.id}`, {
      baseURL: config.public.apiBase,
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
      body: {
        status: statusForm.value.newStatus,
        reason: statusForm.value.reason,
        note: statusForm.value.note,
        resolution: statusForm.value.resolution || undefined,
      },
    })
    closeDetail()
    triggerSuccess()
    await fetchIncidents()
  } catch (err) {
    alert('ไม่สามารถอัปเดตสถานะได้: ' + (err?.data?.message || err?.message))
  } finally {
    submitLoading.value = false
  }
}

const submitReopen = async () => {
  if (!selectedIncident.value) return
  reopenLoading.value = true
  try {
    const token = useCookie('token')?.value || (process.client ? localStorage.getItem('token') : '')
    await $fetch(`/incidents/admin/${selectedIncident.value.id}/reopen`, {
      baseURL: config.public.apiBase,
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
      body: { reason: reopenForm.value.reason, note: reopenForm.value.note },
    })
    closeDetail()
    triggerSuccess()
    await fetchIncidents()
  } catch (err) {
    alert('ไม่สามารถ Reopen ได้: ' + (err?.data?.message || err?.message))
  } finally {
    reopenLoading.value = false
  }
}

const fetchData = () => fetchIncidents();

onMounted(() => {
  fetchIncidents();
});

watch([filterStatus, filterPriority], () => {
  currentPage.value = 1;
  fetchIncidents();
});

let searchTimer = null;
watch(searchQuery, () => {
  clearTimeout(searchTimer);
  searchTimer = setTimeout(() => {
    currentPage.value = 1;
    fetchIncidents();
  }, 500);
});
</script>
