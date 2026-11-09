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

// 1. Map all font objects to their CMap
const fontObjToCMap = {};
const fontRegex = /(\d+)\s+0\s+obj\s*<<[\s\S]*?\/Type\s*\/Font[\s\S]*?\/ToUnicode\s+(\d+)\s+0\s+R[\s\S]*?>>\s*endobj/g;
let m;
while ((m = fontRegex.exec(str)) !== null) {
  const fontObj = m[1];
  const toUnicodeObj = parseInt(m[2]);
  const cmapText = getObjStream(toUnicodeObj);
  fontObjToCMap[fontObj] = parseCMap(cmapText);
}
console.log('Total Font CMaps loaded:', Object.keys(fontObjToCMap).length);

// 2. Helper to resolve indirect object
function resolveObj(objNum) {
  const marker = objNum + ' 0 obj';
  const idx = str.indexOf(marker);
  if (idx === -1) return '';
  const end = str.indexOf('endobj', idx);
  return str.substring(idx, end + 6);
}

// 3. Find all Form XObjects
const formRegex = /(\d+)\s+0\s+obj\s*<<[\s\S]*?\/Subtype\s*\/Form[\s\S]*?>>\s*stream/g;
const formObjs = [];
while ((m = formRegex.exec(str)) !== null) {
  const formNum = m[1];
  const header = m[0];
  
  // Extract Font dict (could be direct or indirect like /Font 794 0 R)
  let fontMap = {};
  const fontIndirect = header.match(/\/Font\s+(\d+)\s+0\s+R/);
  const fontDirect = header.match(/\/Font\s*<<([^>]+)>>/);
  
  let fontDictStr = '';
  if (fontIndirect) {
    fontDictStr = resolveObj(fontIndirect[1]);
  } else if (fontDirect) {
    fontDictStr = fontDirect[1];
  }
  
  const fontPairs = fontDictStr.match(/\/(\w+)\s+(\d+)\s+0\s+R/g) || [];
  fontPairs.forEach(fp => {
    const parts = fp.match(/\/(\w+)\s+(\d+)/);
    if (parts) {
      fontMap[parts[1]] = fontObjToCMap[parts[2]] || {};
    }
  });

  formObjs.push({ formNum, fontMap });
}

console.log('Total Form XObjects found:', formObjs.length);

// 4. Decode each Form XObject
const decodedSections = [];

formObjs.forEach((fo, idx) => {
  const streamText = getObjStream(fo.formNum);
  if (!streamText || !streamText.includes('BT')) return;

  const lines = streamText.split(/\r?\n/);
  let curFont = '';
  let curCMap = {};
  const sectionLines = [];

  for (const l of lines) {
    const fM = l.match(/\/(\w+)\s+[\d\.]+\s+Tf/);
    if (fM) {
      curFont = fM[1];
      curCMap = fo.fontMap[curFont] || {};
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
      if (strBuf.trim()) sectionLines.push(strBuf.trim());
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
      if (strBuf.trim()) sectionLines.push(strBuf.trim());
    }
  }

  if (sectionLines.length > 0) {
    decodedSections.push(`=== FORM XOBJECT ${fo.formNum} (Page Section ${idx + 1}) ===\n` + sectionLines.join('\n'));
  }
});

const fullOutput = decodedSections.join('\n\n');
fs.writeFileSync('D:/AI TBG/AI AUTO/docs/profile_thienbinh_decoded_real.txt', fullOutput, 'utf-8');
console.log('Decoded sections count:', decodedSections.length);
console.log('\n--- SAMPLE OUTPUT (first 3000 chars) ---\n');
console.log(fullOutput.substring(0, 3000));
