<template>
    <div class="min-h-screen bg-gray-50 py-8">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <h1 class="text-2xl font-bold text-gray-800 mb-6">ตรวจสอบ</h1>

            <!-- Tabs -->
            <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-200 mb-6 flex flex-wrap gap-4">
                <button 
                    class="bg-blue-600 text-white border-blue-600 px-6 py-2.5 rounded-md font-medium border transition-colors focus:outline-none">
                    การเดินทางของฉัน
                </button>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Left column: Route List -->
                <div class="lg:col-span-2 space-y-4">
                    <div v-if="isLoading" class="p-12 text-center text-gray-500 bg-white rounded-xl shadow-sm border border-gray-200">
                        <p>กำลังโหลดข้อมูลการเดินทาง...</p>
                    </div>
                    
                    <div v-else-if="myRoutes.length === 0" class="bg-white p-12 rounded-xl border border-gray-200 text-center">
                        <svg class="w-16 h-16 mx-auto text-gray-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
                        <p class="text-gray-500 text-lg">ยังไม่มีรายการเดินทาง</p>
                    </div>

                    <div v-else v-for="route in myRoutes" :key="route.id" class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 flex flex-col sm:flex-row justify-between relative transition-all duration-200 hover:shadow-md">
                        <div class="flex-1 pr-4">
                            <h3 class="text-lg font-bold text-gray-900 flex items-center gap-2">
                                {{ route.from }} 
                                <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path></svg> 
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
                                ราคาต่อที่นั่ง: {{ route.price }} บาท
                            </p>
                        </div>

                        <!-- Status and Action -->
                        <div class="mt-6 sm:mt-0 sm:ml-4 flex flex-col justify-between items-start sm:items-end min-w-[120px]">
                            <span class="px-4 py-1.5 rounded-full text-xs font-bold bg-green-100 text-green-700 self-end mb-4 sm:mb-0">
                                เปิดรับผู้โดยสาร
                            </span>

                            <div class="w-full sm:w-auto mt-auto">
                                <button @click="openPassengerModal(route)"
                                    class="w-full sm:w-auto px-6 py-2 text-sm font-bold text-white bg-emerald-500 rounded-md hover:bg-emerald-600 transition-colors focus:ring-2 focus:ring-emerald-300 gap-1 flex items-center justify-center shadow-sm">
                                    ตรวจสอบ
                                </button>
                            </div>
                        </div>
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

        <!-- Passenger Modal -->
        <div v-if="showPassengerModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/40 backdrop-blur-sm animate-fade-in" @click.self="closePassengerModal">
            <div class="bg-white rounded-2xl shadow-xl w-full max-w-3xl overflow-hidden animate-slide-up">
                <div class="p-6">
                    <h2 class="text-xl font-bold text-gray-900 mb-6">ผู้โดยสารทั้งหมด</h2>
                    
                    <div class="space-y-4 max-h-[60vh] overflow-y-auto pr-2 custom-scrollbar">
                        <div v-if="selectedRoutePassengers.length === 0" class="text-center py-8 text-gray-500">
                            ไม่มีผู้โดยสารจองในเส้นทางนี้
                        </div>
                        
                        <div v-for="passenger in selectedRoutePassengers" :key="passenger.id" 
                            class="flex flex-col sm:flex-row items-center p-4 bg-gray-50 rounded-xl border border-gray-100 hover:border-gray-200 transition-colors">
                            
                            <!-- Left: Passenger Info -->
                            <div class="flex items-center flex-1 w-full mb-4 sm:mb-0">
                                <div class="w-12 h-12 bg-indigo-200 text-indigo-700 rounded-full flex items-center justify-center font-bold text-lg mr-4 flex-shrink-0">
                                    {{ passenger.initials }}
                                </div>
                                <div class="flex-1 min-w-0 pr-4">
                                    <h4 class="font-bold text-gray-900 truncate">{{ passenger.name }}</h4>
                                    <p class="text-xs text-gray-500 truncate mb-1">อีเมล: <span class="text-blue-600">{{ passenger.email }}</span></p>
                                    <div class="flex items-center text-xs">
                                        <div class="flex text-yellow-500 mr-1">
                                            <svg v-for="i in 5" :key="i" class="w-3.5 h-3.5 fill-current" viewBox="0 0 20 20">
                                                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                                            </svg>
                                        </div>
                                        <span class="text-gray-500">{{ passenger.rating }} ({{ passenger.reviews }} รีวิว)</span>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Right: Status and Action -->
                            <div class="flex items-center gap-4 w-full sm:w-auto justify-between sm:justify-end">
                                <span v-if="passenger.status === 'CONFIRMED'" class="px-3 py-1 bg-green-100 text-green-700 text-xs font-bold rounded-full w-24 text-center">
                                    ยืนยัน
                                </span>
                                <span v-else class="px-3 py-1 bg-yellow-100 text-yellow-700 text-xs font-bold rounded-full w-24 text-center">
                                    รอยืนยัน
                                </span>
                                
                                <NuxtLink :to="`/check-payments/verify/${passenger.bookingId}`"
                                    class="px-4 py-1.5 border-2 border-emerald-500 text-emerald-600 hover:bg-emerald-50 rounded-full text-sm font-bold transition-colors text-center">
                                    ตรวจสอบการชำระเงิน
                                </NuxtLink>
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

definePageMeta({
    middleware: 'auth'
})

const { $api } = useNuxtApp()
const isLoading = ref(true)
const myRoutes = ref([])
const showPassengerModal = ref(false)
const selectedRoutePassengers = ref([])

onMounted(async () => {
    try {
        const routes = await $api('/routes/me')
        const allowedRouteStatuses = new Set(['AVAILABLE', 'FULL', 'IN_TRANSIT', 'COMPLETED'])
        
        myRoutes.value = routes
            .filter(r => allowedRouteStatuses.has(String(r.status || '').toUpperCase()))
            .map(r => {
                const startName = r.startLocation?.name || 'ไม่ทราบต้นทาง'
                const endName = r.endLocation?.name || 'ไม่ทราบปลายทาง'
                
                // Show only active bookings that might have payments
                const activeBookings = (r.bookings || []).filter(b => 
                    !['CANCELLED', 'REJECTED'].includes((b.status || '').toUpperCase())
                )
                
                const passengers = activeBookings.map(b => {
                    const fname = b.passenger?.firstName || 'P'
                    const lname = b.passenger?.lastName || ''
                    
                    let paymentStatus = b.paymentStatus || 'PENDING'
                    const mockConfirmedBookings = JSON.parse(localStorage.getItem('mockDriverConfirmedBookings') || '[]')
                    if (mockConfirmedBookings.includes(b.id)) {
                        paymentStatus = 'CONFIRMED'
                    }
                    
                    return {
                        id: b.id, 
                        bookingId: b.id, 
                        initials: (fname.charAt(0) + lname.charAt(0)).toUpperCase(),
                        name: `${fname} ${lname}`.trim() || 'Passenger',
                        email: b.passenger?.email || 'ไม่ระบุอีเมล',
                        rating: 4.5,
                        reviews: Math.floor(Math.random() * 50) + 5,
                        status: paymentStatus
                    }
                })

                return {
                    id: r.id,
                    from: startName,
                    to: endName,
                    date: new Date(r.departureTime).toLocaleDateString('th-TH', { year: 'numeric', month: 'short', day: 'numeric' }),
                    time: new Date(r.departureTime).toLocaleTimeString('th-TH', { hour: '2-digit', minute: '2-digit' }) + ' น.',
                    duration: r.durationSeconds ? `${Math.round(r.durationSeconds / 60)} นาที` : '-',
                    distance: r.distanceMeters ? `${(r.distanceMeters / 1000).toFixed(1)} กม.` : '-',
                    availableSeats: r.availableSeats ?? 0,
                    price: r.pricePerSeat || 0,
                    passengers: passengers
                }
            })
    } catch (error) {
        console.error('Failed to load routes', error)
    } finally {
        isLoading.value = false
    }
})

const openPassengerModal = (route) => {
    selectedRoutePassengers.value = route.passengers || []
    showPassengerModal.value = true
}

const closePassengerModal = () => {
    showPassengerModal.value = false
}
</script>

<style scoped>
.animate-fade-in {
    animation: fadeIn 0.2s ease-out;
}

.animate-slide-up {
    animation: slideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

@keyframes slideUp {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}

.custom-scrollbar::-webkit-scrollbar {
    width: 6px;
}
.custom-scrollbar::-webkit-scrollbar-track {
    background: #f1f1f1; 
    border-radius: 4px;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
    background: #c1c1c1; 
    border-radius: 4px;
}
.custom-scrollbar::-webkit-scrollbar-thumb:hover {
    background: #a8a8a8; 
}
</style>
