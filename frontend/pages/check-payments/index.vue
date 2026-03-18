<template>
  <div class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <h1 class="text-2xl font-bold text-gray-800 mb-6">ตรวจสอบการชำระเงิน</h1>

      <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-200 mb-6 flex flex-wrap gap-4">
        <button class="bg-blue-600 text-white border-blue-600 px-6 py-2.5 rounded-md font-medium border">
          การเดินทางของฉัน
        </button>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="lg:col-span-2 space-y-4">
          <div v-if="isLoading" class="p-12 text-center text-gray-500 bg-white rounded-xl border border-gray-200">กำลังโหลดข้อมูล...</div>
          <div v-else-if="errorMessage" class="p-8 text-center text-red-600 bg-white rounded-xl border border-red-200">{{ errorMessage }}</div>
          <div v-else-if="myRoutes.length === 0" class="p-12 text-center text-gray-500 bg-white rounded-xl border border-gray-200">ยังไม่มีรายการเดินทาง</div>

          <div v-else v-for="route in myRoutes" :key="route.id" class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 flex flex-col sm:flex-row justify-between">
            <div class="flex-1 pr-4">
              <h3 class="text-lg font-bold text-gray-900 flex items-center gap-2">
                {{ route.from }}
                <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                </svg>
                {{ route.to }}
              </h3>
              <p class="text-sm text-gray-500 mt-2">
                วันที่: {{ route.date }} <span class="mx-1">|</span>
                เวลา: {{ route.time }} <span class="mx-1">|</span>
                ระยะเวลา: {{ route.duration }} <span class="mx-1">|</span>
                ระยะทาง: {{ route.distance }}
              </p>
              <p class="text-sm text-gray-500 mt-1">
                ที่นั่งว่าง: {{ route.availableSeats }} <span class="mx-1">|</span>
                ราคา/ที่นั่ง: {{ route.price }} บาท
              </p>
            </div>

            <div class="mt-6 sm:mt-0 sm:ml-4 flex flex-col justify-between items-start sm:items-end min-w-[120px]">
              <span class="px-4 py-1.5 rounded-full text-xs font-bold bg-green-100 text-green-700 self-end mb-4">เปิดรับผู้โดยสาร</span>
              <button
                @click="openPassengerModal(route)"
                class="w-full sm:w-auto px-6 py-2 text-sm font-bold text-white bg-emerald-500 rounded-md hover:bg-emerald-600"
              >
                ตรวจสอบ
              </button>
            </div>
          </div>
        </div>

        <div class="lg:col-span-1">
          <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden sticky top-24">
            <div class="p-5 border-b border-gray-200">
              <h3 class="font-bold text-gray-900 text-lg">แผนที่เส้นทาง</h3>
            </div>
            <div class="w-full h-[500px] bg-gray-100">
              <iframe
                width="100%"
                height="100%"
                frameborder="0"
                style="border:0"
                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3949.46740660233!2d102.82294157502263!3d16.444738484285854!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x31222a2bb5356ec3%3A0xe5f9b1fe658fbff3!2sKhon%20Kaen%20University!5e0!3m2!1sen!2sth!4v1700000000000!5m2!1sen!2sth"
                allowfullscreen
                loading="lazy"
              />
            </div>
          </div>
        </div>
      </div>
    </div>

    <div
      v-if="showPassengerModal"
      class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/40 backdrop-blur-sm"
      @click.self="closePassengerModal"
    >
      <div class="bg-white rounded-2xl shadow-xl w-full max-w-4xl overflow-hidden">
        <div class="p-6">
          <h2 class="text-xl font-bold text-gray-900 mb-6">ผู้โดยสารทั้งหมด</h2>

          <div class="space-y-4 max-h-[60vh] overflow-y-auto pr-2">
            <div v-if="selectedRoutePassengers.length === 0" class="text-center py-8 text-gray-500">
              ไม่มีผู้โดยสารในเส้นทางนี้
            </div>

            <div
              v-for="passenger in selectedRoutePassengers"
              :key="passenger.bookingId"
              class="flex flex-col sm:flex-row items-center p-4 bg-gray-50 rounded-xl border border-gray-100"
            >
              <div class="flex items-center flex-1 w-full mb-4 sm:mb-0">
                <div class="w-12 h-12 bg-indigo-200 text-indigo-700 rounded-full flex items-center justify-center font-bold text-lg mr-4 flex-shrink-0">
                  {{ passenger.initials }}
                </div>
                <div class="flex-1 min-w-0 pr-4">
                  <h4 class="font-bold text-gray-900 truncate">{{ passenger.name }}</h4>
                  <p class="text-xs text-gray-500 truncate mb-1">อีเมล: <span class="text-blue-600">{{ passenger.email }}</span></p>
                  <p class="text-xs text-gray-500">
                    สถานะ: <span class="font-semibold">{{ statusText(passenger.status) }}</span>
                  </p>
                </div>
              </div>

              <div class="flex items-center gap-3 w-full sm:w-auto justify-between sm:justify-end">
                <span v-if="passenger.status === 'CONFIRMED'" class="px-3 py-1 bg-green-100 text-green-700 text-xs font-bold rounded-full w-24 text-center">ยืนยันแล้ว</span>
                <span v-else-if="passenger.status === 'PENDING_REVIEW'" class="px-3 py-1 bg-yellow-100 text-yellow-700 text-xs font-bold rounded-full w-24 text-center">รอตรวจ</span>
                <span v-else-if="passenger.status === 'DISPUTED'" class="px-3 py-1 bg-red-100 text-red-700 text-xs font-bold rounded-full w-24 text-center">ปฏิเสธ</span>
                <span v-else class="px-3 py-1 bg-gray-100 text-gray-600 text-xs font-bold rounded-full w-24 text-center">รอหลักฐาน</span>

                <NuxtLink
                  v-if="passenger.confirmationId"
                  :to="`/check-payments/verify/${passenger.confirmationId}`"
                  class="px-4 py-1.5 border-2 border-emerald-500 text-emerald-600 hover:bg-emerald-50 rounded-full text-sm font-bold text-center"
                >
                  ตรวจสอบการชำระเงิน
                </NuxtLink>
                <button
                  v-else
                  class="px-4 py-1.5 border-2 border-gray-300 text-gray-400 rounded-full text-sm font-bold cursor-not-allowed"
                  disabled
                >
                  รอผู้โดยสารส่งหลักฐาน
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

definePageMeta({ middleware: 'auth' })

const { $api } = useNuxtApp()

const isLoading = ref(true)
const errorMessage = ref('')
const myRoutes = ref([])
const showPassengerModal = ref(false)
const selectedRoutePassengers = ref([])

const statusText = (status) => {
  if (status === 'CONFIRMED') return 'ยืนยันแล้ว'
  if (status === 'PENDING_REVIEW') return 'รอตรวจสอบ'
  if (status === 'DISPUTED') return 'ถูกปฏิเสธ'
  return 'รอส่งหลักฐาน'
}

const openPassengerModal = (route) => {
  selectedRoutePassengers.value = route.passengers || []
  showPassengerModal.value = true
}

const closePassengerModal = () => {
  showPassengerModal.value = false
}

onMounted(async () => {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const [routes, paymentHistory] = await Promise.all([
      $api('/routes/me'),
      $api('/payments/confirmations/history/me?scope=driver&limit=100'),
    ])

    const confirmationByBookingId = new Map((paymentHistory || []).map(item => [item.bookingId, item]))
    const allowedRouteStatuses = new Set(['AVAILABLE', 'FULL', 'IN_TRANSIT', 'COMPLETED'])

    myRoutes.value = (routes || [])
      .filter(r => allowedRouteStatuses.has(String(r.status || '').toUpperCase()))
      .map((r) => {
        const activeBookings = (r.bookings || []).filter(b => !['CANCELLED', 'REJECTED'].includes(String(b.status || '').toUpperCase()))

        const passengers = activeBookings.map((b) => {
          const confirmation = confirmationByBookingId.get(b.id)
          const latestStatus = confirmation?.status || 'UNPAID'

          let status = 'WAITING_PROOF'
          if (latestStatus === 'PROOF_SUBMITTED') status = 'PENDING_REVIEW'
          if (latestStatus === 'DISPUTED') status = 'DISPUTED'
          if (latestStatus === 'CONFIRMED') status = 'CONFIRMED'

          const firstName = b.passenger?.firstName || 'P'
          const lastName = b.passenger?.lastName || ''

          return {
            bookingId: b.id,
            confirmationId: confirmation?.id || null,
            initials: `${firstName.charAt(0)}${lastName.charAt(0)}`.toUpperCase() || 'PA',
            name: `${firstName} ${lastName}`.trim() || 'Passenger',
            email: b.passenger?.email || '-',
            status,
          }
        })

        return {
          id: r.id,
          from: r.startLocation?.name || 'ต้นทาง',
          to: r.endLocation?.name || 'ปลายทาง',
          date: r.departureTime ? new Date(r.departureTime).toLocaleDateString('th-TH', { year: 'numeric', month: 'short', day: 'numeric' }) : '-',
          time: r.departureTime ? `${new Date(r.departureTime).toLocaleTimeString('th-TH', { hour: '2-digit', minute: '2-digit' })} น.` : '-',
          duration: r.durationSeconds ? `${Math.round(r.durationSeconds / 60)} นาที` : '-',
          distance: r.distanceMeters ? `${(r.distanceMeters / 1000).toFixed(1)} กม.` : '-',
          availableSeats: r.availableSeats ?? 0,
          price: r.pricePerSeat || 0,
          passengers,
        }
      })
  } catch (error) {
    console.error('Failed to load routes/payments:', error)
    errorMessage.value = error?.statusMessage || 'ไม่สามารถโหลดข้อมูลการตรวจสอบการชำระเงินได้'
  } finally {
    isLoading.value = false
  }
})
</script>
