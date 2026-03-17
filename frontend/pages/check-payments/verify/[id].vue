<template>
    <div class="min-h-screen py-8 bg-gray-50">
        <div class="px-4 mx-auto max-w-7xl sm:px-6 lg:px-8">

            <!-- Success State -->
            <div v-if="isSuccess" class="flex flex-col items-center justify-center min-h-[60vh]">
                <div class="flex items-center justify-center w-24 h-24 mb-6 bg-green-500 rounded-full shadow-lg">
                    <svg class="w-12 h-12 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"></path>
                    </svg>
                </div>
                <h2 class="text-3xl font-bold text-gray-800">บันทึกสำเร็จ</h2>
                <p class="mt-4 text-gray-600">กำลังพาคุณกลับไปที่หน้ารายการสถานะผู้โดยสาร...</p>
            </div>

            <!-- Verification Form State -->
            <div v-else class="grid grid-cols-1 gap-6 md:grid-cols-12 mt-6">
                <!-- Left Details: Proof Area (4 cols) -->
                <div class="md:col-span-4 lg:col-span-3">
                    <div class="mb-4">
                        <h4 class="mb-2 text-sm font-bold text-gray-800">หลักฐาน <span class="text-red-500">*</span></h4>
                        
                        <!-- Uploaded Proof Box -->
                        <div class="relative flex items-center justify-center w-full h-48 bg-gray-50 border-2 border-gray-300 border-dashed rounded-lg mb-6">
                            <!-- Since this is a mockup, we can use a placeholder image or just text depending on provided mockup -->
                            <img v-if="hasImage" src="https://via.placeholder.com/300x400.png?text=Slip+Image+Mockup" class="object-contain w-full h-full rounded-lg" alt="Slip Proof" />
                            <div v-else class="text-center text-gray-400">
                                <span class="font-medium">รูป</span>
                            </div>
                        </div>
                    </div>

                    <!-- Action Button -->
                    <button v-if="status === 'PENDING'" @click="confirmPayment" :disabled="isSubmitting"
                        class="w-full sm:w-auto px-6 py-2.5 font-bold text-white transition-colors bg-blue-600 rounded-md hover:bg-blue-700 disabled:bg-blue-300 disabled:cursor-not-allowed">
                        <span v-if="isSubmitting" class="flex items-center justify-center">
                            <svg class="w-5 h-5 mr-2 text-white animate-spin" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                            </svg>
                            กำลังส่ง...
                        </span>
                        <span v-else>ยืนยันหลักฐาน</span>
                    </button>
                    <!-- Back Button if already confirmed -->
                    <button v-else @click="goBack" 
                        class="w-full sm:w-auto px-10 py-2.5 font-bold text-white transition-colors bg-blue-600 rounded-md hover:bg-blue-700">
                        กลับ
                    </button>
                </div>

                <!-- Right Details: Payment Summary (8 cols) -->
                <div class="md:col-span-8 lg:col-span-9">
                    <h4 class="mb-2 text-sm font-bold text-gray-800">รายละเอียด <span class="text-red-500">*</span></h4>
                    
                    <div class="p-6 mb-6 bg-white border border-gray-200 rounded-xl">
                        <div class="flex justify-between mb-4 text-gray-800">
                            <span>ค่าเดินทาง</span>
                            <span>{{ paymentPrice }} บาท</span>
                        </div>
                        <div class="flex justify-between pb-6 mb-6 text-gray-800">
                            <span>อื่น ๆ</span>
                            <span>- บาท</span>
                        </div>
                        <div class="flex justify-between text-gray-800 line-clamp-1 border-t border-gray-100 pt-6">
                            <span>รวม</span>
                            <span>{{ paymentPrice }} บาท</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'

definePageMeta({
    middleware: 'auth'
})

const router = useRouter()
const route = useRoute()

const isSubmitting = ref(false)
const isSuccess = ref(false)

// MOCK data based on the route ID
const paymentPrice = ref(10)
const hasImage = ref(true)

// We check if it's already confirmed based on id or mock logic
// For demo purposes, we can assume 'bk_103' is confirmed, anything else is pending
const status = ref('PENDING') 

onMounted(() => {
    // Usually fetch the payment status from API here
    // For mockup purposes, we check localStorage
    const mockConfirmedBookings = JSON.parse(localStorage.getItem('mockDriverConfirmedBookings') || '[]')
    if (mockConfirmedBookings.includes(route.params.id)) {
        status.value = 'CONFIRMED'
    } else {
        status.value = 'PENDING'
    }
})

const goBack = () => {
    router.push('/check-payments')
}

const confirmPayment = async () => {
    isSubmitting.value = true

    // Simulate API approve payment
    setTimeout(() => {
        isSubmitting.value = false
        isSuccess.value = true
        
        // Save to localStorage so status persists as CONFIRMED in the frontend mock
        const mockConfirmedBookings = JSON.parse(localStorage.getItem('mockDriverConfirmedBookings') || '[]')
        if (!mockConfirmedBookings.includes(route.params.id)) {
            mockConfirmedBookings.push(route.params.id)
            localStorage.setItem('mockDriverConfirmedBookings', JSON.stringify(mockConfirmedBookings))
        }
        
        // Auto redirect back to the check payments page
        setTimeout(() => {
            router.push('/check-payments')
        }, 1500)
    }, 1200)
}
</script>

<style scoped>
.animate-fade-in {
    animation: fadeIn 0.3s ease-in-out;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(-10px); }
    to { opacity: 1; transform: translateY(0); }
}
</style>
