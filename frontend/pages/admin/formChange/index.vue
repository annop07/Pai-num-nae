<template>
  <div class="min-h-screen bg-gray-50">
    <div class="w-full px-8 py-12 flex justify-center">
      <div class="w-full max-w-4xl bg-white rounded-2xl shadow-sm border border-gray-200 p-12">

        <div class="text-center mb-10">
          <div class="w-16 h-16 mx-auto rounded-full bg-blue-100 flex items-center justify-center mb-4">
            <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 3l7 4v5c0 5-3.5 9-7 9s-7-4-7-9V7l7-4z" />
            </svg>
          </div>

          <h1 class="text-2xl font-bold text-gray-900">
            แบบฟอร์มดำเนินการและอัปเดตสถานะเหตุการณ์
          </h1>

          <p class="text-gray-500 mt-2 text-sm">
            แบบฟอร์มนี้สำหรับการดำเนินการและเปลี่ยนสถานะ (Admin Only)
          </p>
        </div>

        <div class="space-y-6">

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Incident ID
            </label>
            <input type="text" :value="reporterEmail" readonly
              class="w-full px-4 py-3 border rounded-xl bg-gray-100 text-gray-700" />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Issue Type
            </label>
            <input type="text" :value="issueType" readonly
              class="w-full px-4 py-3 border rounded-xl bg-gray-100 text-gray-700" />
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Priority Level
              </label>
              <input type="text" :value="priority" readonly
                class="w-full px-4 py-3 border rounded-xl bg-gray-100 text-gray-700" />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Reporter Name
              </label>
              <input type="text" :value="reporterName" readonly
                class="w-full px-4 py-3 border rounded-xl bg-gray-100 text-gray-700" />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Current Status
              </label>
              <input type="text" :value="currentStatus" readonly
                class="w-full px-4 py-3 border rounded-xl bg-gray-100 text-gray-700" />
            </div>
          </div>

          <div class="mb-6 relative">
            <label class="block mb-2 font-medium text-gray-700">
              Next Status <span class="text-red-500">*</span>
            </label>

            <div @click="toggleStatus"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl cursor-pointer flex justify-between items-center hover:border-blue-500 transition">
              <span>
                {{ selectedStatus || 'เลือกสถานะ' }}
              </span>
              <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
              </svg>
            </div>

            <div v-if="isStatusOpen"
              class="absolute w-full bg-white border border-gray-200 rounded-xl shadow-lg mt-2 z-20">
              <div v-for="item in statusOptions" :key="item" @click="selectStatus(item)"
                class="px-4 py-3 hover:bg-blue-50 cursor-pointer">
                {{ item }}
              </div>
            </div>
          </div>

          <div class="mb-6 relative">
            <label class="block mb-2 font-medium text-gray-700">
              Reason Category <span class="text-red-500">*</span>
            </label>

            <div @click="toggleReason"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl cursor-pointer flex justify-between items-center hover:border-blue-500 transition">
              <span>
                {{ selectedReason || 'เลือกประเภทเหตุผล' }}
              </span>
              <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
            </svg>
            </div>

            <div v-if="isReasonOpen"
              class="absolute w-full bg-white border border-gray-200 rounded-xl shadow-lg mt-2 z-20">
              <div v-for="item in reasonOptions" :key="item" @click="selectReason(item)"
                class="px-4 py-3 hover:bg-blue-50 cursor-pointer">
                {{ item }}
              </div>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Resolution Note <span class="text-red-500">*</span>
            </label>

            <textarea v-model="resolutionNote" rows="4" placeholder="กรอกหมายเหตุการดำเนินการ..."
              class="w-full px-4 py-3 border border-gray-300 rounded-xl resize-none focus:ring-2 focus:ring-blue-500" />
          </div>

          <div class="flex items-center gap-3 mt-4">
            <input type="checkbox" v-model="isConfirmed" class="w-5 h-5 text-blue-600 border-gray-300 rounded">
            <label class="text-sm text-gray-600">
              ยืนยันว่าระบบจะบันทึกข้อมูลถาวรและไม่สามารถแก้ไขย้อนหลังได้
            </label>
          </div>

        </div>

        <div class="flex justify-end mt-10">
          <button @click="submitChange" :disabled="!isFormValid || isSubmitting"
            class="bg-blue-600 hover:bg-blue-700 text-white px-12 py-4 rounded-xl font-semibold shadow-md transition disabled:opacity-50 disabled:cursor-not-allowed">
            {{ isSubmitting ? 'กำลังบันทึก...' : 'รายงาน' }}
          </button>
        </div>

      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter, useRuntimeConfig, useCookie } from '#app'

const config = useRuntimeConfig()
const isLoading = ref(false)
const loadError = ref('')

const route = useRoute()
const router = useRouter()

const incidentId = ref('')
const reporterEmail = ref('')
const issueType = ref('')
const priority = ref('')
const reporterName = ref('')
const currentStatus = ref('')

const nextStatus = ref('')
const reasonCategory = ref('')
const resolutionNote = ref('')
const isConfirmed = ref(false)
const isSubmitting = ref(false)

const isFormValid = computed(() =>
  nextStatus.value &&
  reasonCategory.value &&
  resolutionNote.value &&
  isConfirmed.value
)

const statusOptions = [
  'INVESTIGATING',
  'RESOLVED',
  'DISMISSED'
]

const selectedStatus = ref('')
const isStatusOpen = ref(false)

function toggleStatus() {
  isStatusOpen.value = !isStatusOpen.value
}

function selectStatus(item) {
  selectedStatus.value = item
  nextStatus.value = item
  isStatusOpen.value = false
}

const reasonOptions = [
  'Invalid Report',
  'Duplicate Case',
  'Insufficient Evidence',
  'Violation Confirmed'
]

const selectedReason = ref('')
const isReasonOpen = ref(false)

function toggleReason() {
  isReasonOpen.value = !isReasonOpen.value
}

function selectReason(item) {
  selectedReason.value = item
  reasonCategory.value = item
  isReasonOpen.value = false
}

async function fetchIncidentDetail() {
  if (!route.query.incidentId) return

  isLoading.value = true
  loadError.value = ''

  try {
    const token =
      useCookie('token')?.value ||
      (process.client ? localStorage.getItem('token') : '')

    const res = await $fetch(`/incidents/admin/${route.query.incidentId}`, {
      baseURL: config.public.apiBase,
      headers: {
        Accept: 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      }
    })

    const data = res.data || res

    incidentId.value = data.id
    reporterEmail.value = data.reporter?.email || ''
    issueType.value = data.type?.replace('_', ' ')
    priority.value = data.priority
    reporterName.value = data.reporter?.username
    currentStatus.value = data.status

  } catch (err) {
    console.error(err)
    loadError.value =
      err?.data?.message || 'ไม่สามารถโหลดข้อมูลเหตุการณ์ได้'
  } finally {
    isLoading.value = false
  }
}

async function submitChange() {
  if (!isFormValid.value) return

  isSubmitting.value = true

  try {
    const token =
      useCookie('token')?.value ||
      (process.client ? localStorage.getItem('token') : '')

    await $fetch(`/incidents/admin/${incidentId.value}`, {
      baseURL: config.public.apiBase,
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      },
      body: {
        status: nextStatus.value,
        resolution: resolutionNote.value,
      }
    })

    alert('บันทึกสำเร็จ')
    router.push('/admin/incidents')

  } catch (err) {
    console.error(err)
    alert(err?.data?.message || 'ไม่สามารถบันทึกได้')
  } finally {
    isSubmitting.value = false
  }
}

onMounted(() => {
  fetchIncidentDetail()
})
</script>