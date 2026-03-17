<template>
  <div class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <h1 class="text-2xl font-bold text-gray-800 mb-6">การชำระเงินของฉัน</h1>

      <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-200 mb-6 flex flex-wrap gap-4">
        <button
          @click="activeTab = 'PENDING'"
          :class="activeTab === 'PENDING' ? 'bg-blue-600 text-white border-blue-600' : 'bg-white text-gray-700 border-gray-300 hover:bg-gray-50'"
          class="px-6 py-2.5 rounded-md font-medium border transition-colors focus:outline-none"
        >
          ยังไม่ยืนยัน ({{ pendingCount }})
        </button>
        <button
          @click="activeTab = 'CONFIRMED'"
          :class="activeTab === 'CONFIRMED' ? 'bg-blue-600 text-white border-blue-600' : 'bg-white text-gray-700 border-gray-300 hover:bg-gray-50'"
          class="px-6 py-2.5 rounded-md font-medium border transition-colors focus:outline-none"
        >
          ยืนยันแล้ว ({{ confirmedCount }})
        </button>
        <button
          @click="activeTab = 'ALL'"
          :class="activeTab === 'ALL' ? 'bg-blue-600 text-white border-blue-600' : 'bg-white text-gray-700 border-gray-300 hover:bg-gray-50'"
          class="px-8 py-2.5 rounded-md font-medium border transition-colors focus:outline-none"
        >
          ทั้งหมด
        </button>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="lg:col-span-2 space-y-4">
          <div v-if="isLoading" class="bg-white rounded-xl border border-gray-200 p-8 text-center text-gray-500">
            กำลังโหลดข้อมูล...
          </div>

          <div v-else-if="errorMessage" class="bg-white rounded-xl border border-red-200 p-6 text-center text-red-600">
            {{ errorMessage }}
          </div>

          <div
            v-else
            v-for="payment in filteredPayments"
            :key="payment.bookingId"
            class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 flex flex-col sm:flex-row justify-between"
          >
            <div class="flex-1 pr-4">
              <h3 class="text-lg font-bold text-gray-900 flex items-center gap-2">
                {{ payment.from }}
                <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                </svg>
                {{ payment.to }}
              </h3>

              <p class="text-sm text-gray-500 mt-2">จุดนัดพบ: <span class="text-gray-700">{{ payment.meetpoint }}</span></p>
              <p class="text-sm text-gray-500 mt-1">
                วันที่: {{ payment.date }} <span class="mx-1">|</span>
                เวลา: {{ payment.time }} <span class="mx-1">|</span>
                ระยะเวลา: {{ payment.duration }} <span class="mx-1">|</span>
                ระยะทาง: {{ payment.distance }}
              </p>

              <p v-if="payment.status === 'DISPUTED' && payment.disputeReason" class="text-sm text-red-600 mt-3">
                เหตุผลที่ถูกปฏิเสธ: {{ payment.disputeReason }}
              </p>

              <div class="flex items-center mt-5">
                <div class="w-12 h-12 bg-purple-200 text-purple-700 rounded-full flex items-center justify-center font-bold text-lg mr-4 flex-shrink-0">
                  {{ payment.driverInitials }}
                </div>
                <div>
                  <p class="text-sm font-bold text-gray-900">{{ payment.driverName }}</p>
                </div>
              </div>
            </div>

            <div class="mt-6 sm:mt-0 sm:ml-4 flex flex-col justify-between items-start sm:items-end min-w-[180px]">
              <span v-if="payment.status === 'CONFIRMED'" class="px-4 py-1.5 rounded-full text-xs font-bold bg-green-100 text-emerald-700 self-end">
                ยืนยันแล้ว
              </span>
              <span v-else-if="payment.status === 'UNDER_REVIEW'" class="px-4 py-1.5 rounded-full text-xs font-bold bg-sky-100 text-sky-700 self-end">
                รอตรวจสอบ
              </span>
              <span v-else-if="payment.status === 'DISPUTED'" class="px-4 py-1.5 rounded-full text-xs font-bold bg-red-100 text-red-700 self-end">
                ถูกปฏิเสธ
              </span>
              <span v-else class="px-4 py-1.5 rounded-full text-xs font-bold bg-amber-100 text-amber-700 self-end">
                ยังไม่ยืนยัน
              </span>

              <div class="text-right mt-4 sm:mt-auto mb-3 w-full">
                <p class="text-2xl font-black text-blue-600 leading-none">{{ payment.price }} บาท</p>
                <p class="text-sm text-gray-500 mt-1">จำนวน {{ payment.seats }} ที่นั่ง</p>
              </div>

              <div class="w-full sm:w-auto h-9 flex items-end">
                <NuxtLink
                  v-if="payment.status === 'CONFIRMED' && payment.hasReceipt && payment.confirmationId"
                  :to="`/my-payments/document/${payment.confirmationId}`"
                  class="w-full sm:w-auto px-4 py-1.5 text-sm font-bold text-green-600 border border-green-500 rounded-md hover:bg-green-50 transition-colors text-center"
                >
                  ดาวน์โหลดเอกสาร
                </NuxtLink>

                <NuxtLink
                  v-if="payment.status === 'PENDING' || payment.status === 'DISPUTED'"
                  :to="`/my-payments/upload/${payment.bookingId}`"
                  class="w-full sm:w-auto px-6 py-1.5 text-sm font-bold text-red-500 border border-red-500 rounded-md hover:bg-red-50 transition-colors text-center"
                >
                  {{ payment.status === 'DISPUTED' ? 'ส่งหลักฐานใหม่' : 'แนบหลักฐาน' }}
                </NuxtLink>
              </div>
            </div>
          </div>

          <div v-if="!isLoading && !errorMessage && filteredPayments.length === 0" class="bg-white p-10 rounded-xl border border-gray-200 text-center text-gray-500">
            ไม่พบรายการในหมวดนี้
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
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

definePageMeta({ middleware: 'auth' })

const { $api } = useNuxtApp()

const activeTab = ref('PENDING')
const isLoading = ref(true)
const errorMessage = ref('')
const payments = ref([])

const pendingCount = computed(() => payments.value.filter(p => ['PENDING', 'UNDER_REVIEW', 'DISPUTED'].includes(p.status)).length)
const confirmedCount = computed(() => payments.value.filter(p => p.status === 'CONFIRMED').length)

const filteredPayments = computed(() => {
  if (activeTab.value === 'ALL') return payments.value
  if (activeTab.value === 'PENDING') {
    return payments.value.filter(p => ['PENDING', 'UNDER_REVIEW', 'DISPUTED'].includes(p.status))
  }
  return payments.value.filter(p => p.status === 'CONFIRMED')
})

const toUiStatus = (confirmation) => {
  const raw = confirmation?.status || 'UNPAID'
  if (raw === 'CONFIRMED') return 'CONFIRMED'
  if (raw === 'PROOF_SUBMITTED') return 'UNDER_REVIEW'
  if (raw === 'DISPUTED') return 'DISPUTED'
  return 'PENDING'
}

const loadPayments = async () => {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const [bookings, history] = await Promise.all([
      $api('/bookings/me'),
      $api('/payments/confirmations/history/me?scope=passenger&limit=100'),
    ])

    const confirmationMap = new Map((history || []).map(item => [item.bookingId, item]))

    payments.value = (bookings || [])
      .filter(b => ['CONFIRMED', 'COMPLETED'].includes(String(b.status || '').toUpperCase()))
      .map((b) => {
        const confirmation = confirmationMap.get(b.id) || null
        const driverFirstName = b.route?.driver?.firstName || ''
        const driverLastName = b.route?.driver?.lastName || ''
        const driverInitials = `${driverFirstName.charAt(0)}${driverLastName.charAt(0)}`.trim() || 'DR'

        return {
          bookingId: b.id,
          confirmationId: confirmation?.id || null,
          from: b.route?.startLocation?.name || 'Unknown',
          to: b.route?.endLocation?.name || 'Unknown',
          meetpoint: b.pickupLocation?.name || '-',
          date: b.route?.departureTime
            ? new Date(b.route.departureTime).toLocaleDateString('th-TH', { year: 'numeric', month: 'short', day: 'numeric' })
            : '-',
          time: b.route?.departureTime
            ? `${new Date(b.route.departureTime).toLocaleTimeString('th-TH', { hour: '2-digit', minute: '2-digit' })} น.`
            : '-',
          duration: b.route?.duration || '-',
          distance: b.route?.distanceMeters ? `${(b.route.distanceMeters / 1000).toFixed(1)} กม.` : '-',
          driverInitials: driverInitials.toUpperCase(),
          driverName: `${driverFirstName} ${driverLastName}`.trim() || 'Driver',
          status: toUiStatus(confirmation),
          disputeReason: confirmation?.disputeReason || null,
          hasReceipt: (confirmation?.documents || []).length > 0,
          price: (b.route?.pricePerSeat || 0) * (b.numberOfSeats || 1),
          seats: b.numberOfSeats || 1,
        }
      })
  } catch (error) {
    console.error('Error fetching payments:', error)
    errorMessage.value = error?.statusMessage || 'ไม่สามารถโหลดข้อมูลการชำระเงินได้'
  } finally {
    isLoading.value = false
  }
}

onMounted(loadPayments)
</script>
