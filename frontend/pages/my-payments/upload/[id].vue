<template>
  <div class="min-h-screen py-8 bg-gray-50">
    <div class="px-4 mx-auto max-w-7xl sm:px-6 lg:px-8">
      <h1 class="mb-6 text-2xl font-bold text-gray-800" v-if="!isSuccess">แนบหลักฐานการชำระเงิน</h1>

      <div v-if="isSuccess" class="flex flex-col items-center justify-center min-h-[60vh]">
        <div class="flex items-center justify-center w-24 h-24 mb-6 bg-green-500 rounded-full shadow-lg">
          <svg class="w-12 h-12 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h2 class="text-3xl font-bold text-gray-800">บันทึกสำเร็จ</h2>
        <p class="mt-4 text-gray-600">กำลังพากลับไปหน้ารายการชำระเงิน...</p>
      </div>

      <div v-else class="grid grid-cols-1 gap-6 md:grid-cols-12">
        <div class="md:col-span-4 lg:col-span-3">
          <div class="mb-4">
            <h4 class="mb-2 text-sm font-bold text-gray-800">แนบหลักฐาน <span class="text-red-500">*</span></h4>
            <p class="text-xs text-gray-500 mb-2" v-if="paymentMethod === 'CASH'">กรณีเงินสด ไม่แนบไฟล์ได้ แต่ต้องใส่หมายเหตุ</p>

            <div class="relative flex items-center justify-center w-full h-48 bg-gray-50 border-2 border-gray-300 border-dashed rounded-lg cursor-pointer hover:bg-gray-100" @click="triggerFileInput">
              <input type="file" ref="fileInput" class="hidden" accept="image/*,application/pdf" @change="handleFileUpload" />
              <div v-if="!previewUrl" class="text-center text-gray-400">
                <span class="font-medium">อัปโหลดรูป/PDF</span>
              </div>
              <img v-else :src="previewUrl" class="object-contain w-full h-full rounded-lg" alt="Preview" />
            </div>
          </div>

          <button
            @click="submitProof"
            :disabled="isSubmitting"
            class="w-full px-4 py-2.5 font-bold text-white transition-colors bg-blue-600 rounded-md hover:bg-blue-700 disabled:bg-blue-300 disabled:cursor-not-allowed"
          >
            <span v-if="isSubmitting" class="flex items-center justify-center">
              <svg class="w-5 h-5 mr-2 text-white animate-spin" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
              </svg>
              กำลังส่ง...
            </span>
            <span v-else>ส่งหลักฐาน</span>
          </button>
        </div>

        <div class="md:col-span-8 lg:col-span-9">
          <h4 class="mb-2 text-sm font-bold text-gray-800">รายละเอียด <span class="text-red-500">*</span></h4>

          <div v-if="errorMessage" class="mb-4 p-3 rounded-md border border-red-200 bg-red-50 text-red-600 text-sm">
            {{ errorMessage }}
          </div>

          <div class="p-6 mb-6 bg-white border border-gray-200 rounded-xl space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="text-sm font-semibold text-gray-700 block mb-1">วิธีชำระเงิน</label>
                <select v-model="paymentMethod" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:border-blue-500">
                  <option value="CASH">เงินสด (CASH)</option>
                  <option value="PROMPTPAY">PromptPay</option>
                  <option value="BANK_TRANSFER">โอนธนาคาร</option>
                  <option value="QR_CODE">QR Code</option>
                  <option value="OTHER">อื่นๆ</option>
                </select>
              </div>
              <div>
                <label class="text-sm font-semibold text-gray-700 block mb-1">วันที่/เวลา ที่ชำระ</label>
                <input v-model="paidAtLocal" type="datetime-local" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:border-blue-500" />
              </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="text-sm font-semibold text-gray-700 block mb-1">จำนวนเงิน (บาท)</label>
                <input v-model.number="amount" type="number" min="0" step="0.01" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:border-blue-500" />
              </div>
              <div>
                <label class="text-sm font-semibold text-gray-700 block mb-1">เลขอ้างอิง (ถ้ามี)</label>
                <input v-model="referenceNo" type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:border-blue-500" />
              </div>
            </div>

            <div>
              <label class="text-sm font-semibold text-gray-700 block mb-2">เอกสารที่ต้องการจากคนขับ</label>
              <div class="grid grid-cols-1 gap-2 md:grid-cols-3">
                <button
                  type="button"
                  @click="requestedDocumentType = 'RECEIPT'"
                  :class="requestedDocumentType === 'RECEIPT' ? 'border-blue-600 bg-blue-50 text-blue-700' : 'border-gray-300 bg-white text-gray-700'"
                  class="px-3 py-2 text-sm border rounded-md text-left"
                >
                  ใบเสร็จรับเงิน
                </button>
                <button
                  type="button"
                  @click="requestedDocumentType = 'TAX_INVOICE'"
                  :class="requestedDocumentType === 'TAX_INVOICE' ? 'border-blue-600 bg-blue-50 text-blue-700' : 'border-gray-300 bg-white text-gray-700'"
                  class="px-3 py-2 text-sm border rounded-md text-left"
                >
                  ใบกำกับภาษี
                </button>
                <button
                  type="button"
                  @click="requestedDocumentType = 'PAYMENT_VOUCHER'"
                  :class="requestedDocumentType === 'PAYMENT_VOUCHER' ? 'border-blue-600 bg-blue-50 text-blue-700' : 'border-gray-300 bg-white text-gray-700'"
                  class="px-3 py-2 text-sm border rounded-md text-left"
                >
                  ใบสำคัญรับเงิน
                </button>
              </div>
            </div>

            <div>
              <label class="text-sm font-semibold text-gray-700 block mb-1">หมายเหตุ</label>
              <textarea v-model="note" rows="3" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:border-blue-500" />
            </div>

            <div class="flex justify-between text-gray-800 border-t pt-4 mt-4">
              <span>รวม</span>
              <span class="font-bold">{{ Number(amount || 0).toLocaleString() }} บาท</span>
            </div>
          </div>

          <div v-if="requestedDocumentType === 'TAX_INVOICE'" class="p-6 bg-white border border-gray-200 rounded-xl">
            <div class="flex items-center mb-4">
              <input id="receiptReq" v-model="wantReceipt" type="checkbox" class="w-4 h-4 text-blue-600 border-gray-300 rounded" />
              <label for="receiptReq" class="ml-2 text-sm text-gray-700">ต้องการออกใบกำกับภาษีในนามนิติบุคคล</label>
            </div>

            <div v-if="wantReceipt" class="space-y-4">
              <div class="flex gap-2">
                <button
                  @click="receiptType = 'INDIVIDUAL'"
                  :class="receiptType === 'INDIVIDUAL' ? 'border-gray-300 text-gray-800 font-bold bg-white' : 'border-gray-200 text-gray-400 bg-gray-50'"
                  class="px-4 py-2 text-sm border rounded-md"
                >
                  บุคคลธรรมดา
                </button>
                <button
                  @click="receiptType = 'CORPORATE'"
                  :class="receiptType === 'CORPORATE' ? 'border-gray-300 text-gray-800 font-bold bg-white' : 'border-gray-200 text-gray-400 bg-gray-50'"
                  class="px-4 py-2 text-sm border rounded-md"
                >
                  นิติบุคคล/บริษัท
                </button>
              </div>

              <div v-if="receiptType === 'CORPORATE'" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label class="text-sm font-semibold text-gray-700 block mb-1">ชื่อบริษัท</label>
                  <input v-model="receiptForm.name" type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md" />
                </div>
                <div>
                  <label class="text-sm font-semibold text-gray-700 block mb-1">เลขผู้เสียภาษี (13 หลัก)</label>
                  <input v-model="receiptForm.taxId" type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md" />
                </div>
                <div class="md:col-span-2">
                  <label class="text-sm font-semibold text-gray-700 block mb-1">ที่อยู่ตามทะเบียนภาษี</label>
                  <textarea v-model="receiptForm.address" rows="3" class="w-full px-3 py-2 border border-gray-300 rounded-md" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'

definePageMeta({ middleware: 'auth' })

const { $api } = useNuxtApp()
const route = useRoute()
const router = useRouter()

const fileInput = ref(null)
const selectedFile = ref(null)
const previewUrl = ref('')
const isSubmitting = ref(false)
const isSuccess = ref(false)
const errorMessage = ref('')

const amount = ref(0)
const paymentMethod = ref('PROMPTPAY')
const paidAtLocal = ref('')
const referenceNo = ref('')
const note = ref('')
const requestedDocumentType = ref('RECEIPT')

const wantReceipt = ref(false)
const receiptType = ref('INDIVIDUAL')
const receiptForm = ref({
  name: '',
  taxId: '',
  address: '',
})

const bookingId = route.params.id

const triggerFileInput = () => fileInput.value?.click()

const handleFileUpload = (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  selectedFile.value = file
  if (file.type.startsWith('image/')) {
    previewUrl.value = URL.createObjectURL(file)
  } else {
    previewUrl.value = ''
  }
}

const validateBeforeSubmit = () => {
  const isCash = paymentMethod.value === 'CASH'

  if (!paidAtLocal.value) return 'กรุณาระบุวันที่/เวลา ที่ชำระ'
  if (!amount.value || Number(amount.value) <= 0) return 'กรุณาระบุจำนวนเงินให้ถูกต้อง'

  if (!isCash && !selectedFile.value) {
    return 'กรุณาแนบหลักฐานการชำระเงินอย่างน้อย 1 ไฟล์'
  }

  if (isCash && !String(note.value || '').trim()) {
    return 'กรณีชำระเงินสด กรุณาระบุหมายเหตุ'
  }

  const isTaxInvoiceRequest = requestedDocumentType.value === 'TAX_INVOICE'

  if (isTaxInvoiceRequest && wantReceipt.value && receiptType.value === 'CORPORATE') {
    if (!String(receiptForm.value.name || '').trim()) return 'กรุณาระบุชื่อบริษัท'
    if (!/^\d{13}$/.test(String(receiptForm.value.taxId || '').trim())) return 'เลขผู้เสียภาษีต้องมี 13 หลัก'
    if (!String(receiptForm.value.address || '').trim()) return 'กรุณาระบุที่อยู่ตามทะเบียนภาษี'
  }

  return ''
}

const submitProof = async () => {
  errorMessage.value = ''
  const validationMessage = validateBeforeSubmit()
  if (validationMessage) {
    errorMessage.value = validationMessage
    return
  }

  isSubmitting.value = true

  try {
    const formData = new FormData()
    formData.append('paymentMethod', paymentMethod.value)
    formData.append('paidAt', new Date(paidAtLocal.value).toISOString())
    formData.append('amount', String(amount.value))
    formData.append('requestedDocumentType', requestedDocumentType.value)

    if (referenceNo.value) formData.append('referenceNo', referenceNo.value)
    if (note.value) formData.append('note', note.value)

    const isCorporateRequest =
      requestedDocumentType.value === 'TAX_INVOICE' &&
      wantReceipt.value &&
      receiptType.value === 'CORPORATE'
    formData.append('isCorporateRequest', String(isCorporateRequest))

    if (isCorporateRequest) {
      formData.append('companyName', receiptForm.value.name)
      formData.append('companyTaxId', receiptForm.value.taxId)
      formData.append('companyAddress', receiptForm.value.address)
      formData.append('companyBranchCode', '00000')
    }

    if (selectedFile.value) {
      formData.append('evidences', selectedFile.value)
    }

    await $api(`/payments/bookings/${bookingId}/proof`, {
      method: 'POST',
      body: formData,
    })

    isSuccess.value = true
    setTimeout(() => router.push('/my-payments'), 1200)
  } catch (error) {
    console.error('submitProof error:', error)
    errorMessage.value = error?.statusMessage || 'ส่งหลักฐานไม่สำเร็จ'
  } finally {
    isSubmitting.value = false
  }
}

onMounted(async () => {
  try {
    const booking = await $api(`/bookings/${bookingId}`)
    amount.value = (booking?.route?.pricePerSeat || 0) * (booking?.numberOfSeats || 1)
  } catch (error) {
    console.error('load booking for upload failed:', error)
    errorMessage.value = 'ไม่สามารถโหลดข้อมูลการเดินทางได้'
  }

  const now = new Date()
  now.setMinutes(now.getMinutes() - now.getTimezoneOffset())
  paidAtLocal.value = now.toISOString().slice(0, 16)
})

watch(requestedDocumentType, (nextType) => {
  if (nextType === 'TAX_INVOICE') return
  wantReceipt.value = false
  receiptType.value = 'INDIVIDUAL'
  receiptForm.value = {
    name: '',
    taxId: '',
    address: '',
  }
})
</script>
