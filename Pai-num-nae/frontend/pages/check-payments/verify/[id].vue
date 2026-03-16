<template>
    <div class="min-h-screen py-8 bg-gray-50">
        <div class="px-4 mx-auto max-w-7xl sm:px-6 lg:px-8">
            <!-- Loading State -->
            <div v-if="isLoading" class="flex flex-col items-center justify-center min-h-[60vh]">
                <div class="w-16 h-16 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin mb-4"></div>
                <p class="text-gray-500 font-medium">กำลังโหลดข้อมูล...</p>
            </div>

            <!-- Error State -->
            <div v-else-if="errorMsg" class="flex flex-col items-center justify-center min-h-[60vh]">
                <div class="w-16 h-16 bg-red-100 text-red-600 rounded-full flex items-center justify-center mb-4">
                    <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                </div>
                <h2 class="text-xl font-bold text-gray-800 mb-2">เกิดข้อผิดพลาดในการโหลดข้อมูล</h2>
                <p class="text-gray-600 mb-6 text-center max-w-md">{{ errorMsg }}</p>
                <div class="flex gap-3">
                    <button @click="fetchBookingData" class="px-6 py-2 bg-blue-600 text-white font-bold rounded-lg hover:bg-blue-700 transition-all">ลองใหม่</button>
                    <button @click="goBack" class="px-6 py-2 bg-gray-200 text-gray-700 font-bold rounded-lg hover:bg-gray-300 transition-all">กลับ</button>
                </div>
            </div>

            <!-- Success State -->
            <div v-else-if="isSuccess" class="flex flex-col items-center justify-center min-h-[60vh]">

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
                        <div class="relative flex items-center justify-center w-full h-auto min-h-48 bg-gray-50 border-2 border-gray-300 border-dashed rounded-lg mb-6 overflow-hidden">
                            <img v-if="bookingData?.paymentProofUrl" :src="bookingData.paymentProofUrl" class="object-contain w-full h-full rounded-lg" alt="Slip Proof" />
                            <div v-else class="text-center text-gray-400 py-10">
                                <span class="font-medium">ยังไม่มีการแนบรูปหลักฐาน</span>
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
                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        <!-- Fee Adjustment Section -->
                        <div class="space-y-4">
                            <h4 class="mb-2 text-sm font-bold text-gray-800">รายละเอียดค่าใช้จ่าย <span class="text-red-500">*</span></h4>
                            <div class="p-6 bg-white border border-gray-200 rounded-xl shadow-sm">
                                <div class="space-y-4">
                                    <div class="flex justify-between items-center text-gray-800">
                                        <span class="text-sm font-medium">ค่าเดินทางพื้นฐาน</span>
                                        <span class="font-bold">{{ bookingData?.totalPrice || paymentPrice }} บาท</span>
                                    </div>
                                    
                                    <div class="pt-4 border-t border-gray-100 flex flex-col gap-3">
                                        <div class="flex items-center justify-between gap-4">
                                            <label class="text-sm text-gray-600">ค่าทางด่วน (ถ้ามี)</label>
                                            <div class="relative w-32">
                                                <input type="number" v-model="tollFees"
                                                    class="w-full px-3 py-1.5 text-right border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-100 focus:border-blue-400 outline-none transition-all" />
                                                <span class="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-gray-400 pointer-events-none"></span>
                                            </div>
                                        </div>
                                        
                                        <div class="flex items-center justify-between gap-4">
                                            <label class="text-sm text-gray-600">ค่าใช้จ่ายเพิ่มเติมอื่นๆ</label>
                                            <div class="relative w-32">
                                                <input type="number" v-model="otherFees"
                                                    class="w-full px-3 py-1.5 text-right border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-100 focus:border-blue-400 outline-none transition-all" />
                                            </div>
                                        </div>
                                    </div>

                                    <div class="pt-4 border-t border-gray-100 flex justify-between items-center text-blue-600">
                                        <span class="font-black text-lg">ยอดรวมสุทธิ</span>
                                        <span class="font-black text-2xl">{{ grandTotal }} บาท</span>
                                    </div>
                                </div>
                            </div>

                            <div class="flex flex-col sm:flex-row gap-3 pt-2">
                                <button v-if="status === 'PENDING'" @click="confirmPayment" :disabled="isSubmitting"
                                    class="flex-1 px-6 py-3 font-bold text-white transition-all rounded-lg shadow-md hover:shadow-lg disabled:opacity-50 disabled:cursor-not-allowed bg-green-600 hover:bg-green-700">
                                    ยืนยันการชำระเงิน
                                </button>
                                <button v-else @click="goBack"
                                    class="w-full px-6 py-3 font-bold text-white transition-all bg-gray-500 rounded-lg hover:bg-gray-600">
                                    กลับ
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
import { ref, onMounted, computed, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useRuntimeConfig } from '#app'

definePageMeta({
    middleware: 'auth'
})

const router = useRouter()
const route = useRoute()
const config = useRuntimeConfig()
const { $api } = useNuxtApp()

const isSubmitting = ref(false)
const isLoading = ref(true)
const errorMsg = ref('')
const isSuccess = ref(false)
const bookingData = ref(null)

// Advanced features state
const tollFees = ref(0)
const otherFees = ref(0)
const showPreview = ref(false)
const driverWantsReceipt = ref(false)
const editableReceipt = ref({
    type: 'INDIVIDUAL',
    name: '',
    taxId: '',
    address: ''
})

// MOCK data based on the route ID
const paymentPrice = ref(10)
const hasImage = ref(false)
const status = ref('PENDING')

const grandTotal = computed(() => {
    const base = bookingData.value?.totalPrice || paymentPrice.value
    return Number(base) + Number(tollFees.value || 0) + Number(otherFees.value || 0)
})

const fetchBookingData = async () => {
    isLoading.value = true
    errorMsg.value = ''
    
    // Fetch real data from backend using $api plugin (handles tokens/cookies automatically)
    // Note: Removed leading slash to prevent double-slash with baseURL ending in /
    try {
        const result = await $api(`bookings/${route.params.id}`)
        
        bookingData.value = result
        status.value = result.status
        hasImage.value = !!result.paymentProofUrl
        
        // Set initial toggle state based on passenger's request
        driverWantsReceipt.value = !!result.isReceiptRequested

        // Initialize editable receipt with data from passenger
        if (result.receiptDetails) {
            editableReceipt.value = { 
                ...result.receiptDetails,
                type: result.receiptDetails.type || 'INDIVIDUAL'
            }
        }
    } catch (error) {
        console.error('Error fetching booking details:', error)
        errorMsg.value = error.data?.message || error.message || 'ไม่สามารถดึงข้อมูลการจองได้'
    } finally {
        isLoading.value = false
    }
}

onMounted(() => {
    fetchBookingData()
})

const goBack = () => {
    router.push('/check-payments')
}

const confirmPayment = async () => {
    isSubmitting.value = true

    // Requirement: Log the final data to console
    const finalData = {
        bookingId: route.params.id,
        status: 'CONFIRMED',
        originalFare: bookingData.value?.totalPrice || paymentPrice.value,
        additionalFees: {
            toll: tollFees.value,
            other: otherFees.value
        },
        grandTotal: grandTotal.value,
        receipt: driverWantsReceipt.value ? editableReceipt.value : null
    }
    
    console.log('Final Data being sent to Backend:', JSON.stringify(finalData, null, 2))

    try {
        // Step 1: Confirm status using $api
        // Note: Removed leading slash to match fetchBookingData style
        await $api(`bookings/${route.params.id}/status`, {
            method: 'PATCH',
            body: { status: 'CONFIRMED' }
        })

        // Success flow
        isSuccess.value = true
        showPreview.value = false
        
        setTimeout(() => {
            router.push('/check-payments')
        }, 1500)

    } catch (error) {
        console.error('Error confirming payment:', error)
        alert(error.data?.message || error.message || 'ยืนยันหลักฐานไม่สำเร็จ')
    } finally {
        isSubmitting.value = false
    }
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
