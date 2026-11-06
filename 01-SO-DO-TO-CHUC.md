# SƠ ĐỒ TỔ CHỨC VÀ PHÂN QUYỀN HỆ AI AGENTIC — THIÊN BÌNH

**Tổng chỉ huy:** TBG-Captain  
**Doanh nghiệp:** THIÊN BÌNH — Cửa vách nhôm kính  
**Cập nhật:** 03/11/2026  

---

## 1. Cấu trúc 5 Agent chuyên trách

```
TBG-Captain (Tổng chỉ huy)
├─ TBG-KTVT · Kỹ thuật & Vật tư: Thiết kế, tính giá, bản vẽ SX, bản vẽ thi công, định mức vật tư, tìm NCC, đặt hàng, theo dõi tồn kho.
├─ TBG-HCKT · Hành chính & Kế toán: Tuyển dụng, đánh giá, chấm công, thống kê, công nợ, dòng tiền, hồ sơ, báo cáo thuế, hạch toán.
├─ TBG-KDMT · Kinh doanh & Marketing: Tiếp thị, bán hàng, theo dõi tiến độ, CSKH, nghiệm thu thanh toán, viết bài, video, chiến dịch marketing.
├─ TBG-SX   · Sản xuất: Nhận hồ sơ, kiểm tra tồn kho, nhận vật tư, gia công, lắp ráp, KCS, đóng bọc, lưu kho, xuất hàng.
└─ TBG-TC   · Thi công: Nhận hồ sơ, khảo sát hiện trạng, phối hợp kỹ thuật, biện pháp thi công, nhận hàng tại công trình, bảo quản, lắp đặt, căn chỉnh, nghiệm thu.
```

---

## 2. Bảng phân quyền & Nguồn dữ liệu

| Mã Agent | Vai trò chuyên trách | Phạm vi nghiệp vụ | Quyền mặc định | Thư mục dữ liệu đầu vào | Thư mục Skill |
|---|---|---|:---:|---|---|
| **TBG-KTVT** | Kỹ thuật & Vật tư | Thiết kế, tính giá, bản vẽ sản xuất, bản vẽ thi công, định mức vật tư, tìm nhà cung cấp, đặt hàng, theo dõi tồn kho | **ĐỌC + ĐỀ XUẤT** | `D:\OneDrive\BIEU MAU\KY THUAT`<br>`D:\OneDrive\BIEU MAU\VAT TU` | [SKILL.md](file:///d:/AI%20TBG/AI%20AUTO/skills/TBG-KTVT/SKILL.md) |
| **TBG-HCKT** | Hành chính & Kế toán | Tuyển dụng, đánh giá, chấm công, thống kê, theo dõi công nợ, dòng tiền, hồ sơ, báo cáo thuế, hạch toán | **ĐỌC + ĐỀ XUẤT** | `D:\OneDrive\BIEU MAU\KE TOAN`<br>`D:\OneDrive\BIEU MAU\HANH CHINH` | [SKILL.md](file:///d:/AI%20TBG/AI%20AUTO/skills/TBG-HCKT/SKILL.md) |
| **TBG-KDMT** | Kinh doanh & Marketing | Tiếp thị, bán hàng, theo dõi quá trình, chăm sóc khách hàng, nghiệm thu thanh toán, viết bài, tạo video, lên chương trình marketing | **ĐỌC + ĐỀ XUẤT** | `D:\OneDrive\BIEU MAU\KINH DOANH` | [SKILL.md](file:///d:/AI%20TBG/AI%20AUTO/skills/TBG-KDMT/SKILL.md) |
| **TBG-SX** | Sản xuất | Nhận hồ sơ công trình, kiểm tra tồn kho, nhận vật tư sản xuất, gia công, lắp ráp, kiểm tra, đóng bọc, lưu kho, xuất hàng | **ĐỌC + ĐỀ XUẤT** | `D:\OneDrive\BIEU MAU\BIEU MAU THAI DUONG\6 - SAN XUAT - SX` | [SKILL.md](file:///d:/AI%20TBG/AI%20AUTO/skills/TBG-SX/SKILL.md) |
| **TBG-TC** | Thi công | Nhận hồ sơ thi công, khảo sát hiện trạng, trao đổi với kỹ thuật, biện pháp thi công, nhận hàng ở công trình, sắp xếp bảo quản, thi công theo bản vẽ, kiểm tra, căn chỉnh, nghiệm thu | **ĐỌC toàn hệ thống, CHẶN** | `D:\OneDrive\BIEU MAU\THI CONG` | [SKILL.md](file:///d:/AI%20TBG/AI%20AUTO/skills/TBG-TC/SKILL.md) |

> [!IMPORTANT]
> **Đặc quyền của TBG-TC (Thi công):** Có quyền **ĐỌC toàn hệ thống** và có quyền **CHẶN** ngay lập tức các lệnh xuất xưởng/thi công nếu phát hiện sai lệch hiện trạng, sai kích thước thực tế, nguy cơ mất an toàn lao động hoặc sai vật tư so với hợp đồng.

---

## 3. Mẫu phiếu giao việc chuẩn (Work Order Ticket)

Mọi công việc điều phối giữa TBG-Captain và các Agent chuyên trách đều bắt buộc phải phát hành phiếu chuẩn:

```yaml
ma_viec:   TBG-[AGENT]-[STT]
agent:     <Tên mã Agent>
yeu_cau:   <Nội dung công việc chi tiết>
dau_vao:   <Đường dẫn thư mục biểu mẫu, file bản vẽ, hợp đồng có sẵn>
dau_ra:    <File kết quả (Excel/Báo cáo), lưu vào folder theo tên công trình và ngày tháng>
tieu_chi:  <Chấm điểm theo thang 100, yêu cầu ≥90 điểm mới được đề xuất duyệt>
han:       <Hạn hoàn thành cụ thể>
quyen:     ĐỌC | ĐỀ XUẤT | THỰC THI | CHẶN
thieu:     <Các dữ liệu bắt buộc cần bổ sung thêm trước khi triển khai>
```
