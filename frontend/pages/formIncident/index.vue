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

        <!-- ระดับความเร่งด่วน -->
        <div class="mb-6">
          <label class="block mb-2 font-medium text-gray-700">
            ระดับความเร่งด่วน <span class="text-red-500">*</span>
          </label>

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-10">
            <button v-for="level in urgencyLevels" :key="level.value" @click="selectedUrgency = level.value"
              :class="getUrgencyClass(level.value)" class="border-2 rounded-xl py-3 font-medium transition">
              {{ level.label }}
            </button>
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

          <div @click="openMapPicker" class="border-2 border-dashed rounded-xl p-4 cursor-pointer transition" :class="location
            ? 'border-blue-500 bg-blue-50 text-gray-800'
            : 'border-gray-300 text-blue-600 hover:bg-blue-50'">
            <div v-if="!location" class="text-center">
              📍 เลือกตำแหน่งจากแผนที่
            </div>

            <div v-else class="flex justify-between items-center">
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
            แนบหลักฐาน (รูปภาพหรือวิดีโอ)
          </label>

          <div
            class="border-2 border-dashed border-gray-300 rounded-xl p-10 text-center hover:bg-gray-50 transition cursor-pointer"
            @click="triggerFileInput">
            <div class="text-4xl mb-3"></div>
            <p class="text-gray-600">คลิกเพื่ออัปโหลด หรือ ลากไฟล์มาวาง</p>
            <p class="text-sm text-gray-400 mt-1">JPG, PNG, MP4 (สูงสุด 10MB)</p>
          </div>

          <input ref="fileInput" type="file" class="hidden" multiple accept="image/*,video/mp4"
            @change="handleFileUpload" />

          <!-- Preview -->
          <div v-if="files.length" class="mt-4 grid grid-cols-2 md:grid-cols-3 gap-4">
            <div v-for="(file, index) in files" :key="index" class="relative border rounded-lg overflow-hidden">
              <img v-if="file.type.startsWith('image/')" :src="file.preview" class="w-full h-32 object-cover" />
              <video v-else :src="file.preview" class="w-full h-32 object-cover"></video>

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
            <button @click="closeMapPicker">✕</button>
          </div>

          <div ref="mapContainer" class="w-full h-[400px] rounded-xl"></div>

          <div class="flex justify-end mt-4">
            <button @click="confirmLocation" class="bg-blue-600 text-white px-6 py-3 rounded-xl">
              ยืนยันตำแหน่ง
            </button>
          </div>
        </div>
      </div>
    </div>
    <!-- SUCCESS MODAL -->
    <div v-if="isSuccessModalOpen" class="fixed inset-0 bg-black/40 flex items-center justify-center z-50">

      <div class="bg-white w-[90%] max-w-md rounded-2xl shadow-xl p-8 text-center">

        <div class="w-16 h-16 mx-auto rounded-full bg-green-100 flex items-center justify-center mb-4">
          <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
          </svg>
        </div>

        <h3 class="text-xl font-semibold text-gray-900 mb-2">
          ส่งข้อมูลเรียบร้อยแล้ว
        </h3>

        <p class="text-gray-500 mb-6">
          ทีมงานได้รับรายงานของคุณแล้ว หากต้องการสอบถามเพิ่มเติมสามารถติดต่อผ่านแชทได้ทันที
        </p>

        <div class="flex flex-col gap-3">

          <!-- Chat Button -->
          <button @click="goToAdminChat"
            class="bg-blue-600 hover:bg-blue-700 text-white py-3 rounded-xl font-medium transition">
            แชทกับ Admin
          </button>

          <!-- Close Button -->
          <button @click="isSuccessModalOpen = false"
            class="bg-gray-100 hover:bg-gray-200 text-gray-700 py-3 rounded-xl font-medium transition">
            ปิด
          </button>

        </div>

      </div>
    </div>

  </div>

</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { navigateTo, useRoute } from '#app'

const { $api } = useNuxtApp()
const route = useRoute()
const bookingId = route.query.bookingId || null
const isSubmitting = ref(false)

const fileInput = ref(null)
const files = ref([])
const location = ref(null)
const isMapOpen = ref(false)
const mapContainer = ref(null)
const locationName = ref('')
const isSuccessModalOpen = ref(false)

let gmap = null
let marker = null
let tempLocation = null

function goToAdminChat() {
  isSuccessModalOpen.value = false
  navigateTo('/chat/admin')
}

function openMapPicker() {
  isMapOpen.value = true
  nextTick(() => {
    initializeMap()
  })
}

function closeMapPicker() {
  isMapOpen.value = false
}

function initializeMap() {
  if (!window.google || !mapContainer.value) return

  const defaultCenter = { lat: 13.7563, lng: 100.5018 }

  gmap = new window.google.maps.Map(mapContainer.value, {
    center: defaultCenter,
    zoom: 12
  })

  gmap.addListener('click', (event) => {
    const lat = event.latLng.lat()
    const lng = event.latLng.lng()

    tempLocation = { lat, lng }

    if (marker) marker.setMap(null)

    marker = new window.google.maps.Marker({
      position: { lat, lng },
      map: gmap
    })
  })
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
    alert('กรุณาเลือกตำแหน่ง')
    return
  }

  location.value = tempLocation

  locationName.value = await reverseGeocode(
    tempLocation.lat,
    tempLocation.lng
  )

  closeMapPicker()
}

function getCurrentLocation() {
  if (!navigator.geolocation) {
    alert('เบราว์เซอร์ไม่รองรับการระบุตำแหน่ง')
    return
  }

  navigator.geolocation.getCurrentPosition(
    (position) => {
      location.value = {
        lat: position.coords.latitude,
        lng: position.coords.longitude
      }
    },
    (error) => {
      alert('ไม่สามารถดึงตำแหน่งได้')
      console.error(error)
    }
  )
}

function triggerFileInput() {
  fileInput.value.click()
}

function handleFileUpload(event) {
  const selectedFiles = Array.from(event.target.files)

  selectedFiles.forEach((file) => {
    if (file.size > 10 * 1024 * 1024) {
      alert('ไฟล์ต้องไม่เกิน 10MB')
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
  'อื่นๆ'
]

const urgencyLevels = [
  { label: 'ไม่เร่งด่วน', value: 'low' },
  { label: 'ปกติ', value: 'normal' },
  { label: 'เร่งด่วน', value: 'high' },
  { label: 'เร่งด่วนมาก', value: 'critical' }
]

const categoryToType = {
  'ปัญหาความปลอดภัย': 'SAFETY_CONCERN',
  'พฤติกรรมไม่เหมาะสม': 'INAPPROPRIATE_BEHAVIOR',
  'การล่วงละเมิด': 'HARASSMENT',
  'อุบัติเหตุ': 'ACCIDENT',
  'ปัญหารถยนต์': 'VEHICLE_ISSUE',
  'การฉ้อโกง': 'FRAUD',
  'ปัญหาเส้นทาง': 'ROUTE_ISSUE',
  'ข้อพิพาทการชำระเงิน': 'PAYMENT_DISPUTE',
  'อื่นๆ': 'OTHER',
}

const urgencyToPriority = {
  'low': 'LOW',
  'normal': 'NORMAL',
  'high': 'HIGH',
  'critical': 'URGENT',
}

const selectedCategory = ref('')
const selectedUrgency = ref('')
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

function getUrgencyClass(value) {
  const base = 'border-gray-300 hover:border-gray-400'

  if (selectedUrgency.value === value) {
    if (value === 'low' || value === 'normal')
      return 'border-green-600 bg-green-600 text-white'
    if (value === 'high')
      return 'border-orange-500 bg-orange-500 text-white'
    if (value === 'critical')
      return 'border-red-600 bg-red-600 text-white'
  }

  if (value === 'low' || value === 'normal')
    return `${base} hover:border-green-600`
  if (value === 'high')
    return `${base} hover:border-orange-500`
  if (value === 'critical')
    return `${base} hover:border-red-600`

  return base
}

async function handleSubmit() {
  if (!selectedCategory.value || !selectedUrgency.value || !title.value || !description.value) {
    alert('กรุณากรอกข้อมูลให้ครบถ้วน')
    return
  }

  isSubmitting.value = true

  try {
    const formData = new FormData()
    formData.append('type', categoryToType[selectedCategory.value])
    formData.append('priority', urgencyToPriority[selectedUrgency.value])
    formData.append('title', title.value)
    formData.append('description', description.value)

    if (bookingId) formData.append('bookingId', bookingId)
    if (location.value) formData.append('location', JSON.stringify(location.value))

    // Append evidence files
    files.value.forEach((f) => {
      formData.append('evidences', f.file)
    })

    await $api('/incidents', {
      method: 'POST',
      body: formData,
    })

    isSuccessModalOpen.value = true
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
