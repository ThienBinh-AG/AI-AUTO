# PowerShell script to create Word document from Markdown
$OutputFile = "D:\AI TBG\AI AUTO\BO_10_BAI_VIET_MARKETING_90_NGAY_THIEN_BINH.docx"
$MdPath = "D:\AI TBG\AI AUTO\KE_HOACH_MARKETING_90_NGAY.md"

$imgMap = @{
    "1" = "D:\ANH CONG TRINH\ANH CHON GUI KHACH\CT (2).jpg"
    "2" = "D:\ANH CONG TRINH\ANH CHON GUI KHACH\CT (6).jpg"
    "3" = "D:\ANH CONG TRINH\NHA CUNG CAP - VAT TU\20231124_112701.jpg"
    "4" = "D:\ANH CONG TRINH\ANH CHON GUI KHACH\CT (17).jpg"
    "5" = "D:\ANH CONG TRINH\ANH CHON GUI KHACH\CT (1).jpg"
    "6" = "D:\ANH CONG TRINH\ANH CHON GUI KHACH\CT (20).jpg"
    "7" = "D:\ANH CONG TRINH\ANH CHON GUI KHACH\CT (14).jpg"
    "8" = "D:\ANH CONG TRINH\ANH CHON GUI KHACH\CT (22).jpg"
    "9" = "D:\ANH CONG TRINH\CT MAT DUNG\20210508_102242.jpg"
    "10" = "D:\ANH CONG TRINH\ANH CHON GUI KHACH\CT (30).jpg"
}

Write-Host "Khoi tao Microsoft Word..."
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

$doc = $word.Documents.Add()
$sel = $word.Selection

function Insert-PostImage($id) {
    if ($id -ne "" -and $imgMap.ContainsKey($id)) {
        $picPath = $imgMap[$id]
        if (Test-Path $picPath) {
            Write-Host "Chen anh cho Bai $id : $picPath"
            $shape = $sel.InlineShapes.AddPicture($picPath)
            $shape.LockAspectRatio = $true
            if ($shape.Width -gt 420) {
                $shape.Width = 420
            }
            $sel.TypeParagraph()
            $sel.Font.Name = "Arial"
            $sel.Font.Size = 10
            $sel.Font.Bold = 1
            $sel.Font.Color = 0x008000
            $sel.ParagraphFormat.Alignment = 1
            $sel.TypeText("[Hinh anh cong trinh thuc te Thien Binh - Bai $id]")
            $sel.TypeParagraph()
            $sel.Font.Size = 8
            $sel.Font.Bold = 0
            $sel.Font.Color = 0x888888
            $sel.TypeText("Nguon anh thuc te: $picPath")
            $sel.TypeParagraph()
            $sel.TypeParagraph()
        }
    }
}

$lines = [System.IO.File]::ReadAllLines($MdPath, [System.Text.Encoding]::UTF8)
$currentId = ""

foreach ($line in $lines) {
    if ($line -match '### B.*I (\d+)') {
        if ($currentId -ne "") {
            Insert-PostImage $currentId
        }
        $currentId = $matches[1]
        $sel.Font.Name = "Arial"
        $sel.Font.Size = 14
        $sel.Font.Bold = 1
        $sel.Font.Color = 0x003366
        $sel.ParagraphFormat.Alignment = 0
        $sel.TypeText($line)
        $sel.TypeParagraph()
    }
    elseif ($line.StartsWith('# ')) {
        $sel.Font.Name = "Arial"
        $sel.Font.Size = 16
        $sel.Font.Bold = 1
        $sel.Font.Color = 0xC00000
        $sel.ParagraphFormat.Alignment = 1
        $sel.TypeText($line.Substring(2))
        $sel.TypeParagraph()
    }
    elseif ($line.StartsWith('## ')) {
        $sel.Font.Name = "Arial"
        $sel.Font.Size = 13
        $sel.Font.Bold = 1
        $sel.Font.Color = 0x004080
        $sel.ParagraphFormat.Alignment = 0
        $sel.TypeText($line.Substring(3))
        $sel.TypeParagraph()
    }
    elseif ($line.StartsWith('> ') -or $line.StartsWith('>')) {
        $sel.Font.Name = "Arial"
        $sel.Font.Size = 10.5
        $sel.Font.Italic = 1
        $sel.Font.Color = 0x333333
        $sel.ParagraphFormat.Alignment = 0
        $cleanLine = $line.TrimStart('>').Trim()
        if ($cleanLine.Length -gt 0) {
            $sel.TypeText($cleanLine)
            $sel.TypeParagraph()
        }
        $sel.Font.Italic = 0
    }
    elseif ($line.StartsWith('* **') -or $line.StartsWith('- **') -or $line.StartsWith('**')) {
        $sel.Font.Name = "Arial"
        $sel.Font.Size = 11
        $sel.Font.Bold = 1
        $sel.Font.Color = 0x222222
        $sel.ParagraphFormat.Alignment = 0
        $sel.TypeText($line)
        $sel.TypeParagraph()
    }
    elseif ($line -match '^---+$') {
        $sel.Font.Name = "Arial"
        $sel.Font.Size = 9
        $sel.Font.Bold = 0
        $sel.Font.Color = 0xCCCCCC
        $sel.ParagraphFormat.Alignment = 1
        $sel.TypeText("_________________________________________________________________________________")
        $sel.TypeParagraph()
    }
    else {
        if ($line.Trim().Length -gt 0) {
            $sel.Font.Name = "Arial"
            $sel.Font.Size = 11
            $sel.Font.Bold = 0
            $sel.Font.Color = 0
            $sel.ParagraphFormat.Alignment = 0
            $sel.TypeText($line)
            $sel.TypeParagraph()
        }
    }
}

if ($currentId -ne "") {
    Insert-PostImage $currentId
}

Write-Host "Luu file: $OutputFile"
$doc.SaveAs([ref]$OutputFile, [ref]16)
$doc.Close()
$word.Quit()

[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sel) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($doc) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

Write-Host "Hoan tat!"
Get-Item $OutputFile | Select-Object Name, Length, LastWriteTime
