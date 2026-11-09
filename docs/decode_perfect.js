const fs = require('fs');
const zlib = require('zlib');

const buf = fs.readFileSync('D:/AI TBG/AI AUTO/NKTHIENBINH/Profile Thien Binh 26 F 1810.pdf');
const str = buf.toString('latin1');

function getObjStream(objNum) {
  const marker = objNum + ' 0 obj';
  const idx = str.indexOf(marker);
  if (idx === -1) return null;
  const sStart = str.indexOf('stream', idx);
  if (sStart === -1) return null;
  const dataStart = str.indexOf('\n', sStart) + 1;
  const sEnd = str.indexOf('endstream', dataStart);
  if (sEnd === -1) return null;
  const sBuf = buf.subarray(dataStart, sEnd);
  try { return zlib.inflateSync(sBuf).toString('utf-8'); } catch(e) { return sBuf.toString('latin1'); }
}

function parseCMap(cmapText) {
  const map = {};
  if (!cmapText) return map;
  const bfcharRegex = /<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>/g;
  let m;
  while ((m = bfcharRegex.exec(cmapText)) !== null) {
    const src = parseInt(m[1], 16);
    const dstCodes = m[2].match(/.{1,4}/g).map(h => parseInt(h, 16));
    map[src] = String.fromCharCode(...dstCodes);
  }
  const bfrangeRegex = /<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>/g;
  while ((m = bfrangeRegex.exec(cmapText)) !== null) {
    const start = parseInt(m[1], 16);
    const end = parseInt(m[2], 16);
    let dstStart = parseInt(m[3], 16);
    for (let i = start; i <= end; i++) map[i] = String.fromCharCode(dstStart++);
  }
  return map;
}

// 1. Map font object ID to CMap
const fontObjToCMap = {};
const fontRegex = /(\d+)\s+0\s+obj\s*<<[\s\S]*?\/Type\s*\/Font[\s\S]*?\/ToUnicode\s+(\d+)\s+0\s+R[\s\S]*?>>\s*endobj/g;
let m;
while ((m = fontRegex.exec(str)) !== null) {
  const fontObj = m[1];
  const toUnicodeObj = parseInt(m[2]);
  const cmapText = getObjStream(toUnicodeObj);
  fontObjToCMap[fontObj] = parseCMap(cmapText);
}
console.log('Mapped font CMaps count:', Object.keys(fontObjToCMap).length);

// 2. Map Page to Fonts and Contents
const pageRegex = /(\d+)\s+0\s+obj\s*<<([^>]*\/Type\s*\/Page\b[\s\S]*?)>>\s*endobj/g;
let pCount = 0;
const pageTexts = [];

while ((m = pageRegex.exec(str)) !== null) {
  pCount++;
  const pageBody = m[2];
  
  // Find Fonts in this page
  const pageFonts = {};
  const fontMatch = pageBody.match(/\/Font\s*<<([^>]+)>>/);
  if (fontMatch) {
    const fontPairs = fontMatch[1].match(/\/(\w+)\s+(\d+)\s+0\s+R/g) || [];
    fontPairs.forEach(fp => {
      const parts = fp.match(/\/(\w+)\s+(\d+)/);
      if (parts) pageFonts[parts[1]] = fontObjToCMap[parts[2]] || {};
    });
  }

  // Find Contents
  let contents = [];
  const cSingle = pageBody.match(/\/Contents\s+(\d+)\s+0\s+R/);
  const cArray = pageBody.match(/\/Contents\s*\[([^\]]+)\]/);
  if (cSingle) contents = [parseInt(cSingle[1])];
  else if (cArray) contents = (cArray[1].match(/\d+/g) || []).map(n => parseInt(n));

  let pageStreamText = '';
  contents.forEach(c => {
    const s = getObjStream(c);
    if (s) pageStreamText += '\n' + s;
  });

  // Decode page text
  let curFont = '';
  let curCMap = {};
  const decodedLines = [];

  const streamLines = pageStreamText.split(/\r?\n/);
  for (const l of streamLines) {
    const fM = l.match(/\/(\w+)\s+[\d\.]+\s+Tf/);
    if (fM) {
      curFont = fM[1];
      curCMap = pageFonts[curFont] || {};
    }

    const tjM = l.match(/\[(.*?)\]\s*TJ/);
    if (tjM) {
      const items = tjM[1].match(/<[0-9A-Fa-f]+>|\([^)]*\)|-?\d+(\.\d+)?/g) || [];
      let strBuf = '';
      for (const it of items) {
        if (it.startsWith('<')) {
          const hex = it.slice(1, -1);
          for (let i = 0; i < hex.length; i += 4) {
            const code = parseInt(hex.substr(i, 4), 16);
            strBuf += curCMap[code] || '';
          }
        } else if (it.startsWith('(')) {
          strBuf += it.slice(1, -1);
        } else {
          const k = parseFloat(it);
          if (k < -180) strBuf += ' ';
        }
      }
      if (strBuf.trim()) decodedLines.push(strBuf.trim());
      continue;
    }

    const hexTj = l.match(/<([0-9A-Fa-f]+)>\s*Tj/);
    if (hexTj) {
      const hex = hexTj[1];
      let strBuf = '';
      for (let i = 0; i < hex.length; i += 4) {
        const code = parseInt(hex.substr(i, 4), 16);
        strBuf += curCMap[code] || '';
      }
      if (strBuf.trim()) decodedLines.push(strBuf.trim());
    }
  }

  pageTexts.push(`==================== TRANG ${pCount} ====================\n` + decodedLines.join('\n'));
}

fs.writeFileSync('D:/AI TBG/AI AUTO/docs/thien_binh_profile_perfect.txt', pageTexts.join('\n\n'), 'utf-8');
console.log('Decoded pages count:', pCount);
console.log('\n--- FIRST 3 PAGES ---\n');
console.log(pageTexts.slice(0, 3).join('\n\n'));
