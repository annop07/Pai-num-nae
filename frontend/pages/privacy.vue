<template>
    <div class="text-gray-800 bg-gray-50">
        <!-- Scroll Progress Indicator -->
        <div class="scroll-indicator">
            <div class="scroll-progress" :style="{ width: scrollWidth + '%' }"></div>
        </div>

        <main class="px-4 py-8 mx-auto max-w-7xl sm:px-6 lg:px-8 md:py-12">
            <div class="grid grid-cols-1 gap-8 lg:grid-cols-4">
                <!-- TOC -->
                <aside class="lg:col-span-1">
                    <div class="sticky p-6 bg-white rounded-lg shadow-md top-24">
                        <h3 class="flex items-center mb-4 text-lg font-semibold text-gray-900">
                            <svg class="w-5 h-5 mr-2 text-gray-500" fill="none" stroke="currentColor"
                                viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2z" />
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M12 12h.01M16 12h.01M8 12h.01" />
                            </svg>
                            สารบัญ
                        </h3>

                        <nav id="toc" class="space-y-2">
                            <a href="#section-1" :class="tocLinkClass('section-1')"
                                class="block px-3 py-2 text-sm rounded-md toc-link">
                                ข้อ 1: บทนำ
                            </a>
                            <a href="#section-2" :class="tocLinkClass('section-2')"
                                class="block px-3 py-2 text-sm rounded-md toc-link">
                                ข้อ 2: ข้อมูลที่เราเก็บรวบรวม
                            </a>
                            <a href="#section-3" :class="tocLinkClass('section-3')"
                                class="block px-3 py-2 text-sm rounded-md toc-link">
                                ข้อ 3: แหล่งที่มาของข้อมูล
                            </a>
                            <a href="#section-4" :class="tocLinkClass('section-4')"
                                class="block px-3 py-2 text-sm rounded-md toc-link">
                                ข้อ 4: วัตถุประสงค์การใช้ข้อมูล
                            </a>
                            <a href="#section-5" :class="tocLinkClass('section-5')"
                                class="block px-3 py-2 text-sm rounded-md toc-link">
                                ข้อ 5: การเปิดเผยและแบ่งปันข้อมูล
                            </a>
                            <a href="#section-6" :class="tocLinkClass('section-6')"
                                class="block px-3 py-2 text-sm rounded-md toc-link">
                                ข้อ 6: ระยะเวลาในการจัดเก็บข้อมูล
                            </a>
                            <a href="#section-7" :class="tocLinkClass('section-7')"
                                class="block px-3 py-2 text-sm rounded-md toc-link">
                                ข้อ 7: ความปลอดภัยของข้อมูล
                            </a>
                            <a href="#section-8" :class="tocLinkClass('section-8')"
                                class="block px-3 py-2 text-sm rounded-md toc-link">
                                ข้อ 8: สิทธิ์ของเจ้าของข้อมูล
                            </a>
                            <a href="#section-9" :class="tocLinkClass('section-9')"
                                class="block px-3 py-2 text-sm rounded-md toc-link">
                                ข้อ 9: การเปลี่ยนแปลงนโยบาย
                            </a>
                            <a href="#section-10" :class="tocLinkClass('section-10')"
                                class="block px-3 py-2 text-sm rounded-md toc-link">
                                ข้อ 10: ข้อมูลการติดต่อ
                            </a>
                        </nav>
                    </div>
                </aside>

                <!-- Main Content -->
                <div class="lg:col-span-3">
                    <!-- Header -->
                    <div class="p-8 mb-8 bg-white rounded-lg shadow-md">
                        <h1 class="mb-2 text-3xl font-bold text-gray-900">นโยบายความเป็นส่วนตัว</h1>
                        <p class="mb-6 text-lg text-gray-600">(Privacy Policy)</p>
                        <div class="p-6 rounded-lg highlight-box">
                            <div class="flex items-center mb-2">
                                <svg class="w-6 h-6 mr-3 text-blue-600" fill="none" stroke="currentColor"
                                    viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                </svg>
                                <span class="text-lg font-semibold text-blue-900">มีผลบังคับใช้ตั้งแต่วันที่: 8 กรกฎาคม
                                    2568</span>
                            </div>
                            <p class="text-sm text-gray-700">
                                เราให้ความสำคัญกับการคุ้มครองข้อมูลส่วนบุคคลของท่านเป็นอย่างยิ่ง</p>
                        </div>
                    </div>

                    <!-- Section 1 -->
                    <section id="section-1" ref="sectionsRef"
                        class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card">
                        <h2 class="mb-4 text-2xl font-bold text-gray-900">ข้อ 1: บทนำ</h2>
                        <p class="mb-4 leading-relaxed text-gray-700">
                            บริษัท ไปนำแหน่ จำกัด ในฐานะผู้ให้บริการแพลตฟอร์ม “ไปนําแหน่” (“แพลตฟอร์ม”, “เรา”)
                            ตระหนักและให้ความสําคัญกับการคุ้มครองข้อมูลส่วนบุคคลของท่าน (“ผู้ใช้”) เป็นอย่างยิ่ง
                            นโยบายความเป็นส่วนตัวนี้จัดทําขึ้นเพื่ออธิบายให้ท่านทราบถึงวิธีการที่เราเก็บรวบรวม, ใช้,
                            เปิดเผย
                            และปกป้องข้อมูลส่วนบุคคลของท่านตามพระราชบัญญัติคุ้มครองข้อมูลส่วนบุคคล พ.ศ. 2562 (“PDPA”)
                        </p>
                        <div class="p-4 border-l-4 border-blue-400 rounded-r-lg bg-blue-50">
                            <p class="font-medium text-blue-800">
                                การใช้งานแพลตฟอร์มของเรา ถือว่าท่านได้อ่านและทำความเข้าใจนโยบายฉบับนี้แล้ว
                            </p>
                        </div>
                    </section>

                    <!-- Section 2 -->
                    <section id="section-2" ref="sectionsRef"
                        class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card">
                        <h2 class="mb-6 text-2xl font-bold text-gray-900">ข้อ 2: ข้อมูลส่วนบุคคลที่เราเก็บรวบรวม</h2>
                        <p class="mb-6 leading-relaxed text-gray-700">
                            เราเก็บรวบรวมข้อมูลส่วนบุคคลของท่านเท่าที่จําเป็นเพื่อการให้บริการ
                            โดยแบ่งประเภทข้อมูลได้ดังนี้:
                        </p>
                        <div class="space-y-6">
                            <div class="p-6 border border-gray-200 rounded-lg bg-gray-50">
                                <h3 class="mb-3 text-lg font-semibold text-gray-900">
                                    2.1. ข้อมูลที่ท่านให้กับเราโดยตรง (Data provided directly by you):
                                </h3>
                                <ul class="space-y-3 text-gray-700">
                                    <li class="flex items-start">
                                        <strong class="w-48 font-medium shrink-0">ข้อมูลบัญชี:</strong>
                                        <span>ชื่อ-นามสกุล, อีเมล, เบอร์โทรศัพท์, ชื่อผู้ใช้ (Username), รหัสผ่าน
                                            (ที่ผ่านการเข้ารหัส), และรูปโปรไฟล์</span>
                                    </li>
                                    <li class="flex items-start">
                                        <strong class="w-48 font-medium shrink-0">ข้อมูลเพื่อยืนยันตัวตน:</strong>
                                        <span>รูปถ่ายบัตรประชาชน, หมายเลขใบขับขี่ (สำหรับผู้ขับขี่และผู้โดยสาร)</span>
                                    </li>
                                    <li class="flex items-start">
                                        <strong class="w-48 font-medium shrink-0">ข้อมูลยานพาหนะ:</strong>
                                        <span>รุ่นรถยนต์, หมายเลขทะเบียนรถ, ประเภทรถยนต์, และจํานวนที่นั่ง
                                            (สำหรับผู้ขับขี่)</span>
                                    </li>
                                </ul>
                            </div>

                            <div class="p-6 border border-green-200 rounded-lg bg-green-50">
                                <h3 class="mb-3 text-lg font-semibold text-green-900">
                                    2.2. ข้อมูลที่เกิดขึ้นโดยอัตโนมัติระหว่างการใช้บริการ (Data generated during service
                                    use):
                                </h3>
                                <ul class="space-y-3 text-gray-700">
                                    <li class="flex items-start">
                                        <strong class="w-40 font-medium shrink-0">ข้อมูลการเดินทาง:</strong>
                                        <span>ตำแหน่งเริ่มต้น, ปลายทาง, จุดแวะพัก, วันและเวลาเดินทาง</span>
                                    </li>
                                    <li class="flex items-start">
                                        <strong class="w-40 font-medium shrink-0">ข้อมูลตำแหน่ง:</strong>
                                        <span>ตำแหน่งเมื่อใช้ฟีเจอร์ติดตามผ่านจุดตรวจ (Checkpoint)
                                            และเมื่อใช้ปุ่มแจ้งเหตุฉุกเฉิน (SOS)</span>
                                    </li>
                                    <li class="flex items-start">
                                        <strong class="w-40 font-medium shrink-0">ข้อมูลการใช้งาน:</strong>
                                        <span>ประวัติการเข้าสู่ระบบ, ประวัติการจอง,
                                            คะแนนและรีวิวที่ท่านมอบให้ผู้อื่น</span>
                                    </li>
                                    <li class="flex items-start">
                                        <strong class="w-40 font-medium shrink-0">ข้อมูลการสื่อสาร:</strong>
                                        <span>ข้อมูลการติดต่อที่ท่านให้กับทีมงาน เช่น อีเมล หรือข้อความผ่านช่องทางที่แพลตฟอร์มกำหนด</span>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </section>

                    <!-- Section 3 -->
                    <section id="section-3" ref="sectionsRef"
                        class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card">
                        <h2 class="mb-4 text-2xl font-bold text-gray-900">ข้อ 3: แหล่งที่มาของข้อมูลส่วนบุคคล</h2>
                        <p class="mb-6 text-gray-700">เราได้รับข้อมูลส่วนบุคคลของท่านจาก 2 แหล่งหลัก:</p>
                        <div class="grid gap-6 md:grid-cols-2">
                            <div class="p-6 text-center rounded-lg bg-purple-50">
                                <div
                                    class="flex items-center justify-center w-16 h-16 p-3 mx-auto mb-3 bg-purple-100 rounded-full">
                                    <svg class="w-8 h-8 text-purple-600" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                    </svg>
                                </div>
                                <h3 class="text-lg font-semibold text-purple-900">1. จากท่านโดยตรง</h3>
                                <p class="text-sm text-purple-800">ผ่านการลงทะเบียน, กรอกข้อมูล, ยืนยันตัวตน,
                                    สร้างเส้นทาง และการติดต่อกับเรา</p>
                            </div>
                            <div class="p-6 text-center rounded-lg bg-teal-50">
                                <div
                                    class="flex items-center justify-center w-16 h-16 p-3 mx-auto mb-3 bg-teal-100 rounded-full">
                                    <svg class="w-8 h-8 text-teal-600" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M12 18h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
                                    </svg>
                                </div>
                                <h3 class="text-lg font-semibold text-teal-900">2. จากการใช้งานของท่าน</h3>
                                <p class="text-sm text-teal-800">
                                    ข้อมูลที่ระบบสร้างและบันทึกโดยอัตโนมัติเมื่อท่านใช้งานฟีเจอร์ต่างๆ บนแพลตฟอร์ม
                                </p>
                            </div>
                        </div>
                    </section>

                    <!-- Section 4 -->
                    <section id="section-4" ref="sectionsRef"
                        class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card">
                        <h2 class="mb-4 text-2xl font-bold text-gray-900">ข้อ 4: วัตถุประสงค์ในการเก็บรวบรวมและใช้ข้อมูล
                        </h2>
                        <div class="p-6 border-l-4 border-indigo-400 rounded-r-lg bg-indigo-50">
                            <p class="mb-4 text-indigo-800">เราใช้ข้อมูลของท่านเพื่อวัตถุประสงค์ดังต่อไปนี้:</p>
                            <ul class="space-y-3 text-gray-700">
                                <li class="flex items-start">
                                    <span class="mt-1 mr-3 text-indigo-500 shrink-0">✓</span>
                                    <span><strong>เพื่อให้บริการและบริหารจัดการแพลตฟอร์ม:</strong>
                                        เพื่อสร้างและดูแลบัญชีของท่าน, ดําเนินการจับคู่เส้นทาง, ยืนยันการจอง
                                        และอํานวยความสะดวกในการเดินทาง</span>
                                </li>
                                <li class="flex items-start">
                                    <span class="mt-1 mr-3 text-indigo-500 shrink-0">✓</span>
                                    <span><strong>เพื่อความปลอดภัยและสร้างความน่าเชื่อถือ:</strong>
                                        เพื่อยืนยันตัวตนของผู้ใช้, ป้องกันการฉ้อโกง,
                                        และตอบสนองต่อเหตุฉุกเฉินผ่านฟังก์ชัน SOS</span>
                                </li>
                                <li class="flex items-start">
                                    <span class="mt-1 mr-3 text-indigo-500 shrink-0">✓</span>
                                    <span><strong>เพื่อการสื่อสาร:</strong>
                                        เพื่อส่งการแจ้งเตือนที่สําคัญเกี่ยวกับการจอง, การเปลี่ยนแปลงสถานะการเดินทาง
                                        และการติดต่อจากผู้ใช้อื่น</span>
                                </li>
                                <li class="flex items-start">
                                    <span class="mt-1 mr-3 text-indigo-500 shrink-0">✓</span>
                                    <span><strong>เพื่อสนับสนุนและช่วยเหลือผู้ใช้:</strong> เพื่อตอบคําถาม,
                                        แก้ไขปัญหาทางเทคนิค และจัดการข้อพิพาทที่อาจเกิดขึ้น</span>
                                </li>
                                <li class="flex items-start">
                                    <span class="mt-1 mr-3 text-indigo-500 shrink-0">✓</span>
                                    <span><strong>เพื่อปรับปรุงและพัฒนาบริการ:</strong>
                                        เพื่อทําความเข้าใจพฤติกรรมการใช้งานและนํามาวิเคราะห์ในการปรับปรุงฟังก์ชันและประสบการณ์ผู้ใช้ให้ดียิ่งขึ้น</span>
                                </li>
                                <li class="flex items-start">
                                    <span class="mt-1 mr-3 text-indigo-500 shrink-0">✓</span>
                                    <span><strong>เพื่อปฏิบัติตามกฎหมาย:</strong>
                                        เพื่อปฏิบัติตามภาระผูกพันทางกฎหมายหรือการร้องขอจากหน่วยงานภาครัฐที่มีอํานาจ</span>
                                </li>
                            </ul>
                        </div>
                    </section>

                    <!-- Section 5 -->
                    <section id="section-5" ref="sectionsRef"
                        class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card">
                        <h2 class="mb-4 text-2xl font-bold text-gray-900">ข้อ 5: การเปิดเผยและแบ่งปันข้อมูลส่วนบุคคล
                        </h2>
                        <p class="mb-6 leading-relaxed text-gray-700">
                            เราจะไม่เปิดเผยข้อมูลส่วนบุคคลของท่านแก่บุคคลที่สามโดยไม่ได้รับความยินยอมจากท่าน
                            ยกเว้นในกรณีต่อไปนี้:
                        </p>
                        <div class="space-y-4">
                            <div class="p-4 rounded-lg bg-gray-50">
                                <h3 class="mb-2 font-semibold text-gray-900">การแบ่งปันระหว่างผู้ใช้</h3>
                                <p class="text-sm text-gray-700">
                                    ผู้โดยสารจะเห็นข้อมูลที่จําเป็นของผู้ขับขี่ (ชื่อ, รูป, รุ่นรถ, คะแนน)
                                    และผู้ขับขี่จะเห็นข้อมูลของผู้โดยสาร (ชื่อ, รูป)
                                    เพื่อการยืนยันตัวตนและการตัดสินใจ
                                </p>
                            </div>
                            <div class="p-4 rounded-lg bg-gray-50">
                                <h3 class="mb-2 font-semibold text-gray-900">การแบ่งปันกับผู้ให้บริการภายนอก</h3>
                                <p class="text-sm text-gray-700">
                                    เราอาจแบ่งปันข้อมูลกับผู้ให้บริการที่ช่วยเราดําเนินงาน เช่น ระบบคลาวด์, แผนที่
                                    (Direction API),
                                    หรือผู้ให้บริการส่งรหัส OTP โดยมีสัญญาคุ้มครองข้อมูล
                                </p>
                            </div>
                            <div class="p-4 border-l-4 border-red-400 rounded-r-lg bg-red-50">
                                <h3 class="mb-2 font-semibold text-red-900">🚨 การตอบสนองต่อเหตุฉุกเฉินและข้อกฎหมาย</h3>
                                <ul class="space-y-1 text-sm text-red-800 list-disc list-inside">
                                    <li>หากมีการใช้งานฟังก์ชัน SOS
                                        ข้อมูลตําแหน่งอาจถูกส่งไปยังผู้ติดต่อฉุกเฉินหรือหน่วยงานที่เกี่ยวข้อง</li>
                                    <li>เราอาจเปิดเผยข้อมูลหากมีความจําเป็นเพื่อปฏิบัติตามหมายศาล, คําสั่งของเจ้าพนักงาน
                                        หรือกฎหมายอื่นใดที่เกี่ยวข้อง</li>
                                </ul>
                            </div>
                        </div>
                    </section>

                    <!-- Section 6 -->
                    <section id="section-6" ref="sectionsRef"
                        class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card">
                        <h2 class="mb-4 text-2xl font-bold text-gray-900">ข้อ 6: ระยะเวลาในการจัดเก็บข้อมูล</h2>
                        <div class="p-6 border-l-4 rounded-r-lg bg-amber-50 border-amber-400">
                            <div class="flex items-start">
                                <svg class="w-8 h-8 mr-4 text-amber-600 shrink-0" fill="none" stroke="currentColor"
                                    viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <div>
                                    <h3 class="mb-1 text-lg font-semibold text-amber-900">Data Retention</h3>
                                    <p class="leading-relaxed text-gray-700">
                                        เราจะจัดเก็บข้อมูลส่วนบุคคลของท่านไว้ตราบเท่าที่จำเป็นเพื่อวัตถุประสงค์ที่ระบุไว้ในนโยบายนี้
                                        และตราบเท่าที่ท่านยังคงสถานะเป็นผู้ใช้ของแพลตฟอร์ม หลังจากที่ท่านยกเลิกบัญชี
                                        เราอาจยังคงเก็บข้อมูลบางส่วนไว้ตามระยะเวลาที่กฎหมายกำหนดเพื่อภาระผูกพันทางบัญชีและกฎหมาย
                                    </p>
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- Section 7 -->
                    <section id="section-7" ref="sectionsRef"
                        class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card">
                        <h2 class="mb-4 text-2xl font-bold text-gray-900">ข้อ 7: ความปลอดภัยของข้อมูล</h2>
                        <div class="p-6 border-l-4 border-green-500 rounded-r-lg bg-green-50">
                            <div class="flex items-start">
                                <svg class="w-8 h-8 mr-4 text-green-600 shrink-0" fill="none" stroke="currentColor"
                                    viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                                </svg>
                                <div>
                                    <h3 class="mb-1 text-lg font-semibold text-green-900">Data Security</h3>
                                    <p class="leading-relaxed text-gray-700">
                                        เรามีมาตรการรักษาความปลอดภัยของข้อมูลทั้งในทางเทคนิคและกายภาพที่เหมาะสม
                                        เพื่อป้องกันการเข้าถึง, การใช้งาน, การเปลี่ยนแปลง
                                        หรือการเปิดเผยข้อมูลส่วนบุคคลโดยไม่ได้รับอนุญาต
                                        ซึ่งรวมถึงการเข้ารหัสข้อมูลที่สำคัญ เช่น รหัสผ่าน
                                    </p>
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- Section 8 -->
                    <section id="section-8" ref="sectionsRef"
                        class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card">
                        <h2 class="mb-4 text-2xl font-bold text-gray-900">ข้อ 8: สิทธิ์ของเจ้าของข้อมูล</h2>
                        <p class="mb-6 leading-relaxed text-gray-700">ในฐานะเจ้าของข้อมูลส่วนบุคคล
                            ท่านมีสิทธิดังต่อไปนี้:</p>
                        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                            <div class="p-4 border border-gray-200 rounded-lg bg-gray-50">
                                <h4 class="font-semibold text-gray-800">สิทธิ์ในการเข้าถึง (Right to Access)</h4>
                                <p class="text-sm text-gray-600">ขอรับสำเนาข้อมูลส่วนบุคคลของท่านที่เราจัดเก็บไว้</p>
                            </div>
                            <div class="p-4 border border-gray-200 rounded-lg bg-gray-50">
                                <h4 class="font-semibold text-gray-800">สิทธิ์ในการแก้ไข (Right to Rectification)</h4>
                                <p class="text-sm text-gray-600">แก้ไขข้อมูลส่วนบุคคลของท่านให้ถูกต้องและเป็นปัจจุบัน
                                </p>
                            </div>
                            <div class="p-4 border border-gray-200 rounded-lg bg-gray-50">
                                <h4 class="font-semibold text-gray-800">สิทธิ์ในการลบ (Right to Erasure)</h4>
                                <p class="text-sm text-gray-600">
                                    ร้องขอให้เราลบหรือทำลายข้อมูลของท่านภายใต้เงื่อนไขที่กฎหมายกำหนด</p>
                            </div>
                            <div class="p-4 border border-gray-200 rounded-lg bg-gray-50">
                                <h4 class="font-semibold text-gray-800">สิทธิ์ในการเพิกถอนความยินยอม</h4>
                                <p class="text-sm text-gray-600">เพิกถอนความยินยอมที่เคยให้ไว้กับเราได้ทุกเมื่อ</p>
                            </div>
                            <div class="p-4 border border-gray-200 rounded-lg bg-gray-50 sm:col-span-2">
                                <h4 class="font-semibold text-gray-800">สิทธิ์ในการคัดค้าน (Right to Object)</h4>
                                <p class="text-sm text-gray-600">คัดค้านการเก็บรวบรวม, ใช้, หรือเปิดเผยข้อมูลของท่าน</p>
                            </div>
                        </div>
                    </section>

                    <!-- Section 9 -->
                    <section id="section-9" ref="sectionsRef"
                        class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card">
                        <h2 class="mb-4 text-2xl font-bold text-gray-900">ข้อ 9: การเปลี่ยนแปลงนโยบาย</h2>
                        <div class="p-6 border-l-4 border-teal-500 rounded-r-lg bg-teal-50">
                            <div class="flex items-start">
                                <svg class="w-8 h-8 mr-4 text-teal-600 shrink-0" fill="none" stroke="currentColor"
                                    viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                                </svg>
                                <div>
                                    <h3 class="mb-1 text-lg font-semibold text-teal-900">Policy Updates</h3>
                                    <p class="leading-relaxed text-gray-700">
                                        เราอาจมีการทบทวนและแก้ไขนโยบายความเป็นส่วนตัวนี้เป็นครั้งคราวเพื่อให้สอดคล้องกับการเปลี่ยนแปลงของบริการและกฎหมายที่เกี่ยวข้อง
                                        เราจะแจ้งให้ท่านทราบถึงการเปลี่ยนแปลงที่สำคัญผ่านช่องทางที่เหมาะสมบนแพลตฟอร์ม
                                    </p>
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- Section 10 -->
                    <section id="section-10" ref="sectionsRef"
                        class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card">
                        <h2 class="mb-4 text-2xl font-bold text-gray-900">ข้อ 10: ข้อมูลการติดต่อ</h2>
                        <div class="p-6 border-l-4 border-blue-500 rounded-r-lg bg-blue-50">
                            <p class="mb-4 leading-relaxed text-gray-700">
                                หากท่านมีคำถาม, ข้อเสนอแนะ, หรือต้องการใช้สิทธิ์เกี่ยวกับข้อมูลส่วนบุคคลของท่าน
                                กรุณาติดต่อเราได้ที่:
                            </p>
                            <div class="space-y-4">
                                <div class="flex items-center p-3 bg-white rounded-lg shadow-sm">
                                    <svg class="w-5 h-5 mr-4 text-blue-600 shrink-0" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                                    </svg>
                                    <div>
                                        <div class="font-medium text-gray-900">อีเมล</div>
                                        <a href="mailto:privacy@painahae.com"
                                            class="text-sm text-blue-700 hover:underline">
                                            privacy@painahae.com
                                        </a>
                                    </div>
                                </div>
                                <div class="flex items-center p-3 bg-white rounded-lg shadow-sm">
                                    <svg class="w-5 h-5 mr-4 text-blue-600 shrink-0" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                                    </svg>
                                    <div>
                                        <div class="font-medium text-gray-900">ที่อยู่</div>
                                        <div class="text-sm text-gray-600">
                                            บริษัท ไปนำแหน่ จำกัด (สำนักงานใหญ่) ถนนมิตรภาพ ขอนแก่น 40000
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>

                </div>
            </div>
        </main>
    </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useHead } from '#imports'

useHead({
    title: 'นโยบายความเป็นส่วนตัว - ไปนำแหน่',
    link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Kanit:wght@300;400;500;600;700&display=swap' }
    ],
    htmlAttrs: { lang: 'th' },
    bodyAttrs: { class: 'bg-gray-50' },
    meta: [
        { name: 'viewport', content: 'width=device-width, initial-scale=1.0' }
    ]
})

// Scroll progress
const scrollWidth = ref(0)

// Active section tracking
const activeSectionId = ref('section-1')
const sectionsRef = ref([])

function handleScroll() {
    // Progress
    const doc = document.documentElement
    const scrollTotal = doc.scrollHeight - doc.clientHeight
    const scrolled = window.scrollY
    scrollWidth.value = scrollTotal > 0 ? (scrolled / scrollTotal) * 100 : 0

    // Active section (offset for sticky header)
    const OFFSET = 120
    let current = activeSectionId.value
    for (const el of sectionsRef.value) {
        if (!el) continue
        if (window.scrollY >= (el.offsetTop - OFFSET)) {
            current = el.id
        }
    }
    activeSectionId.value = current
}

function tocLinkClass(id) {
    return [
        'text-gray-600 hover:text-blue-600 transition-all',
        'border-l-3', // helper (no-op, kept for parity with original intent)
        activeSectionId.value === id ? 'active' : ''
    ]
}

onMounted(() => {
    // Collect all content sections
    sectionsRef.value = Array.from(document.querySelectorAll('.content-section'))
    handleScroll()
    window.addEventListener('scroll', handleScroll, { passive: true })
})

onBeforeUnmount(() => {
    window.removeEventListener('scroll', handleScroll)
})
</script>

<style scoped>
/* Font family from Google Fonts (Kanit) */
:global(html),
:global(body) {
    font-family: 'Kanit', system-ui, -apple-system, Segoe UI, Roboto, Noto Sans, Ubuntu, Cantarell, 'Helvetica Neue', Arial, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', sans-serif;
}

/* Card hover effect */
.section-card {
    transition: all 0.3s ease;
}

.section-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(59, 130, 246, 0.12);
}

/* Highlight box */
.highlight-box {
    background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
    border-left: 4px solid #3b82f6;
}

/* Scroll progress bar */
.scroll-indicator {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 4px;
    background: #e5e7eb;
    z-index: 1000;
}

.scroll-progress {
    height: 100%;
    background: linear-gradient(90deg, #3b82f6, #1d4ed8);
    width: 0%;
    transition: width 0.1s ease-out;
}

/* Section anchor offset for sticky header */
.content-section {
    scroll-margin-top: 100px;
}

/* TOC link interaction */
.toc-link {
    transition: all 0.2s ease;
    border-left: 3px solid transparent;
}

.toc-link:hover {
    background-color: #f3f4f6;
    padding-left: 1rem;
    border-left-color: #93c5fd;
}

.toc-link.active {
    background-color: #eff6ff;
    border-left: 3px solid #3b82f6 !important;
    padding-left: 1rem;
    color: #1d4ed8;
    font-weight: 500;
}

/* Utility (no-op placeholder to mirror original HTML's intent) */
.border-l-3 {
    border-left-width: 3px;
}
</style>
