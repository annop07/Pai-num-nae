<template>
  <div class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8 font-kanit">
    <div class="max-w-4xl mx-auto">
      <!-- Header -->
      <div class="mb-8 flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">ออกเอกสารการเงิน</h1>
          <p class="mt-1 text-sm text-gray-500">สร้างใบกำกับภาษีหรือใบสำคัญรับเงินสำหรับผู้โดยสาร</p>
        </div>
        <button @click="$router.back()" class="text-sm font-medium text-blue-600 hover:text-blue-500 flex items-center">
          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          ย้อนกลับ
        </button>
      </div>

      <!-- Tab Selection -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden mb-6">
        <div class="flex border-b border-gray-200">
          <button 
            @click="documentType = 'tax'"
            :class="['flex-1 py-4 px-6 text-sm font-medium text-center focus:outline-none transition-colors font-kanit', 
              documentType === 'tax' ? 'text-blue-600 border-b-2 border-blue-600 bg-blue-50' : 'text-gray-500 hover:text-gray-700 hover:bg-gray-50']"
          >
            ใบกำกับภาษีอย่างย่อ
          </button>
          <button 
            @click="documentType = 'receipt'"
            :class="['flex-1 py-4 px-6 text-sm font-medium text-center focus:outline-none transition-colors font-kanit', 
              documentType === 'receipt' ? 'text-blue-600 border-b-2 border-blue-600 bg-blue-50' : 'text-gray-500 hover:text-gray-700 hover:bg-gray-50']"
          >
            ใบสำคัญรับเงิน
          </button>
        </div>

        <div class="p-6">
          <div v-if="isLoading" class="py-12 text-center text-gray-500">
            <p>กำลังโหลดข้อมูล...</p>
          </div>

          <form v-else @submit.prevent="handleSubmit" class="space-y-8">
            <!-- ข้อมูลผู้ขาย / ผู้รับเงิน (Driver) -->
            <section>
              <h2 class="text-lg font-semibold text-gray-900 mb-4 border-l-4 border-blue-600 pl-3">ข้อมูลผู้ขับขี่ (ผู้ขาย/ผู้รับเงิน)</h2>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">ชื่อ-นามสกุล</label>
                  <input type="text" v-model="form.driverName" readonly class="w-full px-4 py-2 bg-gray-50 border border-gray-200 rounded-md text-gray-600 font-kanit" />
                </div>
                <div v-if="documentType === 'tax'">
                  <label class="block text-sm font-medium text-gray-700 mb-1">เลขประจำตัวผู้เสียภาษี</label>
                  <input type="text" v-model="form.taxId" class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 font-kanit" placeholder="ระบุเลขประจำตัวผู้เสียภาษี" />
                </div>
                <div v-else>
                  <label class="block text-sm font-medium text-gray-700 mb-1">เลขที่บัตรประชาชน</label>
                  <input type="text" v-model="form.nationalId" class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 font-kanit" placeholder="ระบุเลขบัตรประชาชน" />
                </div>
                <div class="md:col-span-2">
                  <label class="block text-sm font-medium text-gray-700 mb-1">ที่อยู่</label>
                  <textarea v-model="form.driverAddress" rows="2" class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 font-kanit" placeholder="ระบุที่อยู่สำหรับการออกเอกสาร"></textarea>
                </div>
              </div>
            </section>

            <!-- ข้อมูลผู้จ่ายเงิน (Passenger) -->
            <section v-if="documentType === 'receipt'">
              <h2 class="text-lg font-semibold text-gray-900 mb-4 border-l-4 border-blue-600 pl-3">ข้อมูลผู้โดยสาร (ผู้จ่ายเงิน)</h2>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="md:col-span-2">
                  <label class="block text-sm font-medium text-gray-700 mb-1">ชื่อผู้จ่ายเงิน</label>
                  <input type="text" v-model="form.passengerName" class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 font-kanit" />
                </div>
              </div>
            </section>

            <!-- รายละเอียดรายการ -->
            <section>
              <div class="flex items-center justify-between mb-4">
                <h2 class="text-lg font-semibold text-gray-900 border-l-4 border-blue-600 pl-3">รายการค่าใช้จ่าย</h2>
                <button v-if="documentType === 'receipt'" type="button" @click="addItem" class="text-sm font-medium text-blue-600 hover:text-blue-500 flex items-center">
                  <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                  </svg>
                  เพิ่มรายการ
                </button>
              </div>

              <!-- รายการสำหรับ Receipt Voucher -->
              <div v-if="documentType === 'receipt'" class="border border-gray-200 rounded-lg overflow-hidden">
                <table class="min-w-full divide-y divide-gray-200 font-kanit">
                   <thead class="bg-gray-50">
                    <tr>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">รายการ</th>
                      <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider w-32">จำนวนเงิน (บาท)</th>
                      <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider w-16"></th>
                    </tr>
                  </thead>
                  <tbody class="bg-white divide-y divide-gray-200">
                    <tr v-for="(item, index) in form.items" :key="index">
                      <td class="px-6 py-4">
                        <input type="text" v-model="item.description" class="w-full border-none focus:ring-0 p-0 text-gray-900" placeholder="ระบุรายการ..." />
                      </td>
                      <td class="px-6 py-4">
                        <input type="number" v-model.number="item.amount" @input="calculateTotal" class="w-full border-none focus:ring-0 p-0 text-right text-gray-900" />
                      </td>
                      <td class="px-6 py-4 text-center">
                        <button type="button" @click="removeItem(index)" class="text-red-600 hover:text-red-900" :disabled="form.items.length === 1">
                          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                          </svg>
                        </button>
                      </td>
                    </tr>
                  </tbody>
                  <tfoot class="bg-gray-50">
                    <tr>
                      <td class="px-6 py-4 text-sm font-bold text-gray-900">รวมทั้งสิ้น</td>
                      <td class="px-6 py-4 text-right text-lg font-bold text-blue-600 font-kanit">{{ (Number(totalAmount) || 0).toLocaleString() }} บาท</td>
                      <td></td>
                    </tr>
                  </tfoot>
                </table>
              </div>

              <!-- รายการสำหรับ Tax Invoice -->
              <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4 p-4 bg-gray-50 rounded-lg border border-gray-200">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1 font-kanit">ยอดเงินรวม (รวม VAT 7%)</label>
                  <div class="relative">
                    <input type="number" v-model.number="form.taxTotal" @input="calculateTax" class="w-full pl-4 pr-12 py-3 text-lg font-bold text-blue-600 border border-gray-300 rounded-md font-kanit" />
                    <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none text-gray-500">บาท</div>
                  </div>
                </div>
                <div class="grid grid-cols-2 gap-4 py-2">
                  <div>
                    <span class="block text-xs text-gray-500 uppercase font-kanit">ฐานภาษี</span>
                    <span class="text-sm font-medium text-gray-900 font-kanit">{{ (Number(taxBase) || 0).toFixed(2) }} บาท</span>
                  </div>
                  <div>
                    <span class="block text-xs text-gray-500 uppercase font-kanit">ภาษีมูลค่าเพิ่ม (7%)</span>
                    <span class="text-sm font-medium text-gray-900 font-kanit">{{ (Number(taxVat) || 0).toFixed(2) }} บาท</span>
                  </div>
                </div>
              </div>
            </section>

            <!-- Metadata -->
            <section class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1 font-kanit">เลขที่เอกสาร</label>
                <input type="text" v-model="form.docNumber" readonly class="w-full px-4 py-2 bg-gray-50 border border-gray-200 rounded-md text-gray-600 font-kanit" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1 font-kanit">วันที่ออกเอกสาร</label>
                <input type="text" v-model="form.docDate" readonly class="w-full px-4 py-2 bg-gray-50 border border-gray-200 rounded-md text-gray-600 font-kanit" />
              </div>
            </section>

            <!-- Digital Signature -->
            <section>
              <h2 class="text-lg font-semibold text-gray-900 mb-4 border-l-4 border-blue-600 pl-3">ลายมือชื่อดิจิทัล</h2>
              <div class="border-2 border-dashed border-gray-300 rounded-lg p-4 bg-white">
                <canvas 
                  ref="signatureCanvas" 
                  class="w-full h-40 border border-gray-200 cursor-crosshair touch-none bg-white"
                  @mousedown="startDrawing"
                  @mousemove="draw"
                  @mouseup="stopDrawing"
                  @touchstart="startDrawing"
                  @touchmove="draw"
                  @touchend="stopDrawing"
                ></canvas>
                <div class="mt-2 flex justify-between items-center">
                  <p class="text-xs text-gray-500 font-kanit">ลงลายมือชื่อในช่องด้านบน</p>
                  <button type="button" @click="clearSignature" class="text-xs font-medium text-red-600 hover:text-red-500 font-kanit">ล้างลายเซ็น</button>
                </div>
              </div>
            </section>

            <!-- Actions -->
            <div class="flex flex-col sm:flex-row gap-4 pt-6 border-t border-gray-200">
              <button 
                type="button" 
                @click="showPreview = true"
                class="flex-1 px-6 py-3 border border-gray-300 text-gray-700 font-medium rounded-md hover:bg-gray-50 transition-colors font-kanit"
              >
                ดูตัวอย่างเอกสาร
              </button>
              <button 
                type="submit" 
                :disabled="isSubmitting"
                class="flex-1 px-6 py-3 bg-blue-600 text-white font-medium rounded-md hover:bg-blue-700 transition-colors shadow-lg shadow-blue-200 disabled:opacity-50 flex items-center justify-center font-kanit"
              >
                <svg v-if="isSubmitting" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                ออกเอกสารและส่งให้ผู้โดยสาร
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Preview Modal -->
    <div v-if="showPreview" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
      <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="showPreview = false"></div>
        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
        
        <div class="inline-block align-middle bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-2xl sm:w-full">
          <div class="bg-gray-50 px-4 py-3 border-b border-gray-200 flex justify-between items-center no-print">
            <h3 class="text-lg font-medium text-gray-900 font-kanit">ตัวอย่างเอกสาร</h3>
            <button @click="showPreview = false" class="text-gray-400 hover:text-gray-500">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          
          <div class="p-8 bg-white min-h-[600px] text-gray-800 font-kanit">
            <!-- Simulated Document Visuals -->
            <div class="border-2 border-gray-100 p-8 shadow-inner">
               <div class="text-center mb-8">
                 <h1 class="text-2xl font-bold mb-1">{{ documentType === 'tax' ? 'ใบกำกับภาษีอย่างย่อ' : 'ใบสำคัญรับเงิน' }}</h1>
                 <p class="text-sm">{{ documentType === 'tax' ? 'Abbreviated Tax Invoice' : 'Receipt Voucher' }}</p>
               </div>

               <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8 text-sm">
                 <div>
                   <p class="font-bold underline mb-1">ผู้ขาย / ผู้รับเงิน</p>
                   <p>{{ form.driverName || '-' }}</p>
                   <p class="break-words">{{ form.driverAddress || '-' }}</p>
                   <p v-if="documentType === 'tax'">เลขประจำตัวผู้เสียภาษี: {{ form.taxId || '-' }}</p>
                   <p v-else>เลขประจำตัวประชาชน: {{ form.nationalId || '-' }}</p>
                 </div>
                 <div class="flex flex-col md:items-end">
                   <p><span class="font-bold">เลขที่เอกสาร:</span> <span class="font-mono">{{ form.docNumber }}</span></p>
                   <p><span class="font-bold">วันที่:</span> {{ form.docDate }}</p>
                   <div v-if="documentType === 'receipt'" class="mt-4 text-left border-l-2 border-gray-300 pl-3">
                     <p class="font-bold underline mb-1">ผู้จ่ายเงิน</p>
                     <p>{{ form.passengerName || '-' }}</p>
                   </div>
                 </div>
               </div>

               <table class="w-full mb-8 text-sm border-collapse">
                 <thead>
                   <tr class="border-b-2 border-gray-800">
                     <th class="py-2 text-left">รายการ</th>
                     <th class="py-2 text-right">จำนวนเงิน</th>
                   </tr>
                 </thead>
                 <tbody>
                   <template v-if="documentType === 'receipt'">
                    <tr v-for="(item, i) in form.items" :key="i" class="border-b border-gray-100">
                      <td class="py-2">{{ item.description || '-' }}</td>
                      <td class="py-2 text-right">{{ (Number(item.amount) || 0).toLocaleString() }}</td>
                    </tr>
                    <tr class="font-bold text-lg">
                      <td class="py-4">รวมทั้งสิ้น</td>
                      <td class="py-4 text-right text-blue-600">{{ (Number(totalAmount) || 0).toLocaleString() }} บาท</td>
                    </tr>
                   </template>
                   <template v-else>
                    <tr class="border-b border-gray-100">
                      <td class="py-2">ค่าบริการเดินทาง (รวมภาษีมูลค่าเพิ่ม)</td>
                      <td class="py-2 text-right">{{ (Number(form.taxTotal) || 0).toLocaleString() }}</td>
                    </tr>
                    <tr>
                      <td class="pt-4 text-right text-xs">ฐานภาษี:</td>
                      <td class="pt-4 text-right text-xs">{{ (Number(taxBase) || 0).toFixed(2) }}</td>
                    </tr>
                    <tr>
                      <td class="text-right text-xs font-bold">ภาษีมูลค่าเพิ่ม 7%:</td>
                      <td class="text-right text-xs font-bold">{{ (Number(taxVat) || 0).toFixed(2) }}</td>
                    </tr>
                    <tr class="font-bold text-lg">
                      <td class="py-2">ยอดรวมสุทธิ</td>
                      <td class="py-2 text-right text-blue-600">{{ (Number(form.taxTotal) || 0).toLocaleString() }} บาท</td>
                    </tr>
                   </template>
                 </tbody>
               </table>

               <div class="flex justify-end mt-12">
                 <div class="text-center w-48">
                   <div class="h-20 border-b border-gray-400 mb-2 flex items-center justify-center overflow-hidden bg-gray-50">
                     <img v-if="signatureImage" :src="signatureImage" class="max-h-full" />
                     <span v-else class="text-gray-300 italic text-xs">ลงชื่อ</span>
                   </div>
                   <p class="text-xs font-bold">{{ form.driverName }}</p>
                   <p class="text-xs text-gray-500">ผู้รับเงิน / ผู้ขับขี่</p>
                 </div>
               </div>
            </div>
          </div>
          
          <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse no-print">
            <button @click="showPreview = false" class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:ml-3 sm:w-auto sm:text-sm font-kanit">
              ตกลง
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import dayjs from 'dayjs'
import 'dayjs/locale/th'
import buddhistEra from 'dayjs/plugin/buddhistEra'
import { useToast } from '~/composables/useToast'

dayjs.locale('th')
dayjs.extend(buddhistEra)

const route = useRoute()
const router = useRouter()
const { $api } = useNuxtApp()
const { toast } = useToast()

const bookingId = route.params.id
const documentType = ref('tax')
const isLoading = ref(true)
const isSubmitting = ref(false)
const showPreview = ref(false)

// Canvas/Signature State
const signatureCanvas = ref(null)
const signatureImage = ref('')
const isDrawing = ref(false)
let ctx = null

const form = reactive({
  driverName: '',
  taxId: '',
  nationalId: '',
  driverAddress: '',
  passengerName: '',
  passengerId: '',
  docNumber: '',
  docDate: dayjs().format('D MMMM BBBB'),
  items: [
    { description: 'ค่าเดินทาง', amount: 0 }
  ],
  taxTotal: 0
})

const totalAmount = computed(() => {
  return form.items.reduce((sum, item) => sum + (Number(item.amount) || 0), 0)
})

const taxBase = ref(0)
const taxVat = ref(0)

const calculateTax = () => {
  const total = Number(form.taxTotal) || 0
  taxBase.value = total / 1.07
  taxVat.value = total - taxBase.value
}

const calculateTotal = () => {
  // Triggered via v-model or @input if needed
}

const addItem = () => {
  form.items.push({ description: '', amount: 0 })
}

const removeItem = (index) => {
  form.items.splice(index, 1)
}

// Drawing Logic
const startDrawing = (e) => {
  isDrawing.value = true
  ctx = signatureCanvas.value.getContext('2d')
  ctx.beginPath()
  const { x, y } = getCoord(e)
  ctx.moveTo(x, y)
}

const draw = (e) => {
  if (!isDrawing.value) return
  if (e.cancelable) e.preventDefault()
  const { x, y } = getCoord(e)
  ctx.lineTo(x, y)
  ctx.stroke()
}

const stopDrawing = () => {
  if (!isDrawing.value) return
  isDrawing.value = false
  signatureImage.value = signatureCanvas.value.toDataURL()
}

const getCoord = (e) => {
  const canvas = signatureCanvas.value
  const rect = canvas.getBoundingClientRect()
  const clientX = e.touches ? e.touches[0].clientX : e.clientX
  const clientY = e.touches ? e.touches[0].clientY : e.clientY
  
  const x = (clientX - rect.left) * (canvas.width / rect.width)
  const y = (clientY - rect.top) * (canvas.height / rect.height)
  return { x, y }
}

const clearSignature = () => {
  const canvas = signatureCanvas.value
  const context = canvas.getContext('2d')
  context.clearRect(0, 0, canvas.width, canvas.height)
  signatureImage.value = ''
}

const generateDocNumber = () => {
  const prefix = documentType.value === 'tax' ? 'TAX' : 'RV'
  const dateStr = dayjs().format('YYYY/MM')
  const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0')
  form.docNumber = `${prefix}-${dateStr}-${random}`
}

watch(documentType, () => {
  generateDocNumber()
})

const fetchInitialData = async () => {
  isLoading.value = true
  try {
    const booking = await $api(`/bookings/${bookingId}`)
    const user = await $api('/users/me')
    const verification = await $api('/driver-verifications/me').catch(() => null)

    form.driverName = `${user.firstName || ''} ${user.lastName || ''}`.trim()
    form.driverAddress = '' 
    
    if (verification) {
      form.nationalId = verification.nationalIdNumber || ''
      // If taxId isn't in verification, we leave it for driver to input
    }

    form.passengerName = `${booking.passenger?.firstName || ''} ${booking.passenger?.lastName || ''}`.trim()
    form.passengerId = booking.passengerId
    
    const bookingPrice = (booking.route?.pricePerSeat || 0) * (booking.numberOfSeats || 1)
    form.taxTotal = bookingPrice
    form.items[0].amount = bookingPrice
    
    calculateTax()
    generateDocNumber()

    nextTick(() => {
      if (signatureCanvas.value) {
        const canvas = signatureCanvas.value
        canvas.width = canvas.offsetWidth
        canvas.height = canvas.offsetHeight
        ctx = canvas.getContext('2d')
        ctx.strokeStyle = '#000000'
        ctx.lineWidth = 2
        ctx.lineCap = 'round'
      }
    })

  } catch (error) {
    console.error('Failed to fetch data:', error)
    toast.error('โอ๊ะโอ!', 'ไม่สามารถดึงข้อมูลการจองได้')
    router.back()
  } finally {
    isLoading.value = false
  }
}

const handleSubmit = async () => {
  if (!signatureImage.value) {
    toast.warning('ขาดข้อมูล!', 'กรุณาลงลายมือชื่อก่อนส่งเอกสาร')
    return
  }

  isSubmitting.value = true
  
  const payload = {
    bookingId,
    documentType: documentType.value,
    metadata: {
      docNumber: form.docNumber,
      issuedAt: new Date().toISOString()
    },
    issuer: {
      name: form.driverName,
      taxId: documentType.value === 'tax' ? form.taxId : null,
      nationalId: documentType.value === 'receipt' ? form.nationalId : null,
      address: form.driverAddress
    },
    customer: {
      id: form.passengerId,
      name: form.passengerName
    },
    financials: documentType.value === 'tax' ? {
      total: form.taxTotal,
      vat: taxVat.value,
      base: taxBase.value
    } : {
      items: form.items,
      total: totalAmount.value
    },
    signature: signatureImage.value
  }

  console.log('Generating Document JSON:', payload)

  try {
    // For demo/prototype: Save document to localStorage so passenger can see it
    if (typeof window !== 'undefined') {
      localStorage.setItem(`doc_${bookingId}`, JSON.stringify(payload))
    }

    await new Promise(resolve => setTimeout(resolve, 1500))
    toast.success('สำเร็จ!', 'ออกเอกสารและส่งให้ผู้โดยสารเรียบร้อยแล้ว')
    router.back()
  } catch (err) {
    toast.error('เกิดข้อผิดพลาด', 'ไม่สามารถส่งเอกสารได้ในขณะนี้')
  } finally {
    isSubmitting.value = false
  }
}

onMounted(() => {
  fetchInitialData()
})
</script>

<style scoped>
.font-kanit {
  font-family: 'Kanit', sans-serif;
}
canvas {
  image-rendering: -moz-crisp-edges;
  image-rendering: -webkit-optimize-contrast;
  image-rendering: crisp-edges;
  -ms-interpolation-mode: nearest-neighbor;
}
@media print {
  .no-print {
    display: none !important;
  }
}
</style>
