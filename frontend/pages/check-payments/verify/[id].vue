<template>
  <div class="min-h-screen py-8 bg-gray-50">
    <div class="px-4 mx-auto max-w-7xl sm:px-6 lg:px-8">
      <div class="grid grid-cols-1 gap-6 mt-6 md:grid-cols-12">
        <div class="md:col-span-4 lg:col-span-3">
          <div class="mb-4">
            <h4 class="mb-2 text-sm font-bold text-gray-800">หลักฐาน</h4>
            <div class="relative flex items-center justify-center w-full h-48 mb-3 overflow-hidden border-2 border-gray-300 border-dashed rounded-lg bg-gray-50">
              <img v-if="evidenceUrl && isSelectedEvidenceImage" :src="evidenceUrl" class="object-contain w-full h-full" alt="Payment evidence" />
              <div v-else-if="selectedEvidenceFile" class="px-4 text-center text-gray-500">
                <p class="font-semibold text-gray-700">{{ evidenceDisplayName(selectedEvidenceFile, selectedEvidenceIndex) }}</p>
                <p class="text-xs mt-1">{{ selectedEvidenceFile.mimeType || 'Unknown file type' }}</p>
              </div>
              <div v-else class="text-center text-gray-400">ไม่มีไฟล์หลักฐาน</div>
            </div>

            <div v-if="evidenceFiles.length" class="space-y-2">
              <p class="text-xs font-semibold text-gray-700">ไฟล์แนบหลักฐาน ({{ evidenceFiles.length }})</p>
              <div
                v-for="(file, index) in evidenceFiles"
                :key="file.id || file.fileUrl || index"
                :class="[
                  'p-2 rounded-md border text-xs bg-white',
                  index === selectedEvidenceIndex ? 'border-blue-500' : 'border-gray-200'
                ]"
              >
                <p class="font-semibold text-gray-800 truncate">{{ evidenceDisplayName(file, index) }}</p>
                <p class="text-gray-500 truncate">{{ file.mimeType || 'Unknown type' }}{{ file.fileSizeBytes ? ` • ${formatFileSize(file.fileSizeBytes)}` : '' }}</p>
                <div class="mt-2 flex gap-2">
                  <button
                    type="button"
                    @click="viewEvidence(file, index)"
                    class="px-2 py-1 rounded border border-blue-200 text-blue-700 hover:bg-blue-50"
                  >
                    ดูไฟล์
                  </button>
                  <button
                    type="button"
                    @click="downloadEvidence(file, index)"
                    class="px-2 py-1 rounded border border-gray-300 text-gray-700 hover:bg-gray-50"
                  >
                    ดาวน์โหลด
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div v-if="status === 'PROOF_SUBMITTED'" class="space-y-3">
            <button
              @click="confirmPayment"
              :disabled="isSubmitting"
              class="w-full px-6 py-2.5 font-bold text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:bg-blue-300"
            >
              ยืนยันหลักฐาน
            </button>
            <button
              @click="rejectPayment"
              :disabled="isSubmitting"
              class="w-full px-6 py-2.5 font-bold text-white bg-red-600 rounded-md hover:bg-red-700 disabled:bg-red-300"
            >
              ปฏิเสธหลักฐาน
            </button>
          </div>
          <button
            v-else
            @click="goBack"
            class="w-full px-6 py-2.5 font-bold text-white bg-gray-600 rounded-md hover:bg-gray-700"
          >
            กลับ
          </button>
        </div>

        <div class="md:col-span-8 lg:col-span-9">
          <h4 class="mb-2 text-sm font-bold text-gray-800">รายละเอียด</h4>

          <div v-if="successMessage" class="p-3 mb-4 text-sm text-green-700 border border-green-200 rounded-md bg-green-50">
            {{ successMessage }}
          </div>
          <div v-if="errorMessage" class="p-3 mb-4 text-sm text-red-600 border border-red-200 rounded-md bg-red-50">
            {{ errorMessage }}
          </div>

          <div class="p-6 mb-6 space-y-4 bg-white border border-gray-200 rounded-xl">
            <div class="grid grid-cols-1 gap-4">
              <div>
                <label class="block mb-1 text-sm font-semibold text-gray-700">วิธีที่ผู้โดยสารแจ้ง</label>
                <input :value="declaredPaymentMethod" type="text" disabled class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-100" />
              </div>
              <div>
                <label class="block mb-1 text-sm font-semibold text-gray-700">วิธีรับเงินจริงที่คนขับยืนยัน</label>
                <select
                  v-model="verifiedPaymentMethod"
                  :disabled="status !== 'PROOF_SUBMITTED'"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:border-blue-500 disabled:bg-gray-100"
                >
                  <option value="CASH">เงินสด (CASH)</option>
                  <option value="PROMPTPAY">PromptPay</option>
                  <option value="BANK_TRANSFER">โอนธนาคาร</option>
                  <option value="CARD">บัตรเครดิต/เดบิต</option>
                  <option value="OTHER">อื่นๆ</option>
                </select>
              </div>
            </div>

            <div class="grid grid-cols-1 gap-4">
              <div>
                <label class="block mb-1 text-sm font-semibold text-gray-700">เลขอ้างอิง</label>
                <input :value="referenceNo || '-'" type="text" disabled class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-100" />
              </div>
              <div>
                <label class="block mb-1 text-sm font-semibold text-gray-700">เวลาโอน/จ่าย</label>
                <input :value="paidAtText" type="text" disabled class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-100" />
              </div>
            </div>

            <div>
              <label class="block mb-1 text-sm font-semibold text-gray-700">หมายเหตุจากผู้โดยสาร</label>
              <textarea :value="note || '-'" rows="2" disabled class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-100" />
            </div>

            <div v-if="status === 'PROOF_SUBMITTED' && verifiedPaymentMethod !== declaredPaymentMethod">
              <label class="block mb-1 text-sm font-semibold text-gray-700">เหตุผลเมื่อวิธีชำระไม่ตรงกัน <span class="text-red-500">*</span></label>
              <textarea v-model="methodMismatchReason" rows="2" class="w-full px-3 py-2 border border-gray-300 rounded-md" />
            </div>

            <div v-if="status === 'PROOF_SUBMITTED'" class="pt-2">
              <label class="block mb-1 text-sm font-semibold text-gray-700">เหตุผลกรณีปฏิเสธหลักฐาน</label>
              <textarea v-model="rejectReason" rows="2" class="w-full px-3 py-2 border border-gray-300 rounded-md" placeholder="ใส่เมื่อกดปฏิเสธ" />
            </div>

            <div class="flex justify-between pt-4 mt-4 text-gray-800 border-t">
              <span>รวม</span>
              <span class="font-bold">{{ Number(amount || 0).toLocaleString() }} บาท</span>
            </div>
          </div>

          <div class="p-6 mb-6 space-y-4 bg-white border border-gray-200 rounded-xl">
            <h4 class="text-sm font-bold text-gray-800">ออกเอกสารการเงิน</h4>

            <div class="grid grid-cols-1 gap-4">
              <div>
                <label class="block mb-1 text-sm font-semibold text-gray-700">ประเภทเอกสาร</label>
                <select
                  v-model="documentType"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:border-blue-500"
                >
                  <option value="TAX_INVOICE">ใบกำกับภาษี (TAX_INVOICE)</option>
                  <option value="PAYMENT_VOUCHER">ใบสำคัญรับเงิน (PAYMENT_VOUCHER)</option>
                </select>
              </div>
            </div>
            <div
              v-if="hasRequestedDocumentType"
              :class="[
                'rounded-md border p-3 text-sm',
                isRequestedDocumentMismatch
                  ? 'border-amber-300 bg-amber-50 text-amber-900'
                  : 'border-emerald-300 bg-emerald-50 text-emerald-900'
              ]"
            >
              <p>
                Passenger requested:
                <span class="font-semibold">{{ requestedDocumentTypesLabel }}</span>
              </p>
              <p v-if="isRequestedDocumentMismatch" class="mt-1 text-xs">
                Selected type is different from passenger request.
              </p>
            </div>
            <div v-if="documentType === 'TAX_INVOICE'" class="rounded-md border border-blue-200 bg-blue-50 p-3 text-sm text-blue-900">
              <p class="font-semibold">VAT is auto-calculated from paid amount (VAT included 7%)</p>
              <div class="mt-2 grid grid-cols-1 gap-1 md:grid-cols-3">
                <p>Gross amount: <span class="font-bold">{{ formatCurrency(autoTaxSummary.total) }}</span> THB</p>
                <p>Tax base: <span class="font-bold">{{ formatCurrency(autoTaxSummary.base) }}</span> THB</p>
                <p>VAT 7%: <span class="font-bold">{{ formatCurrency(autoTaxSummary.vat) }}</span> THB</p>
              </div>
            </div>


            <div>
              <label class="block mb-1 text-sm font-semibold text-gray-700">หมายเหตุในเอกสาร</label>
              <textarea
                v-model="documentNote"
                rows="2"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:border-blue-500"
                placeholder="เช่น issued by driver"
              />
            </div>

            <div class="flex flex-wrap items-center gap-3">
              <button
                @click="issueDocument"
                :disabled="isIssuingDocument || status !== 'CONFIRMED' || isSelectedDocumentAlreadyIssued"
                class="px-6 py-2.5 font-bold text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:bg-blue-300"
              >
                {{ isIssuingDocument ? 'กำลังออกเอกสาร...' : 'ออกเอกสาร' }}
              </button>
              <span v-if="status !== 'CONFIRMED'" class="text-xs text-amber-700">ต้องยืนยันหลักฐานก่อน จึงจะออกเอกสารได้</span>
              <span v-else-if="isSelectedDocumentAlreadyIssued" class="text-xs text-amber-700">เอกสารประเภทนี้ถูกออกแล้ว</span>
            </div>

            <div v-if="documents.length" class="pt-3 border-t border-gray-200">
              <p class="mb-2 text-sm font-semibold text-gray-800">เอกสารที่ออกแล้ว</p>
              <div class="space-y-2">
                <div v-for="doc in documents" :key="doc.id" class="flex flex-col px-3 py-2 text-sm bg-gray-50 border border-gray-200 rounded-md sm:flex-row sm:items-center sm:justify-between">
                  <div class="text-gray-800">
                    <span class="font-semibold">{{ documentTypeLabel(doc.documentType) }}</span>
                    <span class="mx-2 text-gray-400">|</span>
                    <span class="font-mono">{{ doc.documentNumber }}</span>
                  </div>
                  <div class="text-xs text-gray-500">ออกเมื่อ {{ formatDateTime(doc.issuedAt) }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div
      v-if="showTaxProfileModal"
      class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/40 backdrop-blur-sm"
      @click.self="closeTaxProfileModal"
    >
      <div class="w-full max-w-2xl bg-white rounded-2xl shadow-xl border border-gray-200 overflow-hidden">
        <div class="p-5 border-b border-gray-200 flex items-center justify-between">
          <h3 class="text-lg font-bold text-gray-900">กรอกข้อมูลภาษีครั้งแรก</h3>
          <button class="text-gray-400 hover:text-gray-600" @click="closeTaxProfileModal" :disabled="isSavingTaxProfile">✕</button>
        </div>

        <div class="p-5 space-y-4">
          <p class="text-sm text-gray-600">ระบบต้องมีข้อมูลผู้เสียภาษีของคนขับก่อนออกใบกำกับภาษี</p>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block mb-1 text-sm font-semibold text-gray-700">ประเภทผู้เสียภาษี</label>
              <select v-model="taxProfile.taxpayerType" class="w-full px-3 py-2 border border-gray-300 rounded-md">
                <option value="INDIVIDUAL">บุคคลธรรมดา</option>
                <option value="COMPANY">นิติบุคคล/บริษัท</option>
              </select>
            </div>
            <div>
              <label class="block mb-1 text-sm font-semibold text-gray-700">ชื่อผู้เสียภาษี <span class="text-red-500">*</span></label>
              <input v-model="taxProfile.taxpayerName" type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md" />
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block mb-1 text-sm font-semibold text-gray-700">เลขผู้เสียภาษี 13 หลัก <span class="text-red-500">*</span></label>
              <input v-model="taxProfile.taxId" type="text" maxlength="13" class="w-full px-3 py-2 border border-gray-300 rounded-md" />
            </div>
            <div class="space-y-2">
              <label class="inline-flex items-center gap-2 text-sm text-gray-700">
                <input v-model="taxProfile.isHeadOffice" type="checkbox" class="rounded border-gray-300" />
                สำนักงานใหญ่
              </label>
              <div>
                <label class="block mb-1 text-sm font-semibold text-gray-700">รหัสสาขา</label>
                <input v-model="taxProfile.branchCode" type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md" :disabled="taxProfile.isHeadOffice" />
              </div>
            </div>
          </div>

          <div>
            <label class="block mb-1 text-sm font-semibold text-gray-700">ที่อยู่ตามทะเบียนภาษี <span class="text-red-500">*</span></label>
            <textarea v-model="taxProfile.taxAddress" rows="2" class="w-full px-3 py-2 border border-gray-300 rounded-md" />
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block mb-1 text-sm font-semibold text-gray-700">อีเมล</label>
              <input v-model="taxProfile.email" type="email" class="w-full px-3 py-2 border border-gray-300 rounded-md" />
            </div>
            <div>
              <label class="block mb-1 text-sm font-semibold text-gray-700">เบอร์โทร</label>
              <input v-model="taxProfile.phoneNumber" type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md" />
            </div>
          </div>

          <div class="pt-2 flex gap-3 justify-end">
            <button
              class="px-4 py-2 rounded-md border border-gray-300 text-gray-700 hover:bg-gray-50"
              @click="closeTaxProfileModal"
              :disabled="isSavingTaxProfile"
            >
              ยกเลิก
            </button>
            <button
              class="px-5 py-2 rounded-md text-white bg-blue-600 hover:bg-blue-700 disabled:bg-blue-300"
              @click="saveTaxProfileAndContinue"
              :disabled="isSavingTaxProfile"
            >
              {{ isSavingTaxProfile ? 'กำลังบันทึก...' : 'บันทึกและออกใบกำกับภาษี' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

definePageMeta({ middleware: 'auth' })

const { $api } = useNuxtApp()
const route = useRoute()
const router = useRouter()

const isSubmitting = ref(false)
const isIssuingDocument = ref(false)
const isSavingTaxProfile = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

const status = ref('')
const amount = ref(0)
const declaredPaymentMethod = ref('')
const verifiedPaymentMethod = ref('')
const methodMismatchReason = ref('')
const rejectReason = ref('')
const referenceNo = ref('')
const note = ref('')
const paidAtText = ref('')
const evidenceUrl = ref('')
const evidenceFiles = ref([])
const selectedEvidenceIndex = ref(0)
const documents = ref([])
const requestedDocumentTypes = ref([])

const documentType = ref('TAX_INVOICE')
const documentNote = ref('issued by driver')

const showTaxProfileModal = ref(false)
const shouldIssueAfterTaxProfile = ref(false)
const driverDisplayName = ref('')
const loadedTaxpayerName = ref('')
const taxProfile = reactive({
  taxpayerType: 'INDIVIDUAL',
  taxpayerName: '',
  taxId: '',
  branchCode: '',
  isHeadOffice: true,
  taxAddress: '',
  email: '',
  phoneNumber: '',
})

const confirmationId = route.params.id
const documentTypeOrder = ['TAX_INVOICE', 'PAYMENT_VOUCHER']

const issuedDocumentTypeSet = computed(() => new Set(documents.value.map(d => d.documentType)))
const isSelectedDocumentAlreadyIssued = computed(() => issuedDocumentTypeSet.value.has(documentType.value))
const hasRequestedDocumentType = computed(() => requestedDocumentTypes.value.length > 0)
const isRequestedDocumentMismatch = computed(() => (
  hasRequestedDocumentType.value &&
  !requestedDocumentTypes.value.includes(documentType.value)
))
const requestedDocumentTypesLabel = computed(() => {
  if (!requestedDocumentTypes.value.length) return '-'
  return requestedDocumentTypes.value.map((type) => documentTypeLabel(type)).join(', ')
})
const roundCurrency = (value) => Math.round((Number(value || 0) + Number.EPSILON) * 100) / 100
const formatCurrency = (value) => Number(value || 0).toLocaleString('th-TH', {
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
})

const nextAvailableDocumentType = (preferredTypes = []) => {
  const preferredList = Array.isArray(preferredTypes) ? preferredTypes : []
  const preferred = preferredList.find(
    (type) => documentTypeOrder.includes(type) && !issuedDocumentTypeSet.value.has(type)
  )
  if (preferred) return preferred
  const nextType = documentTypeOrder.find(type => !issuedDocumentTypeSet.value.has(type))
  return nextType || documentType.value || 'TAX_INVOICE'
}

const autoTaxSummary = computed(() => {
  const total = roundCurrency(amount.value)
  const base = roundCurrency(total / 1.07)
  const vat = roundCurrency(total - base)
  return { total, base, vat }
})

const selectedEvidenceFile = computed(() => evidenceFiles.value[selectedEvidenceIndex.value] || null)

const isImageEvidence = (file) => {
  const mime = String(file?.mimeType || '').toLowerCase()
  const url = String(file?.fileUrl || '').toLowerCase()
  return mime.startsWith('image/') || /\.(png|jpe?g|gif|webp|bmp|svg)$/.test(url)
}

const isSelectedEvidenceImage = computed(() => isImageEvidence(selectedEvidenceFile.value))

const evidenceDisplayName = (file, index = 0) => {
  return String(file?.fileName || '').trim() || `หลักฐาน-${index + 1}`
}

const formatFileSize = (bytes) => {
  const value = Number(bytes || 0)
  if (!Number.isFinite(value) || value <= 0) return '-'
  if (value < 1024) return `${value} B`
  if (value < 1024 * 1024) return `${(value / 1024).toFixed(1)} KB`
  return `${(value / (1024 * 1024)).toFixed(2)} MB`
}

const selectEvidence = (index) => {
  selectedEvidenceIndex.value = index
  evidenceUrl.value = evidenceFiles.value[index]?.fileUrl || ''
}

const viewEvidence = (file, index) => {
  if (!file?.fileUrl) return
  selectEvidence(index)
  if (typeof window !== 'undefined') {
    window.open(file.fileUrl, '_blank', 'noopener,noreferrer')
  }
}

const triggerBrowserDownload = (url, filename) => {
  if (typeof window === 'undefined') return
  const anchor = document.createElement('a')
  anchor.href = url
  anchor.rel = 'noopener noreferrer'
  anchor.download = filename
  document.body.appendChild(anchor)
  anchor.click()
  document.body.removeChild(anchor)
}

const buildForceDownloadUrl = (rawUrl, filename) => {
  try {
    const url = new URL(rawUrl)

    if (url.hostname.includes('res.cloudinary.com') && url.pathname.includes('/upload/')) {
      url.pathname = url.pathname.replace('/upload/', '/upload/fl_attachment/')
      if (filename) url.searchParams.set('filename', filename)
      return url.toString()
    }

    url.searchParams.set('download', '1')
    return url.toString()
  } catch {
    return rawUrl
  }
}

const downloadEvidence = async (file, index) => {
  if (!file?.fileUrl || typeof window === 'undefined') return
  selectEvidence(index)
  const fileName = evidenceDisplayName(file, index)

  try {
    const response = await fetch(file.fileUrl)
    if (!response.ok) throw new Error(`Download failed with status ${response.status}`)

    const blob = await response.blob()
    const blobUrl = URL.createObjectURL(blob)
    triggerBrowserDownload(blobUrl, fileName)
    setTimeout(() => URL.revokeObjectURL(blobUrl), 1000)
  } catch (error) {
    console.warn('download evidence fallback:', error)
    const forceDownloadUrl = buildForceDownloadUrl(file.fileUrl, fileName)
    window.open(forceDownloadUrl, '_blank', 'noopener,noreferrer')
  }
}

const documentTypeLabel = (type) => {
  if (type === 'TAX_INVOICE') return 'ใบกำกับภาษี'
  if (type === 'PAYMENT_VOUCHER') return 'ใบสำคัญรับเงิน'
  return 'ใบเสร็จรับเงิน'
}

const formatDateTime = (value) => (value ? new Date(value).toLocaleString('th-TH') : '-')

const goBack = () => router.push('/check-payments')

const buildDisplayName = (user) => {
  const fullName = [user?.firstName, user?.lastName].filter(Boolean).join(' ').trim()
  return fullName || user?.username || user?.email || ''
}

const fillTaxProfile = (profile = null) => {
  loadedTaxpayerName.value = profile?.taxpayerName || ''
  taxProfile.taxpayerType = profile?.taxpayerType || 'INDIVIDUAL'
  taxProfile.taxpayerName = profile?.taxpayerName || ''
  taxProfile.taxId = profile?.taxId || ''
  taxProfile.branchCode = profile?.branchCode || ''
  taxProfile.isHeadOffice = profile?.isHeadOffice ?? true
  taxProfile.taxAddress = profile?.taxAddress || ''
  taxProfile.email = profile?.email || ''
  taxProfile.phoneNumber = profile?.phoneNumber || ''
}

const loadConfirmation = async () => {
  try {
    const data = await $api(`/payments/confirmations/${confirmationId}`)
    driverDisplayName.value = buildDisplayName(data?.driver)
    status.value = data?.status || ''
    documents.value = Array.isArray(data?.documents) ? data.documents : []

    const submission = data?.latestSubmission || data?.proofSubmissions?.[0]
    if (!submission) {
      errorMessage.value = 'ไม่พบข้อมูลหลักฐานการชำระเงิน'
      return
    }

    amount.value = Number(submission.amount || data?.paidAmount || data?.expectedAmount || 0)
    declaredPaymentMethod.value = submission.paymentMethod || ''
    verifiedPaymentMethod.value = submission.verifiedPaymentMethod || submission.paymentMethod || 'CASH'
    methodMismatchReason.value = submission.methodMismatchReason || ''
    referenceNo.value = submission.referenceNo || ''
    note.value = submission.note || ''
    const submissionRequestedDocumentTypes = Array.isArray(submission.requestedDocumentTypes)
      ? submission.requestedDocumentTypes
      : (submission.requestedDocumentType
        ? [submission.requestedDocumentType]
        : (submission.isCorporateRequest ? ['TAX_INVOICE'] : []))
    requestedDocumentTypes.value = submissionRequestedDocumentTypes
    paidAtText.value = submission.paidAt ? new Date(submission.paidAt).toLocaleString('th-TH') : '-'
    evidenceFiles.value = Array.isArray(submission?.evidenceFiles) ? submission.evidenceFiles : []
    selectedEvidenceIndex.value = 0
    evidenceUrl.value = evidenceFiles.value[0]?.fileUrl || ''
    documentType.value = nextAvailableDocumentType(requestedDocumentTypes.value)
  } catch (error) {
    console.error('load confirmation failed:', error)
    errorMessage.value = error?.statusMessage || 'ไม่สามารถโหลดข้อมูลการยืนยันการชำระเงินได้'
  }
}

watch(
  () => taxProfile.taxpayerType,
  (nextType, prevType) => {
    if (nextType !== 'INDIVIDUAL' || prevType !== 'COMPANY') return

    const currentName = String(taxProfile.taxpayerName || '').trim()
    const previousLoadedName = String(loadedTaxpayerName.value || '').trim()
    const suggestedIndividualName = String(driverDisplayName.value || '').trim()

    if (!currentName || currentName === previousLoadedName) {
      taxProfile.taxpayerName = suggestedIndividualName || currentName
    }
  }
)

const confirmPayment = async () => {
  errorMessage.value = ''
  successMessage.value = ''

  if (!verifiedPaymentMethod.value) {
    errorMessage.value = 'กรุณาเลือกวิธีรับเงินจริง'
    return
  }

  const isMismatch = verifiedPaymentMethod.value !== declaredPaymentMethod.value
  if (isMismatch && String(methodMismatchReason.value || '').trim().length < 3) {
    errorMessage.value = 'กรุณาระบุเหตุผลเมื่อวิธีชำระไม่ตรงกัน (อย่างน้อย 3 ตัวอักษร)'
    return
  }

  isSubmitting.value = true
  try {
    await $api(`/payments/confirmations/${confirmationId}/confirm`, {
      method: 'POST',
      body: {
        verifiedPaymentMethod: verifiedPaymentMethod.value,
        ...(isMismatch ? { methodMismatchReason: methodMismatchReason.value.trim() } : {}),
      },
    })

    successMessage.value = 'ยืนยันหลักฐานสำเร็จ สามารถออกเอกสารการเงินได้แล้ว'
    await loadConfirmation()
  } catch (error) {
    console.error('confirm payment failed:', error)
    errorMessage.value = error?.statusMessage || 'ยืนยันหลักฐานไม่สำเร็จ'
  } finally {
    isSubmitting.value = false
  }
}

const rejectPayment = async () => {
  errorMessage.value = ''
  successMessage.value = ''

  if (String(rejectReason.value || '').trim().length < 3) {
    errorMessage.value = 'กรุณาระบุเหตุผลการปฏิเสธอย่างน้อย 3 ตัวอักษร'
    return
  }

  isSubmitting.value = true
  try {
    await $api(`/payments/confirmations/${confirmationId}/reject`, {
      method: 'POST',
      body: {
        reason: rejectReason.value.trim(),
      },
    })

    successMessage.value = 'ปฏิเสธหลักฐานสำเร็จ'
    setTimeout(() => goBack(), 900)
  } catch (error) {
    console.error('reject payment failed:', error)
    errorMessage.value = error?.statusMessage || 'ปฏิเสธหลักฐานไม่สำเร็จ'
  } finally {
    isSubmitting.value = false
  }
}

const buildIssuePayload = () => ({
  documentType: documentType.value,
  ...(String(documentNote.value || '').trim() ? { note: documentNote.value.trim() } : {}),
})

const issueDocumentRequest = async () => {
  await $api(`/payments/confirmations/${confirmationId}/documents`, {
    method: 'POST',
    body: buildIssuePayload(),
  })

  successMessage.value = `ออก${documentTypeLabel(documentType.value)}สำเร็จ`
  await loadConfirmation()
}

const closeTaxProfileModal = () => {
  if (isSavingTaxProfile.value) return
  showTaxProfileModal.value = false
  shouldIssueAfterTaxProfile.value = false
}

const openTaxProfileModal = async () => {
  try {
    const profile = await $api('/payments/tax-profile/me')
    fillTaxProfile(profile || null)
  } catch {
    fillTaxProfile(null)
  }

  showTaxProfileModal.value = true
  shouldIssueAfterTaxProfile.value = true
}

const validateTaxProfile = () => {
  if (!String(taxProfile.taxpayerName || '').trim()) return 'กรุณากรอกชื่อผู้เสียภาษี'
  if (!/^\d{13}$/.test(String(taxProfile.taxId || '').trim())) return 'เลขผู้เสียภาษีต้องเป็นตัวเลข 13 หลัก'
  if (!String(taxProfile.taxAddress || '').trim()) return 'กรุณากรอกที่อยู่ตามทะเบียนภาษี'
  if (taxProfile.email && !/^\S+@\S+\.\S+$/.test(String(taxProfile.email))) return 'รูปแบบอีเมลไม่ถูกต้อง'
  return ''
}

const saveTaxProfileAndContinue = async () => {
  errorMessage.value = ''
  successMessage.value = ''

  const invalidMessage = validateTaxProfile()
  if (invalidMessage) {
    errorMessage.value = invalidMessage
    return
  }

  isSavingTaxProfile.value = true
  try {
    await $api('/payments/tax-profile/me', {
      method: 'PUT',
      body: {
        taxpayerType: taxProfile.taxpayerType,
        taxpayerName: String(taxProfile.taxpayerName || '').trim(),
        taxId: String(taxProfile.taxId || '').trim(),
        branchCode: taxProfile.isHeadOffice ? undefined : (String(taxProfile.branchCode || '').trim() || undefined),
        isHeadOffice: !!taxProfile.isHeadOffice,
        taxAddress: String(taxProfile.taxAddress || '').trim(),
        email: String(taxProfile.email || '').trim() || undefined,
        phoneNumber: String(taxProfile.phoneNumber || '').trim() || undefined,
      },
    })

    showTaxProfileModal.value = false
    successMessage.value = 'บันทึกข้อมูลภาษีเรียบร้อย กำลังออกใบกำกับภาษี...'

    if (shouldIssueAfterTaxProfile.value) {
      shouldIssueAfterTaxProfile.value = false
      isIssuingDocument.value = true
      try {
        await issueDocumentRequest()
      } finally {
        isIssuingDocument.value = false
      }
    }
  } catch (error) {
    console.error('save tax profile failed:', error)
    errorMessage.value = error?.statusMessage || 'บันทึกข้อมูลภาษีไม่สำเร็จ'
  } finally {
    isSavingTaxProfile.value = false
  }
}

const issueDocument = async () => {
  errorMessage.value = ''
  successMessage.value = ''

  if (status.value !== 'CONFIRMED') {
    errorMessage.value = 'ต้องยืนยันหลักฐานก่อน จึงจะออกเอกสารได้'
    return
  }
  if (!documentType.value) {
    errorMessage.value = 'กรุณาเลือกประเภทเอกสาร'
    return
  }
  if (isSelectedDocumentAlreadyIssued.value) {
    errorMessage.value = 'เอกสารประเภทนี้ถูกออกแล้ว'
    return
  }

  if (documentType.value === 'TAX_INVOICE') {
    try {
      const profile = await $api('/payments/tax-profile/me')
      if (!profile) {
        await openTaxProfileModal()
        return
      }
    } catch (error) {
      const message = String(error?.statusMessage || error?.data?.message || '')
      if (/tax profile/i.test(message) || /not found/i.test(message)) {
        await openTaxProfileModal()
        return
      }
      throw error
    }
  }

  isIssuingDocument.value = true
  try {
    await issueDocumentRequest()
  } catch (error) {
    const message = String(error?.statusMessage || error?.data?.message || '')
    if (documentType.value === 'TAX_INVOICE' && /tax profile/i.test(message)) {
      await openTaxProfileModal()
      return
    }

    console.error('issue document failed:', error)
    errorMessage.value = error?.statusMessage || 'ออกเอกสารไม่สำเร็จ'
  } finally {
    isIssuingDocument.value = false
  }
}

onMounted(loadConfirmation)
</script>

