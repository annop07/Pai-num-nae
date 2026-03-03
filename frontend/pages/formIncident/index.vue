<template>
  <div class="min-h-screen bg-gray-50">
    <div class="w-full px-8 py-12">
      <div class="w-full bg-white rounded-2xl shadow-sm border border-gray-200 p-12">

        <!-- Header -->
        <div class="text-center mb-8">
          <div class="w-16 h-16 mx-auto rounded-full bg-gray-100 flex items-center justify-center mb-4">
            <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 3l7 4v5c0 5-3.5 9-7 9s-7-4-7-9V7l7-4z" />
            </svg>
          </div>

          <h1 class="text-3xl font-bold text-gray-900">แจ้งเหตุการณ์</h1>
          <p class="text-gray-500 mt-2">
            ระบบรับแจ้งเรื่องร้องเรียนและเหตุการณ์ฉุกเฉิน กรุณากรอกข้อมูลให้ครบถ้วนเพื่อความรวดเร็วในการดำเนินการ
          </p>
        </div>

        <!-- ประเภทปัญหา -->
        <div class="mb-6 relative" ref="dropdownRef">
          <label class="block mb-2 font-medium text-gray-700">
            ประเภทปัญหา <span class="text-red-500">*</span>
          </label>

          <div @click="toggleDropdown"
            class="w-full px-4 py-3 border border-gray-300 rounded-xl cursor-pointer flex justify-between items-center hover:border-blue-500 transition">
            <span class="text-gray-700">
              {{ selectedCategory || 'เลือกประเภทปัญหา' }}
            </span>
            <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
            </svg>
          </div>

          <div v-if="isDropdownOpen"
            class="absolute w-full bg-white border border-gray-200 rounded-xl shadow-lg mt-2 z-20 overflow-hidden">
            <div v-for="item in categories" :key="item" @click="selectCategory(item)"
              class="px-4 py-3 hover:bg-blue-50 cursor-pointer transition">
              {{ item }}
            </div>
          </div>
        </div>

        <!-- ระดับความเร่งด่วน (แสดงอัตโนมัติตามประเภทปัญหา) -->
        <div v-if="selectedCategory" class="mb-6">
          <label class="block mb-2 font-medium text-gray-700">ระดับความเร่งด่วน</label>
          <div class="flex items-center gap-3 px-4 py-3 rounded-xl border"
            :class="autoPriorityStyle.border">
            <span class="w-2.5 h-2.5 rounded-full flex-shrink-0" :class="autoPriorityStyle.dot"></span>
            <span class="font-semibold" :class="autoPriorityStyle.text">{{ autoPriorityLabel }}</span>
            <span class="text-sm text-gray-400 ml-1">— กำหนดอัตโนมัติตามประเภทปัญหาที่เลือก</span>
          </div>
        </div>

        <!-- หัวข้อ -->
        <div class="mb-6">
          <label class="block mb-2 font-medium text-gray-700">
            หัวข้อ <span class="text-red-500">*</span>
          </label>

          <input v-model="title" maxlength="100" type="text" placeholder="เช่น รถเสียกลางทาง"
            class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition" />

          <div class="flex justify-between text-sm text-gray-400 mt-1">
            <span>ไม่เกิน 100 ตัวอักษร</span>
            <span>{{ title.length }}/100</span>
          </div>
        </div>

        <!-- รายละเอียด -->
        <div class="mb-6">
          <label class="block mb-2 font-medium text-gray-700">
            รายละเอียด <span class="text-red-500">*</span>
          </label>

          <textarea v-model="description" rows="5" placeholder="โปรดอธิบายเหตุการณ์ที่เกิดขึ้นอย่างละเอียด"
            class="w-full px-4 py-3 border border-gray-300 rounded-xl resize-none focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition" />
        </div>

        <!-- สถานที่ -->
        <div>
          <label class="block mb-2 font-semibold text-gray-700">
            สถานที่เกิดเหตุ
          </label>

          <div
            class="border-2 border-dashed rounded-xl p-4 cursor-pointer transition"
            :class="location
              ? 'border-blue-500 bg-blue-50 text-gray-800'
              : 'border-gray-300 text-blue-600 hover:bg-blue-50'">
            <div v-if="!location" class="text-center">
              <button
                type="button"
                @click="getCurrentLocation"
                :disabled="getLocationLoading"
                class="inline-flex items-center gap-2 text-blue-600 hover:text-blue-700 disabled:opacity-60 disabled:cursor-not-allowed">
                <svg v-if="getLocationLoading" class="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                  <path class="opacity-75" fill="currentColor"
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                </svg>
                <span v-else>📍</span>
                {{ getLocationLoading ? 'กำลังรับตำแหน่ง...' : 'รับตำแหน่งปัจจุบัน' }}
              </button>
              <span class="text-gray-400 mx-1">หรือ</span>
              <button type="button" @click.stop="openMapPicker"
                class="text-blue-600 hover:text-blue-700 underline">
                เลือกตำแหน่งจากแผนที่
              </button>
            </div>

            <div v-else @click="openMapPicker" class="flex justify-between items-center">
              <span class="truncate">
                {{ locationName }}
              </span>
              <span class="text-sm text-blue-600">เปลี่ยนตำแหน่ง</span>
            </div>
          </div>
        </div>

        <!-- แนบไฟล์ -->
        <div>
          <label class="block mb-2 font-semibold text-gray-700 mt-6">
            แนบหลักฐาน (รูปภาพ, วิดีโอ หรือ PDF)
          </label>

          <div
            class="border-2 border-dashed border-gray-300 rounded-xl p-10 text-center hover:bg-gray-50 transition cursor-pointer"
            @click="triggerFileInput">
            <div class="text-4xl mb-3"></div>
            <p class="text-gray-600">คลิกเพื่ออัปโหลด หรือ ลากไฟล์มาวาง</p>
            <p class="text-sm text-gray-400 mt-1">JPG, PNG, MP4, MOV, PDF (สูงสุด 50MB)</p>
          </div>

          <input ref="fileInput" type="file" class="hidden" multiple accept="image/*,video/mp4,video/quicktime,application/pdf"
            @change="handleFileUpload" />

          <!-- Preview -->
          <div v-if="files.length" class="mt-4 grid grid-cols-2 md:grid-cols-3 gap-4">
            <div v-for="(file, index) in files" :key="index" class="relative border rounded-lg overflow-hidden">
              <img v-if="file.type.startsWith('image/')" :src="file.preview" class="w-full h-32 object-cover" />
              <video v-else-if="file.type.startsWith('video/')" :src="file.preview" class="w-full h-32 object-cover"></video>
              <div v-else class="w-full h-32 flex flex-col items-center justify-center bg-red-50">
                <span class="text-3xl">📄</span>
                <span class="text-xs text-red-600 font-medium mt-1 px-2 truncate w-full text-center">{{ file.file.name }}</span>
              </div>

              <button @click="removeFile(index)"
                class="absolute top-1 right-1 bg-red-600 text-white text-xs px-2 py-1 rounded">
                ✕
              </button>
            </div>
          </div>
        </div>


        <!-- ปุ่มรายงาน -->
        <div class="flex justify-end mt-10">
          <button @click="handleSubmit" :disabled="isSubmitting"
            class="bg-blue-600 hover:bg-blue-700 text-white px-12 py-4 rounded-xl text-lg font-semibold shadow-md transition disabled:opacity-50 disabled:cursor-not-allowed">
            {{ isSubmitting ? 'กำลังส่ง...' : 'รายงานเหตุการณ์' }}
          </button>
        </div>

      </div>
      <!-- MAP PICKER MODAL -->
      <div v-if="isMapOpen" class="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
        <div class="bg-white w-[90%] max-w-4xl rounded-2xl shadow-xl p-6">

          <div class="flex justify-between items-center mb-4">
            <h3 class="text-lg font-semibold">เลือกตำแหน่ง</h3>
            <button @click="closeMapPicker" class="text-gray-400 hover:text-gray-600 text-xl">✕</button>
          </div>

          <!-- Search Box -->
          <div class="relative mb-3">
            <div class="absolute inset-y-0 left-3 flex items-center pointer-events-none">
              <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35M17 11A6 6 0 1 1 5 11a6 6 0 0 1 12 0z" />
              </svg>
            </div>
            <input
              ref="searchInput"
              type="text"
              placeholder="ค้นหาสถานที่... เช่น สยามพารากอน, มหาวิทยาลัยเกษตรศาสตร์"
              class="w-full pl-9 pr-4 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          <!-- Selected place name preview -->
          <div v-if="tempLocationName" class="mb-3 px-3 py-2 bg-blue-50 border border-blue-200 rounded-xl text-sm text-blue-700 flex items-center gap-2">
            <span>📍</span>
            <span class="truncate">{{ tempLocationName }}</span>
          </div>

          <div ref="mapContainer" class="w-full h-[380px] rounded-xl"></div>

          <p class="text-xs text-gray-400 mt-2">คลิกบนแผนที่หรือค้นหาชื่อสถานที่เพื่อเลือกตำแหน่ง</p>

          <div class="flex justify-end mt-4">
            <button @click="confirmLocation" class="bg-blue-600 text-white px-6 py-3 rounded-xl font-medium hover:bg-blue-700 transition">
              ยืนยันตำแหน่ง
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Success Overlay (เหมือน Admin - เครื่องหมายถูก + พื้นหลังเบลอ) -->
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

  </div>

</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { useRoute, navigateTo } from '#app'

const { $api } = useNuxtApp()
const route = useRoute()
const bookingId = route.query.bookingId || null
const isSubmitting = ref(false)

const fileInput = ref(null)
const files = ref([])
const location = ref(null)
const isMapOpen = ref(false)
const mapContainer = ref(null)
const searchInput = ref(null)
const locationName = ref('')
const tempLocationName = ref('')
const getLocationLoading = ref(false)
const showSuccess = ref(false)
const lastCreatedIncident = ref(null)

function triggerSuccess() {
  showSuccess.value = true
  setTimeout(() => {
    showSuccess.value = false
    navigateTo('/myIncidents')
  }, 2000)
}

let gmap = null
let marker = null
let tempLocation = null
let autocomplete = null

function openMapPicker() {
  tempLocationName.value = locationName.value || ''
  tempLocation = location.value ? { ...location.value } : null
  isMapOpen.value = true
  nextTick(() => {
    initializeMap()
    // ถ้ามีตำแหน่งเดิม ให้วาง marker ไว้ก่อน
    if (tempLocation) {
      placeMarker(tempLocation.lat, tempLocation.lng)
      gmap?.panTo(tempLocation)
      gmap?.setZoom(16)
    }
  })
}

function closeMapPicker() {
  isMapOpen.value = false
  autocomplete = null
}

function placeMarker(lat, lng) {
  if (marker) marker.setMap(null)
  marker = new window.google.maps.Marker({
    position: { lat, lng },
    map: gmap,
    animation: window.google.maps.Animation.DROP,
  })
  tempLocation = { lat, lng }
}

function initializeMap() {
  if (!window.google || !mapContainer.value) return

  const defaultCenter = { lat: 13.7563, lng: 100.5018 }

  gmap = new window.google.maps.Map(mapContainer.value, {
    center: defaultCenter,
    zoom: 12,
  })

  // คลิกบนแผนที่ → วาง marker + reverse geocode realtime
  gmap.addListener('click', async (event) => {
    const lat = event.latLng.lat()
    const lng = event.latLng.lng()
    placeMarker(lat, lng)
    tempLocationName.value = 'กำลังโหลดชื่อสถานที่...'
    tempLocationName.value = await reverseGeocode(lat, lng)
  })

  // Google Places Autocomplete
  if (searchInput.value && window.google.maps.places) {
    autocomplete = new window.google.maps.places.Autocomplete(searchInput.value, {
      fields: ['geometry', 'formatted_address', 'name'],
    })

    autocomplete.addListener('place_changed', () => {
      const place = autocomplete.getPlace()
      if (!place.geometry?.location) return

      const lat = place.geometry.location.lat()
      const lng = place.geometry.location.lng()

      gmap.panTo({ lat, lng })
      gmap.setZoom(16)
      placeMarker(lat, lng)
      tempLocationName.value = place.formatted_address || place.name || ''
    })
  }
}

async function reverseGeocode(lat, lng) {
  return new Promise((resolve) => {
    const geocoder = new google.maps.Geocoder()

    geocoder.geocode(
      { location: { lat, lng } },
      (results, status) => {
        if (status === 'OK' && results[0]) {
          resolve(results[0].formatted_address)
        } else {
          resolve('ไม่พบชื่อสถานที่')
        }
      }
    )
  })
}

async function confirmLocation() {
  if (!tempLocation) {
    alert('กรุณาเลือกตำแหน่งบนแผนที่หรือค้นหาชื่อสถานที่')
    return
  }

  location.value = { ...tempLocation }
  locationName.value = tempLocationName.value || await reverseGeocode(tempLocation.lat, tempLocation.lng)

  closeMapPicker()
}

async function getCurrentLocation() {
  if (!navigator.geolocation) {
    alert('เบราว์เซอร์ไม่รองรับการระบุตำแหน่ง')
    return
  }

  getLocationLoading.value = true
  navigator.geolocation.getCurrentPosition(
    async (position) => {
      const lat = position.coords.latitude
      const lng = position.coords.longitude

      location.value = { lat, lng }

      // ดึงชื่อสถานที่จาก Nominatim (เหมือนระบบ Chat)
      try {
        const res = await fetch(
          `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&accept-language=th`,
          { headers: { Accept: 'application/json' } }
        )
        const data = await res.json()
        locationName.value = data?.display_name || 'ตำแหน่งปัจจุบัน'
      } catch {
        locationName.value = 'ตำแหน่งปัจจุบัน'
      } finally {
        getLocationLoading.value = false
      }
    },
    (error) => {
      getLocationLoading.value = false
      if (error.code === 1) {
        alert('คุณไม่อนุญาตให้เข้าถึงตำแหน่ง กรุณาเปิดสิทธิ์ในเบราว์เซอร์')
      } else if (error.code === 2) {
        alert('ไม่สามารถระบุตำแหน่งได้ กรุณาลองใหม่')
      } else if (error.code === 3) {
        alert('การรอตำแหน่งใช้เวลานานเกินไป')
      } else {
        alert('เกิดข้อผิดพลาดในการรับตำแหน่ง')
      }
    },
    { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
  )
}

function triggerFileInput() {
  fileInput.value.click()
}

function handleFileUpload(event) {
  const selectedFiles = Array.from(event.target.files)

  selectedFiles.forEach((file) => {
    if (file.size > 50 * 1024 * 1024) {
      alert('ไฟล์ต้องไม่เกิน 50MB')
      return
    }

    const reader = new FileReader()
    reader.onload = (e) => {
      files.value.push({
        file,
        preview: e.target.result,
        type: file.type
      })
    }
    reader.readAsDataURL(file)
  })

  event.target.value = ''
}

function removeFile(index) {
  files.value.splice(index, 1)
}

const categories = [
  'ปัญหาความปลอดภัย',
  'พฤติกรรมไม่เหมาะสม',
  'การล่วงละเมิด',
  'อุบัติเหตุ',
  'ปัญหารถยนต์',
  'การฉ้อโกง',
  'ปัญหาเส้นทาง',
  'ข้อพิพาทการชำระเงิน',
  'ลืมของ',
  'คนขับไม่มาตามจุดนัด',
  'ผู้โดยสารไม่มา',
  'ป้ายทะเบียนรถไม่ตรง',
  'อื่นๆ',
]

const categoryToType = {
  'ปัญหาความปลอดภัย':      'SAFETY_CONCERN',
  'พฤติกรรมไม่เหมาะสม':   'INAPPROPRIATE_BEHAVIOR',
  'การล่วงละเมิด':          'HARASSMENT',
  'อุบัติเหตุ':             'ACCIDENT',
  'ปัญหารถยนต์':           'VEHICLE_ISSUE',
  'การฉ้อโกง':             'FRAUD',
  'ปัญหาเส้นทาง':          'ROUTE_ISSUE',
  'ข้อพิพาทการชำระเงิน':  'PAYMENT_DISPUTE',
  'ลืมของ':                'LOST_ITEM',
  'คนขับไม่มาตามจุดนัด':   'NO_SHOW_DRIVER',
  'ผู้โดยสารไม่มา':        'NO_SHOW_PASSENGER',
  'ป้ายทะเบียนรถไม่ตรง':  'LICENSE_PLATE_MISMATCH',
  'อื่นๆ':                 'OTHER',
}

// Priority กำหนดอัตโนมัติตามประเภทปัญหา (3 ระดับ: LOW / NORMAL / HIGH)
const categoryToPriority = {
  'ปัญหาความปลอดภัย':     'HIGH',
  'พฤติกรรมไม่เหมาะสม':  'LOW',
  'การล่วงละเมิด':         'HIGH',
  'อุบัติเหตุ':            'HIGH',
  'ปัญหารถยนต์':          'NORMAL',
  'การฉ้อโกง':            'HIGH',
  'ปัญหาเส้นทาง':         'LOW',
  'ข้อพิพาทการชำระเงิน': 'NORMAL',
  'ลืมของ':               'NORMAL',
  'คนขับไม่มาตามจุดนัด':  'NORMAL',
  'ผู้โดยสารไม่มา':       'LOW',
  'ป้ายทะเบียนรถไม่ตรง': 'NORMAL',
  'อื่นๆ':                'LOW',
}

const PRIORITY_DISPLAY = {
  LOW:    { label: 'ไม่เร่งด่วน', dot: 'bg-green-500',  text: 'text-green-700',  border: 'border-green-200 bg-green-50' },
  NORMAL: { label: 'ปกติ',        dot: 'bg-blue-500',   text: 'text-blue-700',   border: 'border-blue-200 bg-blue-50' },
  HIGH:   { label: 'เร่งด่วน',    dot: 'bg-orange-500', text: 'text-orange-700', border: 'border-orange-200 bg-orange-50' },
}

const autoPriority = computed(() => categoryToPriority[selectedCategory.value] || 'NORMAL')
const autoPriorityLabel = computed(() => PRIORITY_DISPLAY[autoPriority.value]?.label || '')
const autoPriorityStyle = computed(() => PRIORITY_DISPLAY[autoPriority.value] || PRIORITY_DISPLAY.NORMAL)

const selectedCategory = ref('')
const title = ref('')
const description = ref('')
const isDropdownOpen = ref(false)
const dropdownRef = ref(null)

function toggleDropdown() {
  isDropdownOpen.value = !isDropdownOpen.value
}

function selectCategory(item) {
  selectedCategory.value = item
  isDropdownOpen.value = false
}


async function handleSubmit() {
  if (!selectedCategory.value || !title.value || !description.value) {
    alert('กรุณากรอกข้อมูลให้ครบถ้วน')
    return
  }

  isSubmitting.value = true

  try {
    const formData = new FormData()
    formData.append('type', categoryToType[selectedCategory.value])
    formData.append('priority', autoPriority.value)
    formData.append('title', title.value)
    formData.append('description', description.value)

    if (bookingId) formData.append('bookingId', bookingId)
    if (location.value) formData.append('location', JSON.stringify(location.value))

    // Append evidence files
    files.value.forEach((f) => {
      formData.append('evidences', f.file)
    })

    const res = await $api('/incidents', {
      method: 'POST',
      body: formData,
    })

    lastCreatedIncident.value = res || null
    triggerSuccess()
  } catch (err) {
    alert(err?.statusMessage || 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง')
  } finally {
    isSubmitting.value = false
  }
}

function handleClickOutside(event) {
  if (dropdownRef.value && !dropdownRef.value.contains(event.target)) {
    isDropdownOpen.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
/* Success Overlay (เหมือน Admin incidents) */
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
</style>
