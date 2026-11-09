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
  try {
    return zlib.inflateSync(sBuf).toString('utf-8');
  } catch (e) {
    return sBuf.toString('latin1');
  }
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
    for (let i = start; i <= end; i++) {
      map[i] = String.fromCharCode(dstStart++);
    }
  }

  const bfrangeArrRegex = /<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>\s*\[([^\]]+)\]/g;
  while ((m = bfrangeArrRegex.exec(cmapText)) !== null) {
    const start = parseInt(m[1], 16);
    const end = parseInt(m[2], 16);
    const arr = m[3].match(/<([0-9a-fA-F]+)>/g) || [];
    for (let i = 0; i < arr.length && (start + i) <= end; i++) {
      const dstHex = arr[i].replace(/<|>/g, '');
      const dstCodes = dstHex.match(/.{1,4}/g).map(h => parseInt(h, 16));
      map[start + i] = String.fromCharCode(...dstCodes);
    }
  }
  return map;
}

// Build global CMap
const globalCMap = {};
const toUnicodeRegex = /\/ToUnicode\s+(\d+)\s+\d+\s+R/g;
let tum;
const seenObjs = new Set();
while ((tum = toUnicodeRegex.exec(str)) !== null) {
  const objNum = parseInt(tum[1]);
  if (!seenObjs.has(objNum)) {
    seenObjs.add(objNum);
    const cmapText = getObjStream(objNum);
    const map = parseCMap(cmapText);
    Object.assign(globalCMap, map);
  }
}
console.log('Total CMap entries mapped:', Object.keys(globalCMap).length);

function decodeHex(hex) {
  let res = '';
  for (let i = 0; i < hex.length; i += 4) {
    const code = parseInt(hex.substr(i, 4), 16);
    const ch = globalCMap[code] || String.fromCharCode(code);
    res += ch;
  }
  return res;
}

// Read extracted streams
const rawText = fs.readFileSync('D:/AI TBG/AI AUTO/docs/extracted_profile_text.txt', 'utf-8');
const streams = rawText.split('=== STREAM ');

const decodedSections = [];

streams.forEach(s => {
  if (!s.trim()) return;
  const header = s.substring(0, s.indexOf('\n')).trim();
  const body = s.substring(s.indexOf('\n') + 1);
  
  const textPieces = [];
  const lines = body.split(/\r?\n/);
  
  for (const l of lines) {
    // TJ array: [ ... ] TJ
    const tjMatch = l.match(/\[(.*?)\]\s*TJ/);
    if (tjMatch) {
      const inner = tjMatch[1];
      const items = inner.match(/<[0-9A-Fa-f]+>|\([^)]*\)|-?\d+(\.\d+)?/g) || [];
      let piece = '';
      for (const it of items) {
        if (it.startsWith('<')) {
          piece += decodeHex(it.slice(1, -1));
        } else if (it.startsWith('(')) {
          piece += it.slice(1, -1);
        } else {
          const num = parseFloat(it);
          if (num < -150) piece += ' ';
        }
      }
      if (piece.trim()) textPieces.push(piece.trim());
      continue;
    }

    // Tj: <hex> Tj
    const hexTj = l.match(/<([0-9A-Fa-f]+)>\s*Tj/);
    if (hexTj) {
      const piece = decodeHex(hexTj[1]);
      if (piece.trim()) textPieces.push(piece.trim());
      continue;
    }
  }

  if (textPieces.length > 0) {
    decodedSections.push(`=== STREAM ${header} ===\n` + textPieces.join('\n'));
  }
});

const result = decodedSections.join('\n\n');
fs.writeFileSync('D:/AI TBG/AI AUTO/docs/decoded_profile_text.txt', result, 'utf-8');
console.log('Decoded streams:', decodedSections.length);
console.log('\n--- SAMPLE EXTRACTED CONTENT ---\n');
console.log(result.substring(0, 3000));
