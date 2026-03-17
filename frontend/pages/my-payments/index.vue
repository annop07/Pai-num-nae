<template>
    <div class="min-h-screen bg-gray-50 py-8">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <h1 class="text-2xl font-bold text-gray-800 mb-6">การชำระเงินของฉัน</h1>

            <!-- Tabs -->
            <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-200 mb-6 flex flex-wrap gap-4">
                <button @click="activeTab = 'PENDING'" 
                    :class="activeTab === 'PENDING' ? 'bg-blue-600 text-white border-blue-600' : 'bg-white text-gray-700 border-gray-300 hover:bg-gray-50'" 
                    class="px-6 py-2.5 rounded-md font-medium border transition-colors focus:outline-none">
                    ยังไม่ยืนยัน({{ pendingCount }})
                </button>
                <button @click="activeTab = 'CONFIRMED'" 
                    :class="activeTab === 'CONFIRMED' ? 'bg-blue-600 text-white border-blue-600' : 'bg-white text-gray-700 border-gray-300 hover:bg-gray-50'" 
                    class="px-6 py-2.5 rounded-md font-medium border transition-colors focus:outline-none">
                    ยืนยันแล้ว({{ confirmedCount }})
                </button>
                <button @click="activeTab = 'ALL'" 
                    :class="activeTab === 'ALL' ? 'bg-blue-600 text-white border-blue-600' : 'bg-white text-gray-700 border-gray-300 hover:bg-gray-50'" 
                    class="px-8 py-2.5 rounded-md font-medium border transition-colors focus:outline-none w-full sm:w-auto">
                    ทั้งหมด
                </button>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Left column: Payment List -->
                <div class="lg:col-span-2 space-y-4">
                    <div v-for="payment in filteredPayments" :key="payment.id" class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 flex flex-col sm:flex-row justify-between relative transition-all duration-200 hover:shadow-md">
                        <div class="flex-1 pr-4">
                            <h3 class="text-lg font-bold text-gray-900 flex items-center gap-2">
                                {{ payment.from }} 
                                <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path></svg> 
                                {{ payment.to }}
                            </h3>
                            <p class="text-sm text-gray-500 mt-2">จุดนัดพบ: <span class="text-gray-700">{{ payment.meetpoint }}</span></p>
                            <p class="text-sm text-gray-500 mt-1">
                                วันที่: {{ payment.date }} <span class="mx-1">|</span> 
                                เวลา: {{ payment.time }} <span class="mx-1">|</span> 
                                ระยะเวลา: {{ payment.duration }} <span class="mx-1">|</span> 
                                ระยะทาง: {{ payment.distance }}
                            </p>

                            <div class="flex items-center mt-5">
                                <div class="w-12 h-12 bg-purple-200 text-purple-700 rounded-full flex items-center justify-center font-bold text-lg mr-4 flex-shrink-0">
                                    {{ payment.driverInitials }}
                                </div>
                                <div>
                                    <p class="text-sm font-bold text-gray-900">{{ payment.driverName }}</p>
                                    <div class="flex items-center text-xs mt-0.5">
                                        <div class="flex text-yellow-500 mr-1">
                                            <svg v-for="i in 5" :key="i" class="w-3.5 h-3.5 fill-current" viewBox="0 0 20 20">
                                                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                                            </svg>
                                        </div>
                                        <span class="text-gray-500">{{ payment.rating }} ({{ payment.reviews }} รีวิว)</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Status and Action -->
                        <div class="mt-6 sm:mt-0 sm:ml-4 flex flex-col justify-between items-start sm:items-end min-w-[120px]">
                            <span v-if="payment.status === 'CONFIRMED'" class="px-4 py-1.5 rounded-full text-xs font-bold bg-green-100 text-emerald-600 self-end">
                                ยืนยันแล้ว
                            </span>
                            <span v-else-if="payment.status === 'PENDING'" class="px-4 py-1.5 rounded-full text-xs font-bold bg-amber-100 text-amber-700 self-end">
                                ยังไม่ยืนยัน
                            </span>

                            <div class="text-right mt-4 sm:mt-auto mb-3 w-full flex flex-row items-end justify-between sm:flex-col sm:justify-start">
                                <span class="sm:hidden text-gray-500 text-sm font-medium">ค่าโดยสาร</span>
                                <div class="text-right">
                                    <p class="text-2xl font-black text-blue-600 leading-none">{{ payment.price }} บาท</p>
                                    <p class="text-sm text-gray-500 mt-1">จำนวน {{ payment.seats }} ที่นั่ง</p>
                                </div>
                            </div>

                            <div class="w-full sm:w-auto h-9 flex items-end">
                                <button v-if="payment.status === 'CONFIRMED' && payment.hasReceipt" 
                                    class="w-full sm:w-auto px-4 py-1.5 text-sm font-bold text-green-600 border border-green-500 rounded-md hover:bg-green-50 transition-colors focus:ring-2 focus:ring-green-200">
                                    ดาวน์โหลดใบเสร็จ
                                </button>
                                <NuxtLink v-if="payment.status === 'PENDING'" :to="`/my-payments/upload/${payment.id}`"
                                    class="w-full sm:w-auto px-6 py-1.5 text-sm font-bold text-red-500 border border-red-500 rounded-md hover:bg-red-50 transition-colors focus:ring-2 focus:ring-red-200 gap-1 flex items-center justify-center">
                                    แนบหลักฐาน
                                </NuxtLink>
                            </div>
                        </div>
                    </div>

                    <div v-if="filteredPayments.length === 0" class="bg-white p-12 rounded-xl border border-gray-200 text-center">
                        <svg class="w-16 h-16 mx-auto text-gray-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
                        <p class="text-gray-500 text-lg">ไม่มีรายการชำระเงินในหมวดหมู่นี้</p>
                    </div>
                </div>

                <!-- Right column: Map -->
                <div class="lg:col-span-1">
                    <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden sticky top-24">
                        <div class="p-5 border-b border-gray-200">
                            <h3 class="font-bold text-gray-900 text-lg">แผนที่เส้นทาง</h3>
                        </div>
                        <div class="w-full h-[500px] bg-gray-100 relative">
                            <!-- Placeholder Map. In a real scenario, use Google Maps API component -->
                            <iframe 
                                width="100%" 
                                height="100%" 
                                frameborder="0" 
                                style="border:0"
                                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3949.46740660233!2d102.82294157502263!3d16.444738484285854!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x31222a2bb5356ec3%3A0xe5f9b1fe658fbff3!2sKhon%20Kaen%20University!5e0!3m2!1sen!2sth!4v1700000000000!5m2!1sen!2sth" 
                                allowfullscreen
                                loading="lazy">
                            </iframe>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

definePageMeta({
    middleware: 'auth'
})

// === State & Data ===
const activeTab = ref('PENDING')
const isLoading = ref(true)
const payments = ref([])

const pendingCount = computed(() => payments.value.filter(p => p.status === 'PENDING').length)
const confirmedCount = computed(() => payments.value.filter(p => p.status === 'CONFIRMED').length)

const filteredPayments = computed(() => {
    if (activeTab.value === 'ALL') return payments.value
    return payments.value.filter(p => p.status === activeTab.value)
})

const { $api } = useNuxtApp()

onMounted(async () => {
    try {
        const bookings = await $api('/bookings/me')
        // Filter out rejected, cancelled trips? Let's just map for now
        payments.value = bookings.filter(b => b.status === 'CONFIRMED' || b.status === 'COMPLETED').map(b => {
             const startName = b.route?.startLocation?.name || 'Unknown'
             const endName = b.route?.endLocation?.name || 'Unknown'
             
             // To simplify, if payment status is completed, we consider it confirmed. 
             // Without real payment status in the fast mockup, let's treat hasReceipt randomly or mock for now
             const hasReceipt = Math.random() > 0.5 // Mock logic if it has receipt or not from backend
             
             return {
                 id: b.id,
                 from: startName,
                 to: endName,
                 meetpoint: b.pickupLocation?.name || 'ไม่ระบุ',
                 date: new Date(b.route?.departureTime).toLocaleDateString('th-TH', { year: 'numeric', month: 'short', day: 'numeric' }),
                 time: new Date(b.route?.departureTime).toLocaleTimeString('th-TH', { hour: '2-digit', minute: '2-digit' }) + ' น.',
                 duration: b.route?.duration || '-',
                 distance: b.route?.distanceMeters ? `${(b.route.distanceMeters / 1000).toFixed(1)} กม.` : '-',
                 
                 driverInitials: (b.route?.driver?.firstName || 'D').charAt(0).toUpperCase() + (b.route?.driver?.lastName || '').charAt(0).toUpperCase(),
                 driverName: `${b.route?.driver?.firstName || ''} ${b.route?.driver?.lastName || ''}`.trim() || 'Driver',
                 rating: 4.5,
                 reviews: 35,
                 
                 // Default to PENDING if payment is unpaid, but in our case trips that are confirmed mean they are ready to attach slip
                 status: hasReceipt ? 'CONFIRMED' : 'PENDING',
                 hasReceipt: hasReceipt,
                 
                 price: (b.route?.pricePerSeat || 0) * (b.numberOfSeats || 1),
                 seats: b.numberOfSeats || 1
             }
        })
    } catch (error) {
        console.error('Error fetching payments:', error)
    } finally {
        isLoading.value = false
    }
})
</script>

<style scoped>
/* Optional styling details */
</style>
