<template>
  <div class="document-page min-h-screen bg-zinc-100 py-8 px-4 sm:px-6 lg:px-8">
    <div class="document-shell max-w-5xl mx-auto space-y-4">
      <div class="flex w-full items-center gap-3 print-hidden">
        <button @click="$router.back()" class="text-sm font-medium text-blue-700 hover:text-blue-600">← ย้อนกลับ</button>
        <button @click="printDocument" class="ml-auto px-5 py-2.5 bg-blue-600 text-white rounded-md text-sm font-semibold hover:bg-blue-700">
          พิมพ์เอกสาร / PDF
        </button>
      </div>

      <div v-if="isLoading" class="bg-white border border-zinc-300 rounded-md p-10 text-center text-zinc-500">
        กำลังโหลดเอกสาร...
      </div>

      <div v-else-if="errorMessage" class="bg-white border border-red-300 rounded-md p-8 text-center text-red-700">
        {{ errorMessage }}
      </div>

      <div v-else-if="!activeDocument" class="bg-white border border-zinc-300 rounded-md p-8 text-center text-zinc-500">
        ยังไม่มีเอกสารการเงินสำหรับรายการนี้
      </div>

      <div v-else class="space-y-4">
        <div v-if="sortedDocuments.length > 1" class="bg-white border border-zinc-300 rounded-md px-4 py-3 print-hidden">
          <p class="text-xs text-zinc-500 mb-2">เลือกประเภทเอกสาร</p>
          <div class="flex flex-wrap gap-2">
            <button
              v-for="doc in sortedDocuments"
              :key="doc.id"
              @click="selectDocument(doc.id)"
              :class="[
                'px-3 py-1.5 rounded-md border text-sm transition-colors',
                activeDocument.id === doc.id
                  ? 'bg-blue-600 text-white border-blue-600'
                  : 'bg-white text-blue-700 border-blue-200 hover:bg-blue-50'
              ]"
            >
              {{ titleByType(doc.documentType) }}
            </button>
          </div>
        </div>

        <article
          v-if="activeDocument.documentType === 'PAYMENT_VOUCHER'"
          class="print-one-page voucher-paper bg-white border border-black screen-shadow p-6 sm:p-8"
        >
          <header class="text-center mb-4">
            <h1 class="text-xl font-bold tracking-wide">ใบสำคัญรับเงิน</h1>
          </header>

          <section class="text-sm text-black leading-7 space-y-1">
            <div class="flex justify-end gap-8">
              <p>เลขที่ <span class="inline-block border-b border-black min-w-[140px] px-1">{{ activeDocument.documentNumber || '-' }}</span></p>
              <p>วันที่ <span class="inline-block border-b border-black min-w-[140px] px-1">{{ formatDate(activeDocument.issuedAt) }}</span></p>
            </div>

            <p>
              ข้าพเจ้า
              <span class="inline-block border-b border-black min-w-[240px] px-1">{{ activeDocument.payeeName || '-' }}</span>
              (ผู้ขายสินค้า / ผู้รับจ้าง)
            </p>

            <p>
              อยู่บ้านเลขที่
              <span class="inline-block border-b border-black min-w-[140px] px-1">{{ normalizeText(activeDocument.payeeAddress) }}</span>
            </p>

            <p>
              ได้รับเงินจาก
              <span class="inline-block border-b border-black min-w-[240px] px-1">{{ activeDocument.payerName || '-' }}</span>
            </p>

            <p>
              เป็นเงินจำนวน
              <span class="inline-block border-b border-black min-w-[160px] px-1 text-right">{{ formatMoney(totalAmount) }}</span>
              บาท
              ({{ toThaiBahtText(totalAmount) }})
            </p>
          </section>

          <section class="mt-4 border border-black">
            <table class="w-full text-sm border-collapse voucher-table">
              <thead>
                <tr>
                  <th class="border border-black p-1.5 w-[62%]">รายการ</th>
                  <th class="border border-black p-1.5 text-center" colspan="2">จำนวนเงิน</th>
                </tr>
                <tr>
                  <th class="border border-black p-1.5"></th>
                  <th class="border border-black p-1.5 w-[19%] text-center">บาท</th>
                  <th class="border border-black p-1.5 w-[19%] text-center">สต.</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, index) in voucherRows" :key="index">
                  <td class="border border-black p-1.5 h-7">{{ row.description }}</td>
                  <td class="border border-black p-1.5 h-7 text-right">{{ row.baht }}</td>
                  <td class="border border-black p-1.5 h-7 text-right">{{ row.satang }}</td>
                </tr>
                <tr>
                  <td class="border border-black p-1.5 text-right font-semibold">รวมเป็นเงิน</td>
                  <td class="border border-black p-1.5 text-right font-semibold">{{ splitBahtSatang(totalAmount).baht }}</td>
                  <td class="border border-black p-1.5 text-right font-semibold">{{ splitBahtSatang(totalAmount).satang }}</td>
                </tr>
              </tbody>
            </table>
          </section>

          <section class="mt-4 text-sm text-black leading-7">
            <p>
              จำนวนเงิน (ตัวอักษร)
              <span class="inline-block border-b border-black min-w-[320px] px-1">{{ toThaiBahtText(totalAmount) }}</span>
            </p>

            <div class="grid grid-cols-2 gap-8 mt-6">
              <div class="text-center">
                <p>ผู้จ่ายเงิน</p>
                <div class="mt-8 border-b border-black"></div>
                <p class="mt-1">({{ activeDocument.payerName || '-' }})</p>
              </div>
              <div class="text-center">
                <p>ผู้รับเงิน</p>
                <div class="mt-8 border-b border-black"></div>
                <p class="mt-1">({{ activeDocument.payeeName || '-' }})</p>
              </div>
            </div>
          </section>
        </article>

        <article v-else class="ticket-wrapper print-one-page">
          <div class="ticket-paper bg-white border border-zinc-300 screen-shadow overflow-hidden">
            <div class="ticket-corner"></div>

            <header class="px-5 pt-5 pb-3 border-b border-zinc-300 text-center">
              <div class="flex items-center justify-center gap-2 mb-1">
                <div class="w-2.5 h-2.5 rounded-full bg-slate-700"></div>
                <p class="font-semibold text-zinc-700 text-xs tracking-widest">PAI-NUM-NAE</p>
              </div>
              <h1 class="text-lg font-bold text-zinc-900">
                {{ activeDocument.documentType === 'TAX_INVOICE' ? 'ใบกำกับภาษีอย่างย่อ' : 'ใบเสร็จรับเงิน' }}
              </h1>
              <p class="text-[11px] text-zinc-600 uppercase tracking-wide">
                {{ activeDocument.documentType === 'TAX_INVOICE' ? 'Abbreviated Tax Invoice' : 'Receipt' }}
              </p>
            </header>

            <section class="px-5 py-3 text-[12px] leading-5 text-zinc-800 border-b border-zinc-300">
              <div
                :class="[
                  'rounded border p-2.5 text-center leading-4',
                  activeDocument.documentType === 'TAX_INVOICE' ? 'border-sky-400 bg-sky-50' : 'border-zinc-300 bg-zinc-50'
                ]"
              >
                <p class="font-semibold">{{ activeDocument.payeeName || 'ไปนำแหน่' }}</p>
                <p>{{ normalizeText(activeDocument.payeeAddress) }}</p>
                <p>
                  เลขประจำตัวผู้เสียภาษี:
                  {{ activeDocument.payeeTaxId || '-' }}
                </p>
              </div>

              <div class="mt-3 space-y-1.5">
                <p class="flex justify-between gap-2 border-b border-zinc-300 pb-1">
                  <span class="text-zinc-600">เลขที่เอกสาร</span>
                  <span class="font-semibold">{{ activeDocument.documentNumber || '-' }}</span>
                </p>
                <p class="flex justify-between gap-2 border-b border-zinc-300 pb-1">
                  <span class="text-zinc-600">วันที่ออกเอกสาร</span>
                  <span class="font-semibold">{{ formatDate(activeDocument.issuedAt) }}</span>
                </p>
                <p class="flex justify-between gap-2 border-b border-zinc-300 pb-1">
                  <span class="text-zinc-600">ลูกค้า</span>
                  <span class="font-semibold text-right">{{ activeDocument.payerName || '-' }}</span>
                </p>
              </div>
            </section>

            <section class="px-5 py-3 text-[12px]">
              <table class="w-full text-[12px]">
                <thead>
                  <tr class="border-b border-zinc-400">
                    <th class="text-left pb-1 font-semibold">รายการ</th>
                    <th class="text-right pb-1 font-semibold">จำนวนเงิน</th>
                  </tr>
                </thead>
                <tbody>
                  <tr class="border-b border-zinc-200">
                    <td class="py-1.5">ค่าบริการเดินทาง</td>
                    <td class="py-1.5 text-right">{{ formatMoney(subtotalAmount) }}</td>
                  </tr>
                  <tr v-if="taxAmountNumber > 0" class="border-b border-zinc-200">
                    <td class="py-1.5">ภาษีมูลค่าเพิ่ม</td>
                    <td class="py-1.5 text-right">{{ formatMoney(taxAmountNumber) }}</td>
                  </tr>
                  <tr class="font-semibold border-b border-zinc-300">
                    <td class="py-1.5">จำนวนเงินรวม</td>
                    <td class="py-1.5 text-right">{{ formatMoney(totalAmount) }}</td>
                  </tr>
                </tbody>
              </table>

              <div class="mt-3 space-y-1 text-[11px] text-zinc-700">
                <p class="flex justify-between gap-2">
                  <span>จำนวนเงินตัวอักษร</span>
                  <span class="text-right">{{ toThaiBahtText(totalAmount) }}</span>
                </p>
                <p class="flex justify-between gap-2">
                  <span>วิธีชำระเงิน</span>
                  <span>{{ paymentMethodLabel(activeDocument.paymentMethod) }}</span>
                </p>
                <p class="flex justify-between gap-2">
                  <span>เลขอ้างอิง</span>
                  <span>{{ activeDocument.referenceNo || '-' }}</span>
                </p>
              </div>
            </section>

            <footer class="px-5 pt-3 pb-4 border-t border-zinc-300 text-center text-[11px] text-zinc-600">
              <p v-if="activeDocument.documentType === 'TAX_INVOICE'" class="font-semibold">VAT INCLUDED</p>
              <p>ใบเสร็จฉบับอิเล็กทรอนิกส์จากระบบไปนำแหน่</p>
            </footer>
          </div>
        </article>

        <div v-if="activeDocument.templateData" class="bg-white border border-zinc-300 rounded-md p-4 text-sm text-zinc-700 print-hidden">
          <p class="font-semibold text-zinc-900 mb-2">บันทึกการตรวจสอบการชำระเงิน</p>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-2">
            <p><span class="font-medium">วิธีที่ผู้โดยสารแจ้ง:</span> {{ paymentMethodLabel(activeDocument.templateData.declaredPaymentMethod) }}</p>
            <p><span class="font-medium">วิธีที่คนขับยืนยัน:</span> {{ paymentMethodLabel(activeDocument.templateData.verifiedPaymentMethod || activeDocument.paymentMethod) }}</p>
            <p class="md:col-span-2"><span class="font-medium">เหตุผลกรณีวิธีชำระไม่ตรงกัน:</span> {{ activeDocument.templateData.methodMismatchReason || '-' }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'

definePageMeta({ middleware: 'auth' })

const { $api } = useNuxtApp()
const route = useRoute()

const isLoading = ref(true)
const errorMessage = ref('')
const documents = ref([])
const selectedDocumentId = ref('')

const documentTypeWeight = {
  RECEIPT: 0,
  PAYMENT_VOUCHER: 1,
  TAX_INVOICE: 2,
}

const sortedDocuments = computed(() => {
  return [...documents.value].sort((a, b) => {
    const byType = (documentTypeWeight[a.documentType] ?? 99) - (documentTypeWeight[b.documentType] ?? 99)
    if (byType !== 0) return byType

    const timeA = new Date(a.issuedAt || 0).getTime()
    const timeB = new Date(b.issuedAt || 0).getTime()
    return timeB - timeA
  })
})

const activeDocument = computed(() => {
  return sortedDocuments.value.find((doc) => doc.id === selectedDocumentId.value) || sortedDocuments.value[0] || null
})

const subtotalAmount = computed(() => Number(activeDocument.value?.subtotal || 0))
const taxAmountNumber = computed(() => Number(activeDocument.value?.taxAmount || 0))
const totalAmount = computed(() => Number(activeDocument.value?.totalAmount || 0))

const selectDocument = (id) => {
  selectedDocumentId.value = id
}

const titleByType = (type) => {
  if (type === 'TAX_INVOICE') return 'ใบกำกับภาษีอย่างย่อ'
  if (type === 'PAYMENT_VOUCHER') return 'ใบสำคัญรับเงิน'
  return 'ใบเสร็จรับเงิน'
}

const paymentMethodLabel = (method) => {
  if (!method) return '-'
  if (method === 'CASH') return 'เงินสด'
  if (method === 'PROMPTPAY') return 'พร้อมเพย์'
  if (method === 'BANK_TRANSFER') return 'โอนผ่านธนาคาร'
  if (method === 'QR_CODE') return 'QR Code'
  if (method === 'OTHER') return 'อื่น ๆ'
  return method
}

const formatMoney = (value) => {
  return Number(value || 0).toLocaleString('th-TH', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })
}

const formatDate = (value) => {
  return value ? new Date(value).toLocaleDateString('th-TH') : '-'
}

const splitBahtSatang = (value) => {
  const amount = Number(value || 0)
  const sign = amount < 0 ? '-' : ''
  const absolute = Math.abs(amount)
  const totalSatang = Math.round(absolute * 100)
  const baht = Math.floor(totalSatang / 100)
  const satang = totalSatang % 100

  return {
    baht: `${sign}${baht.toLocaleString('th-TH')}`,
    satang: String(satang).padStart(2, '0'),
  }
}

const normalizeText = (value) => {
  const text = String(value || '').trim()
  return text || '-'
}

const voucherRows = computed(() => {
  const firstRowAmount = splitBahtSatang(totalAmount.value)
  const rows = [
    {
      description: 'ค่าบริการเดินทาง',
      baht: firstRowAmount.baht,
      satang: firstRowAmount.satang,
    },
  ]

  while (rows.length < 8) {
    rows.push({ description: '', baht: '', satang: '' })
  }

  return rows
})

const thaiDigits = ['ศูนย์', 'หนึ่ง', 'สอง', 'สาม', 'สี่', 'ห้า', 'หก', 'เจ็ด', 'แปด', 'เก้า']
const thaiPlaces = ['', 'สิบ', 'ร้อย', 'พัน', 'หมื่น', 'แสน']

const readUnderMillion = (num) => {
  const input = Number(num || 0)
  if (!input) return ''

  const numberString = String(Math.floor(input))
  let output = ''

  for (let i = 0; i < numberString.length; i += 1) {
    const digit = Number(numberString[i])
    const place = numberString.length - i - 1

    if (digit === 0) continue

    if (place === 0) {
      if (digit === 1 && numberString.length > 1) {
        output += 'เอ็ด'
      } else {
        output += thaiDigits[digit]
      }
      continue
    }

    if (place === 1) {
      if (digit === 1) {
        output += 'สิบ'
      } else if (digit === 2) {
        output += 'ยี่สิบ'
      } else {
        output += `${thaiDigits[digit]}สิบ`
      }
      continue
    }

    output += `${thaiDigits[digit]}${thaiPlaces[place]}`
  }

  return output
}

const readThaiInteger = (num) => {
  const input = Number(num || 0)
  if (input === 0) return 'ศูนย์'
  if (input < 1000000) return readUnderMillion(input)

  const front = Math.floor(input / 1000000)
  const back = input % 1000000
  return `${readThaiInteger(front)}ล้าน${back ? readUnderMillion(back) : ''}`
}

const toThaiBahtText = (value) => {
  const amount = Number(value || 0)
  if (!Number.isFinite(amount) || amount < 0) return '-'

  const fixed = amount.toFixed(2)
  const [integerPart, satangPart] = fixed.split('.')
  const integerText = `${readThaiInteger(Number(integerPart))}บาท`
  const satang = Number(satangPart)

  if (satang === 0) return `${integerText}ถ้วน`
  return `${integerText}${readUnderMillion(satang)}สตางค์`
}

const printDocument = () => window.print()

onMounted(async () => {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const confirmation = await $api(`/payments/confirmations/${route.params.id}`)
    const docs = Array.isArray(confirmation?.documents) ? confirmation.documents : []

    if (!docs.length) {
      errorMessage.value = 'ยังไม่มีเอกสารการเงินสำหรับรายการนี้'
      return
    }

    documents.value = docs

    const requestedType = String(route.query.type || '').toUpperCase()
    const preselected = docs.find((doc) => doc.documentType === requestedType)
    selectedDocumentId.value = preselected?.id || docs[0].id
  } catch (error) {
    console.error('load document failed:', error)
    errorMessage.value = error?.statusMessage || 'ไม่สามารถโหลดเอกสารการเงินได้'
  } finally {
    isLoading.value = false
  }
})
</script>

<style scoped>
.ticket-wrapper {
  display: flex;
  justify-content: center;
}

.ticket-paper {
  width: 360px;
  max-width: 100%;
  position: relative;
}

.ticket-corner {
  position: absolute;
  top: 0;
  right: 0;
  width: 0;
  height: 0;
  border-left: 24px solid transparent;
  border-top: 24px solid #0f172a;
}

.voucher-paper {
  max-width: 900px;
  margin: 0 auto;
}

.voucher-table td,
.voucher-table th {
  line-height: 1.2;
}

.screen-shadow {
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.08);
}

@media print {
  @page {
    size: A4;
    margin: 8mm;
  }

  .document-page {
    min-height: auto !important;
    padding: 0 !important;
    background: #ffffff !important;
  }

  .document-shell {
    max-width: none !important;
    margin: 0 !important;
    padding: 0 !important;
  }

  .document-shell.space-y-4 > * {
    margin-top: 0 !important;
  }

  .print-one-page {
    page-break-inside: avoid;
    break-inside: avoid-page;
  }

  .print-hidden {
    display: none !important;
  }

  .screen-shadow {
    box-shadow: none !important;
  }

  .ticket-paper {
    width: 78mm;
    margin: 0 auto;
  }

  .voucher-paper {
    max-width: none;
    width: 100%;
    transform: scale(0.95);
    transform-origin: top center;
  }

  .voucher-table td,
  .voucher-table th {
    padding-top: 2px !important;
    padding-bottom: 2px !important;
  }

  body {
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }
}
</style>
