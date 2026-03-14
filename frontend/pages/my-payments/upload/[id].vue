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
                        <div class="relative flex items-center justify-center w-full h-48 bg-gray-50 border-2 border-gray-300 border-dashed rounded-lg cursor-pointer hover:bg-gray-100" @click="triggerFileInput">
                            <input type="file" ref="fileInput" class="hidden" accept="image/*" @change="handleFileUpload" />
                            <div v-if="!previewUrl" class="text-center text-gray-400">
                                <span class="font-medium">อัปโหลดรูป</span>
                            </div>
                            <img v-else :src="previewUrl" class="object-contain w-full h-full rounded-lg" alt="Preview preview" />
                        </div>
                    </div>

                    <!-- Receipt Toggle -->
                    <div class="flex items-center mb-6">
                        <input type="radio" id="receiptRadio" :checked="wantReceipt" @click="toggleReceipt" class="w-4 h-4 text-blue-600 border-gray-300 focus:ring-blue-500">
                        <label for="receiptRadio" class="ml-2 text-sm text-gray-700 cursor-pointer" @click="toggleReceipt">ต้องการใบเสร็จหรือไม่</label>
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

                    <!-- Receipt Form -->
                    <div v-if="wantReceipt" class="p-6 bg-white border border-gray-200 rounded-xl animate-fade-in">
                        <div class="flex gap-2 mb-6">
                            <button @click="receiptType = 'INDIVIDUAL'" 
                                :class="receiptType === 'INDIVIDUAL' ? 'border-gray-300 text-gray-800 font-bold bg-white' : 'border-gray-200 text-gray-400 bg-gray-50'"
                                class="px-4 py-2 text-sm border rounded-md transition-colors focus:outline-none">
                                บุคคลธรรมดา
                            </button>
                            <button @click="receiptType = 'CORPORATE'" 
                                :class="receiptType === 'CORPORATE' ? 'border-gray-300 text-gray-800 font-bold bg-white' : 'border-gray-200 text-gray-400 bg-gray-50'"
                                class="px-4 py-2 text-sm border rounded-md transition-colors focus:outline-none">
                                นิติบุคคล/บริษัท
                            </button>
                        </div>

                        <div class="space-y-4">
                            <div class="flex flex-col sm:flex-row sm:items-center gap-2">
                                <label class="w-full sm:w-48 text-sm text-gray-800">ชื่อ-นามสกุล :</label>
                                <input type="text" v-model="receiptForm.name" class="flex-1 w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:border-blue-500" />
                            </div>
                            <div class="flex flex-col sm:flex-row sm:items-center gap-2">
                                <label class="w-full sm:w-48 text-sm text-gray-800">เลขประจำตัวผู้เสียภาษี :</label>
                                <input type="text" v-model="receiptForm.taxId" class="flex-1 w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:border-blue-500" />
                            </div>
                            <div class="flex flex-col sm:flex-row sm:items-start gap-2">
                                <label class="w-full sm:w-48 text-sm text-gray-800 pt-2">ที่อยู่ตามทะเบียนภาษี :</label>
                                <textarea v-model="receiptForm.address" rows="3" class="flex-1 w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:border-blue-500"></textarea>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

definePageMeta({
    middleware: 'auth'
})

const router = useRouter()
const fileInput = ref(null)
const previewUrl = ref(null)
const wantReceipt = ref(false)
const receiptType = ref('INDIVIDUAL')
const isSubmitting = ref(false)
const isSuccess = ref(false)

// MOCK data
const paymentPrice = ref(10)

const receiptForm = ref({
    name: '',
    taxId: '',
    address: ''
})

const toggleReceipt = () => {
    wantReceipt.value = !wantReceipt.value
    if (wantReceipt.value && !receiptType.value) {
        receiptType.value = 'INDIVIDUAL'
    }
}

const triggerFileInput = () => {
    fileInput.value.click()
}

const handleFileUpload = (e) => {
    const file = e.target.files[0]
    if (file) {
        previewUrl.value = URL.createObjectURL(file)
    }
}

const submitProof = async () => {
    if (!previewUrl.value) return
    
    isSubmitting.value = true

    // Simulate API upload
    setTimeout(() => {
        isSubmitting.value = false
        isSuccess.value = true
        
        // พาผู้ใช้กลับไปหน้ารายการอัตโนมัติ 1.5 วินาทีหลังจากแสดงหน้าสำเร็จ
        setTimeout(() => {
            router.push('/my-payments')
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
