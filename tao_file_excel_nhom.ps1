# Script khoi tao file Excel SO_SANH_NHA_CUNG_CAP_NHOM.xlsx
# Thuc hien boi TBG-Captain & TBG-KTVT

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$wb = $excel.Workbooks.Add()

# Xoa cac sheet mac dinh chi de lai sheet 1
while ($wb.Sheets.Count -gt 1) {
    $wb.Sheets.Item(2).Delete()
}

# ==========================================
# SHEET 1: Danh_Gia_NCC (Thang diem 100)
# ==========================================
$ws1 = $wb.Sheets.Item(1)
$ws1.Name = "Danh_Gia_NCC"

$ws1.Cells.Item(1, 1) = "BẢNG ĐÁNH GIÁ & CHẤM ĐIỂM NHÀ CUNG CẤP THANH PROFILE NHÔM — THIÊN BÌNH 2026"
$ws1.Range("A1:J1").Merge()
$ws1.Range("A1:J1").Font.Bold = $true
$ws1.Range("A1:J1").Font.Size = 14
$ws1.Range("A1:J1").Font.Color = 0xFFFFFF
$ws1.Range("A1:J1").Interior.Color = 0x794E1F # Dark Blue #1F4E79 in BGR (0x794E1F)
$ws1.Range("A1:J1").HorizontalAlignment = -4108 # Center

$ws1.Cells.Item(2, 1) = "Thang điểm 100 tiêu chuẩn Thiên Bình: Kỹ thuật & Độ bền (25đ) | Thẩm mỹ & Màu sắc (20đ) | Ổn định chuỗi cung ứng & Chống nhái (20đ) | Đơn giá & Chiết khấu (20đ) | Hỗ trợ xưởng & Bảo hành (15đ)"
$ws1.Range("A2:J2").Merge()
$ws1.Range("A2:J2").Font.Italic = $true
$ws1.Range("A2:J2").Font.Size = 10
$ws1.Range("A2:J2").HorizontalAlignment = -4108

$headers1 = @("Mã NCC", "Nhà cung cấp / Thương hiệu", "Xuất xứ & Công nghệ", "Kỹ thuật & Độ dày (25đ)", "Thẩm mỹ & Màu sơn (20đ)", "Cung ứng & Chống nhái (20đ)", "Đơn giá & CS xưởng (20đ)", "Bảo hành & Hỗ trợ (15đ)", "TỔNG ĐIỂM", "Xếp loại & Đề xuất đối tác")
for ($col = 0; $col -lt $headers1.Length; $col++) {
    $ws1.Cells.Item(4, $col + 1) = $headers1[$col]
}
$ws1.Range("A4:J4").Font.Bold = $true
$ws1.Range("A4:J4").Font.Color = 0xFFFFFF
$ws1.Range("A4:J4").Interior.Color = 0x2A3B4C # Navy
$ws1.Range("A4:J4").HorizontalAlignment = -4108
$ws1.Range("A4:J4").WrapText = $true

$data1 = @(
    @("NCC-01", "MAXPRO.JP (Trung Chính / LIXIL)", "Công nghệ Nhật Bản (JIS)", 24, 20, 19, 14, 15, "=SUM(D5:H5)", "Chiến lược Dòng Cao Cấp (Quiet Luxury, Biệt thự, Resort ven biển)"),
    @("NCC-02", "XINGFA CLASS A (AseanWindow)", "Quảng Đông / Rãnh C Châu Âu", 24, 19, 19, 15, 15, "=SUM(D6:H6)", "Chiến lược Dòng Cận Cao Cấp & Cửa Khổ Lớn Rãnh C"),
    @("NCC-03", "TOPAL AUSTDOOR (Austdoor Group)", "Việt Nam (Austdoor Hưng Yên & ĐN)", 22, 18, 20, 18, 14, "=SUM(D7:H7)", "Chiến lược Dòng Dự Án Dân Dụng & Thương Mại Đồng Bộ"),
    @("NCC-04", "PMI MALAYSIA (Press Metal Berhad)", "Nhập khẩu Malaysia (Qualicoat)", 23, 18, 17, 16, 14, "=SUM(D8:H8)", "Chiến lược Hệ Cầu Cách Nhiệt (Thermal Break) & Xếp Trượt"),
    @("NCC-05", "XINGFA QUẢNG ĐÔNG (Tem đỏ Aseanwindow)", "Phật Sơn, Quảng Đông (AkzoNobel)", 22, 17, 15, 19, 13, "=SUM(D9:H9)", "Chủ lực Dân dụng Phổ thông (Bắt buộc kiểm soát 100% tem nhái)"),
    @("NCC-06", "PMA PLATINUM (PMA Group)", "Việt Nam (Hệ vát cạnh tiết kiệm)", 19, 16, 18, 20, 13, "=SUM(D10:H10)", "Tối ưu hóa Chi phí / Công trình Dân dụng Kinh tế & Hoàn vốn nhanh")
)

for ($row = 0; $row -lt $data1.Length; $row++) {
    for ($col = 0; $col -lt $data1[$row].Length; $col++) {
        $ws1.Cells.Item($row + 5, $col + 1) = $data1[$row][$col]
    }
}

$ws1.Range("A5:J10").Font.Size = 10
$ws1.Range("A5:A10").HorizontalAlignment = -4108
$ws1.Range("D5:I10").HorizontalAlignment = -4108
$ws1.Range("I5:I10").Font.Bold = $true
$ws1.Range("A5:J10").Borders.LineStyle = 1

# Highlight Maxpro, Xingfa Class A, Topal
$ws1.Range("A5:J5").Interior.Color = 0xE6F2FF # Light Blue
$ws1.Range("A6:J6").Interior.Color = 0xE6F2FF
$ws1.Range("A7:J7").Interior.Color = 0xE6FFE6 # Light Green

# ==========================================
# SHEET 2: So_Sanh_Ky_Thuat
# ==========================================
$ws2 = $wb.Sheets.Add([System.Reflection.Missing]::Value, $ws1)
$ws2.Name = "So_Sanh_Ky_Thuat"

$ws2.Cells.Item(1, 1) = "BẢNG SO SÁNH TIÊU CHÍ KỸ THUẬT PROFILE NHÔM ĐỊNH HÌNH — THIÊN BÌNH"
$ws2.Range("A1:G1").Merge()
$ws2.Range("A1:G1").Font.Bold = $true
$ws2.Range("A1:G1").Font.Size = 14
$ws2.Range("A1:G1").Font.Color = 0xFFFFFF
$ws2.Range("A1:G1").Interior.Color = 0x794E1F
$ws2.Range("A1:G1").HorizontalAlignment = -4108

$headers2 = @("Tiêu chí kỹ thuật", "MAXPRO.JP", "XINGFA CLASS A", "TOPAL (AUSTDOOR)", "PMI MALAYSIA", "XINGFA QUẢNG ĐÔNG (Tem đỏ)", "PMA PLATINUM")
for ($col = 0; $col -lt $headers2.Length; $col++) {
    $ws2.Cells.Item(3, $col + 1) = $headers2[$col]
}
$ws2.Range("A3:G3").Font.Bold = $true
$ws2.Range("A3:G3").Font.Color = 0xFFFFFF
$ws2.Range("A3:G3").Interior.Color = 0x2A3B4C
$ws2.Range("A3:G3").HorizontalAlignment = -4108

$techData = @(
    @("Xuất xứ & Nhà máy", "Công nghệ Nhật Bản / XNK Trung Chính", "Quảng Đông (AseanWindow độc quyền)", "Nhà máy Austdoor Hưng Yên & Đồng Nai", "Press Metal Berhad (Malaysia)", "Quảng Đông (Nhập khẩu nguyên thanh)", "Việt Nam (PMA Group)"),
    @("Tiêu chuẩn sản xuất", "JIS H4100 & JIS H8602, Qualanod", "Tiêu chuẩn Châu Âu (European Norm)", "TCVN 9366-2:2012, Quatest 1", "EN 15088, CE Mark, Qualicoat", "GB 5237-2008, ISO 9001", "TCVN 6305, ISO 9001:2015"),
    @("Mác nhôm hợp kim", "6063-T5 / 6063-T6 nguyên sinh", "6063-T5 nguyên sinh độ cứng cao", "6063-T5 độ cứng 10-12 Webster", "6063-T5 nguyên sinh tinh khiết", "6063-T5", "6063-T5"),
    @("Độ dày profile Cửa đi", "2.0mm – 2.5mm (Hệ R65, R83)", "2.0mm – 2.2mm (Hệ A65)", "1.9mm – 2.0mm (Topal Prima)", "2.0mm (Hệ PE45, P55D)", "2.0mm (±5%)", "1.4mm – 1.8mm"),
    @("Độ dày profile Cửa sổ", "1.4mm – 2.0mm", "1.4mm – 1.8mm", "1.3mm – 1.4mm", "1.4mm – 1.6mm", "1.4mm (±5%)", "1.2mm – 1.4mm"),
    @("Độ dày Cửa lùa / Trượt", "2.0mm – 2.6mm (SW83, SD115)", "2.0mm – 2.5mm (A115 lùa nâng)", "1.4mm – 2.0mm", "2.0mm – 2.2mm (L100, L120C)", "2.0mm (Hệ 93/95)", "1.6mm – 1.8mm (Platinum 95)"),
    @("Chuẩn rãnh phụ kiện", "Rãnh C Châu Âu & Hệ đa điểm", "Rãnh C chuẩn Châu Âu", "Topal đồng bộ & Rãnh tiêu chuẩn", "Rãnh C Châu Âu & Tiêu chuẩn", "Rãnh K truyền thống (khoan vít)", "Rãnh K vát cạnh (Ke nhảy/ke vĩnh cửu)"),
    @("Công nghệ xử lý bề mặt", "Mạ Anodise ED - Texguard Nhật Bản", "Anodized-ED / Sơn PVDF 2-3 lớp / AkzoNobel", "Sơn tĩnh điện Wagner bột AkzoNobel", "Sơn tĩnh điện AkzoNobel / Cầu cách nhiệt", "Sơn tĩnh điện bột AkzoNobel", "Sơn tĩnh điện nhiệt ngoài trời"),
    @("Thời gian bảo hành màu", "25 NĂM chính hãng", "10 – 25 NĂM (tùy lớp Anode/PVDF)", "5 – 10 NĂM", "10 – 15 NĂM", "5 NĂM", "5 – 10 NĂM"),
    @("Khả năng kháng muối biển", "Cực tốt (>2.000h phun sương muối)", "Rất tốt (>1.500h với bản Anode/PVDF)", "Khá (công trình ven biển cần gói sơn đặc biệt)", "Tốt (đạt chứng chỉ Qualicoat Seaside)", "Trung bình (dễ oxy hóa nếu ở mép biển)", "Trung bình"),
    @("Tải trọng cánh tối đa", "350kg – 400kg/cánh (Cửa lùa nâng SD115)", "300kg/cánh (Hệ lùa A115)", "150kg – 200kg/cánh (Prima)", "250kg – 300kg/cánh (L120C)", "120kg – 150kg/cánh", "100kg – 120kg/cánh"),
    @("Cầu cách nhiệt (Thermal Break)", "Tùy chọn hệ cao cấp", "Tùy chọn hệ cách nhiệt", "Topal Prima XPU", "Có hệ chuyên biệt (DPE56, DL100F)", "Ít phổ biến (phải đặt hàng riêng)", "Không có"),
    @("Phụ kiện tương thích tối ưu", "CMECH (Mỹ), BOGO, Phụ kiện Maxpro", "CMECH, BOGO, Sigico, Hopo", "Phụ kiện Topal đồng bộ, Draho", "Sigico, Hopo, Draho, CMECH", "Kinlong, Draho, 3H, Huy Hoàng", "Draho, PMA đồng bộ, AG"),
    @("Nguy cơ hàng giả nhái tại VN", "CỰC KỲ THẤP (<2%)", "CỰC KỲ THẤP (<2%)", "HẦU NHƯ KHÔNG CÓ (Tem điện tử)", "THẤP (<5%)", "CỰC KỲ CAO (>60% trôi nổi)", "THẤP (<5%)")
)

for ($row = 0; $row -lt $techData.Length; $row++) {
    for ($col = 0; $col -lt $techData[$row].Length; $col++) {
        $ws2.Cells.Item($row + 4, $col + 1) = $techData[$row][$col]
    }
}

$ws2.Range("A4:G17").Font.Size = 10
$ws2.Range("A4:A17").Font.Bold = $true
$ws2.Range("A4:G17").Borders.LineStyle = 1
$ws2.Range("A4:G17").WrapText = $true

# ==========================================
# SHEET 3: Bang_Don_Gia_Chi_Tiet
# ==========================================
$ws3 = $wb.Sheets.Add([System.Reflection.Missing]::Value, $ws2)
$ws3.Name = "Bang_Don_Gia_Chi_Tiet"

$ws3.Cells.Item(1, 1) = "BẢNG ĐƠN GIÁ THANH NHÔM CÂY & ĐƠN GIÁ CỬA THÀNH PHẨM THAM CHIẾU — THIÊN BÌNH 2026"
$ws3.Range("A1:H1").Merge()
$ws3.Range("A1:H1").Font.Bold = $true
$ws3.Range("A1:H1").Font.Size = 14
$ws3.Range("A1:H1").Font.Color = 0xFFFFFF
$ws3.Range("A1:H1").Interior.Color = 0x794E1F
$ws3.Range("A1:H1").HorizontalAlignment = -4108

$ws3.Cells.Item(2, 1) = "Giá thanh nhôm cây dành cho xưởng sản xuất Thiên Bình (chưa VAT) & Đơn giá cửa hoàn thiện (đã gồm kính an toàn/cường lực + phụ kiện chuẩn)"
$ws3.Range("A2:H2").Merge()
$ws3.Range("A2:H2").Font.Italic = $true
$ws3.Range("A2:H2").Font.Size = 10
$ws3.Range("A2:H2").HorizontalAlignment = -4108

$headers3 = @("STT", "Thương hiệu nhôm", "Hệ nhôm / Quy cách cửa", "Độ dày (mm)", "Giá nhôm cây theo Kg (VNĐ/kg)", "Giá nhôm cây 5.8m (VNĐ/cây)", "Đơn giá cửa m² chưa PK (VNĐ/m²)", "Đơn giá cửa m² trọn gói PK (VNĐ/m²)")
for ($col = 0; $col -lt $headers3.Length; $col++) {
    $ws3.Cells.Item(4, $col + 1) = $headers3[$col]
}
$ws3.Range("A4:H4").Font.Bold = $true
$ws3.Range("A4:H4").Font.Color = 0xFFFFFF
$ws3.Range("A4:H4").Interior.Color = 0x2A3B4C
$ws3.Range("A4:H4").HorizontalAlignment = -4108
$ws3.Range("A4:H4").WrapText = $true

$priceData = @(
    @("1", "MAXPRO.JP (Nhật Bản)", "Cửa sổ mở quay R55 / R65", "1.4 - 2.0", 195000, 950000, 2900000, 3850000),
    @("2", "MAXPRO.JP (Nhật Bản)", "Cửa đi mở quay R65 Plus (Anodise ED)", "2.0 - 2.5", 210000, 1450000, 3600000, 4850000),
    @("3", "MAXPRO.JP (Nhật Bản)", "Cửa đi lùa nâng Lift-Slide SD115", "2.0 - 2.6", 225000, 1850000, 4200000, 5800000),
    @("4", "MAXPRO.JP (Nhật Bản)", "Cửa đi xếp trượt cao cấp SFD80", "2.0", 220000, 1750000, 4100000, 5600000),
    @("5", "XINGFA CLASS A", "Cửa sổ mở quay Hệ A65 (Sơn AkzoNobel)", "1.6 - 1.8", 155000, 780000, 2450000, 3350000),
    @("6", "XINGFA CLASS A", "Cửa đi mở quay Hệ A65 (Anodized-ED)", "2.0 - 2.2", 195000, 1350000, 3500000, 4800000),
    @("7", "XINGFA CLASS A", "Cửa lùa trượt khổ lớn A115 (PVDF)", "2.0 - 2.5", 190000, 1550000, 3400000, 4700000),
    @("8", "XINGFA CLASS A", "Cửa xếp trượt rãnh C Hệ SC8", "1.8 - 2.5", 205000, 1650000, 3800000, 5300000),
    @("9", "TOPAL AUSTDOOR", "Cửa sổ mở quay Topal Slima 56", "1.2 - 1.4", 95000, 480000, 1350000, 1650000),
    @("10", "TOPAL AUSTDOOR", "Cửa đi mở quay Topal Slima 56", "1.3 - 1.4", 96000, 590000, 1450000, 1850000),
    @("11", "TOPAL AUSTDOOR", "Cửa sổ mở quay Topal Prima", "1.4", 108000, 650000, 1850000, 2350000),
    @("12", "TOPAL AUSTDOOR", "Cửa đi mở quay Topal Prima", "1.9 - 2.0", 112000, 920000, 2250000, 2950000),
    @("13", "TOPAL AUSTDOOR", "Cửa nhôm Thủy Lực bản cánh 180mm", "2.0", 120000, 1450000, 3100000, 4200000),
    @("14", "PMI MALAYSIA", "Cửa sổ mở quay Hệ PE45", "1.4 - 1.6", 148000, 720000, 2200000, 2950000),
    @("15", "PMI MALAYSIA", "Cửa đi mở quay Hệ P55D", "2.0", 155000, 1100000, 2550000, 3450000),
    @("16", "PMI MALAYSIA", "Cửa đi mở quay Cầu Cách Nhiệt DPE56", "2.0", 225000, 1750000, 4100000, 5600000),
    @("17", "PMI MALAYSIA", "Cửa lùa nâng Lift-Slide L120C", "2.2", 210000, 1650000, 3800000, 5200000),
    @("18", "XINGFA QUẢNG ĐÔNG", "Cửa sổ mở quay Hệ 55 (Tem đỏ)", "1.4", 112000, 580000, 1550000, 1950000),
    @("19", "XINGFA QUẢNG ĐÔNG", "Cửa đi mở quay Hệ 55 (Tem đỏ)", "2.0", 115000, 890000, 1850000, 2450000),
    @("20", "XINGFA QUẢNG ĐÔNG", "Cửa đi lùa Hệ 93 (Tem đỏ)", "2.0", 116000, 920000, 1800000, 2350000),
    @("21", "XINGFA QUẢNG ĐÔNG", "Cửa đi xếp trượt Hệ 63 (Tem đỏ)", "1.6 - 2.5", 124000, 1150000, 2350000, 3200000),
    @("22", "PMA PLATINUM", "Cửa sổ mở quay PMA 55 Vát Cạnh", "1.2 - 1.4", 92000, 440000, 1150000, 1450000),
    @("23", "PMA PLATINUM", "Cửa đi mở quay PMA 55 Vát Cạnh", "1.4", 94000, 520000, 1300000, 1680000),
    @("24", "PMA PLATINUM", "Cửa đi mở quay PMA Platinum", "1.6 - 1.8", 102000, 720000, 1650000, 2150000),
    @("25", "PMA PLATINUM", "Cửa lùa trượt PMA Platinum Hệ 95", "1.6 - 1.8", 99000, 780000, 1550000, 2050000)
)

for ($row = 0; $row -lt $priceData.Length; $row++) {
    for ($col = 0; $col -lt $priceData[$row].Length; $col++) {
        $ws3.Cells.Item($row + 5, $col + 1) = $priceData[$row][$col]
    }
}

$ws3.Range("A5:H29").Font.Size = 10
$ws3.Range("A5:A29").HorizontalAlignment = -4108
$ws3.Range("D5:D29").HorizontalAlignment = -4108
$ws3.Range("E5:H29").NumberFormat = "#,##0 ""đ"""
$ws3.Range("A5:H29").Borders.LineStyle = 1

# ==========================================
# SHEET 4: Khuyen_Nghi_Doi_Tac
# ==========================================
$ws4 = $wb.Sheets.Add([System.Reflection.Missing]::Value, $ws3)
$ws4.Name = "Khuyen_Nghi_Doi_Tac"

$ws4.Cells.Item(1, 1) = "CHIẾN LƯỢC LỰA CHỌN ĐỐI TÁC CUNG ỨNG NHÔM — THIÊN BÌNH (PARTNER PORTFOLIO)"
$ws4.Range("A1:G1").Merge()
$ws4.Range("A1:G1").Font.Bold = $true
$ws4.Range("A1:G1").Font.Size = 14
$ws4.Range("A1:G1").Font.Color = 0xFFFFFF
$ws4.Range("A1:G1").Interior.Color = 0x794E1F
$ws4.Range("A1:G1").HorizontalAlignment = -4108

$headers4 = @("Phân tầng thị trường", "Đối tác chiến lược lựa chọn", "Hệ Profile chủ lực", "Hệ phụ kiện đồng bộ", "Lý do lựa chọn & Lợi thế cạnh tranh", "Chính sách đàm phán xưởng")
for ($col = 0; $col -lt $headers4.Length; $col++) {
    $ws4.Cells.Item(3, $col + 1) = $headers4[$col]
}
$ws4.Range("A3:F3").Font.Bold = $true
$ws4.Range("A3:F3").Font.Color = 0xFFFFFF
$ws4.Range("A3:F3").Interior.Color = 0x2A3B4C
$ws4.Range("A3:F3").HorizontalAlignment = -4108

$partnerData = @(
    @("1. PHÂN KHÚC CAO CẤP (Quiet Luxury / Biệt thự nghỉ dưỡng / Khách sạn 5 sao / Ven biển)", "MAXPRO.JP (Công nghệ Nhật Bản)", "R65 Plus mở quay, SD115 lùa nâng, SFD80 xếp trượt", "CMECH (Hoa Kỳ) hoặc Phụ kiện Maxpro", "Bảo hành màu 25 năm, mạ Anodise ED kháng muối biển tuyệt hảo, thẩm mỹ kim loại sang trọng đỉnh cao, không lo hàng nhái.", "Đàm phán hạn mức nợ thanh nhôm 30 ngày, chiết khấu thanh toán sớm 3-5%, hỗ trợ máy đột dập dưỡng mẫu."),
    @("2. PHÂN KHÚC CẬN CAO CẤP & CỬA KHỔ LỚN RÃNH C CHÂU ÂU", "XINGFA CLASS A (AseanWindow)", "Hệ A65 mở quay, A115 lùa trượt, SC8 xếp trượt", "CMECH (Mỹ), BOGO (Đức), Sigico", "Chuẩn rãnh C Châu Âu giấu vít toàn bộ, cải tiến vượt trội so với Xingfa thường, phân phối độc quyền qua AseanWindow, chống giả nhái 100%.", "Ký hợp đồng Đại lý ủy quyền Cấp 1 AseanWindow, hưởng mức chiết khấu lũy tiến quý, hỗ trợ biển hiệu và góc mẫu showroom."),
    @("3. PHÂN KHÚC DỰ ÁN DÂN DỤNG & THƯƠNG MẠI TIÊU CHUẨN", "TOPAL AUSTDOOR (Austdoor Group)", "Topal Slima 56/46, Topal Prima, Cửa Thủy Lực", "Phụ kiện Topal đồng bộ hoặc Draho", "Nhà máy Austdoor lớn nhất VN, chuỗi cung ứng tổng kho trải dài Bắc - Nam cực kỳ chủ động tiến độ, tem bảo hành điện tử chính hãng.", "Đàm phán chính sách xưởng sản xuất ủy quyền Topal Partner, gối đầu vật tư theo tiến độ nghiệm thu công trình."),
    @("4. PHÂN KHÚC CÔNG TRÌNH XANH & TIẾT KIỆM NĂNG LƯỢNG", "PMI MALAYSIA (Press Metal)", "DPE56 Cầu cách nhiệt, L120C Lift-Slide", "Sigico, Hopo, CMECH", "Chứng chỉ CE Châu Âu, dải Polyamide cách âm cách nhiệt đỉnh cao, giảm 40% chi phí điện năng điều hòa cho mặt tiền hướng Tây.", "Nhập thanh theo đơn đặt hàng dự án có bảo lãnh tạm ứng CĐT, yêu cầu cấp đủ CO/CQ và kết quả thí nghiệm Quatest."),
    @("5. PHÂN KHÚC NHÀ DÂN DỤNG PHỔ THÔNG KHỐI LƯỢNG LỚN", "XINGFA QUẢNG ĐÔNG (Nhập khẩu chính hãng)", "Hệ 55 mở quay, Hệ 93 lùa trượt", "DRAHO (Việt Nam) hoặc Kinlong chuẩn", "Thương hiệu quen thuộc nhất với khách hàng dân dụng. Bắt buộc kết hợp phụ kiện DRAHO chính hãng để triệt tiêu rủi ro bảo hành xệ cánh.", "Chỉ nhập từ tổng kho lớn uy tín có hóa đơn VAT, kiểm tra 100% mã vạch QR và tem chữ chìm."),
    @("6. PHÂN KHÚC TỐI ƯU CHI PHÍ / NHÀ TRỌ / DÂN DỤNG TIẾT KIỆM", "PMA PLATINUM (PMA Group)", "Hệ 55 Vát Cạnh, PMA Platinum 95", "Phụ kiện PMA đồng bộ, Draho", "Giá thành thấp nhất trong các hệ nhôm định hình chất lượng, gia công không cần ép góc thủy lực, thời gian hoàn vốn nhanh.", "Đàm phán giá sỉ theo tấn tại kho tổng Hà Nội/Hải Phòng, thanh toán gối đầu 50/50.")
)

for ($row = 0; $row -lt $partnerData.Length; $row++) {
    for ($col = 0; $col -lt $partnerData[$row].Length; $col++) {
        $ws4.Cells.Item($row + 4, $col + 1) = $partnerData[$row][$col]
    }
}

$ws4.Range("A4:F9").Font.Size = 10
$ws4.Range("A4:A9").Font.Bold = $true
$ws4.Range("A4:F9").Borders.LineStyle = 1
$ws4.Range("A4:F9").WrapText = $true

# Auto-fit all sheets
foreach ($ws in $wb.Sheets) {
    $ws.Cells.EntireColumn.AutoFit() | Out-Null
    $ws.Application.ActiveWindow.DisplayGridlines = $true
}

# Luu file
$filePath = "d:\AI TBG\AI AUTO\SO_SANH_NHA_CUNG_CAP_NHOM.xlsx"
if (Test-Path $filePath) {
    Remove-Item $filePath -Force
}
$wb.SaveAs($filePath)
$wb.Close($false)
$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null

Write-Output "Da khoi tao thanh cong file: $filePath"
