<template>
    <div class="min-h-screen py-8 bg-gray-50">
        <div class="px-4 mx-auto max-w-7xl sm:px-6 lg:px-8">
            <h1 class="mb-6 text-2xl font-bold text-gray-800" v-if="!isSuccess">แนบหลักฐานการชำระเงิน</h1>

            <div v-if="isSuccess" class="flex flex-col items-center justify-center min-h-[60vh]">
                <div class="flex items-center justify-center w-24 h-24 mb-6 bg-green-500 rounded-full shadow-lg">
                    <svg class="w-12 h-12 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"></path>
                    </svg>
                </div>
                <h2 class="text-3xl font-bold text-gray-800">บันทึกสำเร็จ</h2>
                <p class="mt-4 text-gray-600">กำลังพาคุณกลับไปที่หน้ารายการชำระเงิน...</p>
            </div>

            <!-- Upload Form State -->
            <div v-else class="grid grid-cols-1 gap-6 md:grid-cols-12">
                <!-- Left Details: Upload Area & Receipt Toggle (4 cols) -->
                <div class="md:col-span-4 lg:col-span-3">
                    <div class="mb-4">
                        <h4 class="mb-2 text-sm font-bold text-gray-800">แนบหลักฐาน <span class="text-red-500">*</span></h4>
                        
                        <!-- Upload Box -->
                        <div class="relative flex flex-col items-center justify-center w-full h-48 bg-gray-50 border-2 border-gray-300 border-dashed rounded-lg mb-2">
                            <input type="file" ref="fileInput" class="hidden" accept="image/*" @change="handleFileUpload" />
                            <div v-if="!previewUrl" class="text-center text-gray-400 cursor-pointer w-full h-full flex items-center justify-center hover:bg-gray-100" @click="triggerFileInput">
                                <span class="font-medium">อัปโหลดรูป</span>
                            </div>
                            <div v-else class="relative w-full h-full group">
                                <img :src="previewUrl" class="object-contain w-full h-full rounded-lg" alt="Preview preview" />
                                <div class="absolute inset-0 bg-black/40 bg-opacity-50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center rounded-lg backdrop-blur-sm">
                                    <button @click="removeImage" type="button" class="px-4 py-2 bg-red-500 text-white text-sm font-bold rounded-md hover:bg-red-600 shadow-md flex items-center gap-2">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                                        ลบรูป
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                        <!-- Document Choice Toggle -->
                        <div class="flex items-center mb-6">
                            <input type="radio" id="receiptYes" :value="true" v-model="isReceiptRequested" class="w-4 h-4 text-blue-600 border-gray-300 focus:ring-blue-500">
                            <label for="receiptYes" class="ml-2 mr-6 text-sm text-gray-700 cursor-pointer">ขอใบกำกับภาษี/ใบสำคัญรับเงิน</label>
                            
                            <input type="radio" id="receiptNo" :value="false" v-model="isReceiptRequested" class="w-4 h-4 text-blue-600 border-gray-300 focus:ring-blue-500">
                            <label for="receiptNo" class="ml-2 text-sm text-gray-700 cursor-pointer">ไม่ต้องการ</label>
                        </div>

                        <button @click="submitProof" :disabled="!previewUrl || isSubmitting"
                            class="w-full px-4 py-2.5 font-bold text-white transition-colors bg-blue-600 rounded-md hover:bg-blue-700 disabled:bg-blue-300 disabled:cursor-not-allowed">
                        <span v-if="isSubmitting" class="flex items-center justify-center">
                            <svg class="w-5 h-5 mr-2 text-white animate-spin" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                            </svg>
                            กำลังส่ง...
                        </span>
                        <span v-else>ส่งหลักฐาน</span>
                    </button>
                </div>

                <!-- Right Details: Payment Summary & Receipt Form (8 cols) -->
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
import { useRuntimeConfig } from '#app'

definePageMeta({
    middleware: 'auth'
})

const router = useRouter()
const route = useRoute()
const config = useRuntimeConfig()
const bookingId = route.params.id

const fileInput = ref(null)
const previewUrl = ref(null)
const selectedFile = ref(null)
const isReceiptRequested = ref(false)
const isSubmitting = ref(false)
const isSuccess = ref(false)

// MOCK data
const paymentPrice = ref(10)

// Initial data fetch can go here
onMounted(() => {
    //
})

const removeImage = () => {
    previewUrl.value = null
    if (fileInput.value) fileInput.value.value = ''
}

const triggerFileInput = () => {
    fileInput.value.click()
}

const handleFileUpload = (e) => {
    const file = e.target.files[0]
    if (file) {
        selectedFile.value = file
        previewUrl.value = URL.createObjectURL(file)
    }
}

const submitProof = async () => {
    if (!selectedFile.value) {
        alert('กรุณาอัปโหลดรูปหลักฐานการชำระเงิน')
        return
    }
    

    isSubmitting.value = true

    try {
        // Prepare multipart data
        const formData = new FormData()
        formData.append('paymentProof', selectedFile.value)
        formData.append('isReceiptRequested', isReceiptRequested.value)
        

        const { $api } = useNuxtApp()

        const response = await $api(`/bookings/${bookingId}/payment-proof`, {
            method: 'PATCH',
            body: formData
        })

        isSuccess.value = true
        
        // พาผู้ใช้กลับไปหน้ารายการอัตโนมัติ 1.5 วินาทีหลังจากแสดงหน้าสำเร็จ
        setTimeout(() => {
            router.push('/my-payments')
        }, 1500)

    } catch (error) {
        console.error('Submission error:', error)
        alert(error.message || 'ไม่สามารถส่งหลักฐานได้ กรุณาลองใหม่')
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
