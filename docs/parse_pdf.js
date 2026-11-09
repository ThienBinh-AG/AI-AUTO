const fs = require('fs');
const zlib = require('zlib');

const pdfBuf = fs.readFileSync('D:/AI TBG/AI AUTO/NKTHIENBINH/Profile Thien Binh 26 F 1810.pdf');
const pdfStr = pdfBuf.toString('latin1');

// 1. Build CMap dictionary from ToUnicode streams
const cmapRegex = /(\d+)\s+(\d+)\s+obj\s*<<[\s\S]*?\/ToUnicode\s+(\d+)\s+(\d+)\s+R[\s\S]*?>>/g;
const toUnicodeObjs = {};

// Find all ToUnicode stream references
let match;
const fontToCMap = {};
const fontRegex = /\/F(\w+)\s+(\d+)\s+(\d+)\s+R/g;

// Let's find all ToUnicode objects directly
const toUnicodeStreamRegex = /(\d+)\s+(\d+)\s+obj\s*<<[\s\S]*?\/Filter\s*\/FlateDecode[\s\S]*?>>\s*stream\r?\n([\s\S]*?)endstream/g;

console.log('Searching for ToUnicode maps...');
const charMaps = {}; // objNum -> map

let streamPos = 0;
while (true) {
  const objIdx = pdfStr.indexOf(' obj', streamPos);
  if (objIdx === -1) break;
  const numStart = pdfStr.lastIndexOf('\n', objIdx);
  const objNum = parseInt(pdfStr.substring(numStart, objIdx).trim().split(' ')[0]);
  
  const streamIdx = pdfStr.indexOf('stream', objIdx);
  const endObjIdx = pdfStr.indexOf('endobj', objIdx);
  if (streamIdx !== -1 && streamIdx < endObjIdx) {
    const dictHeader = pdfStr.substring(objIdx, streamIdx);
    if (dictHeader.includes('/ToUnicode') || dictHeader.includes('/CIDInit')) {
      // It's a CMap stream
      const sStart = pdfStr.indexOf('\n', streamIdx) + 1;
      const sEnd = pdfStr.indexOf('endstream', sStart);
      const sBuf = pdfBuf.subarray(sStart, sEnd);
      try {
        const decomp = zlib.inflateSync(sBuf).toString('utf-8');
        // Parse bfchar and bfrange
        const map = {};
        const bfcharRegex = /<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>/g;
        let cm;
        while ((cm = bfcharRegex.exec(decomp)) !== null) {
          const src = parseInt(cm[1], 16);
          const dst = String.fromCharCode(...cm[2].match(/.{1,4}/g).map(h => parseInt(h, 16)));
          map[src] = dst;
        }
        const bfrangeRegex = /<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>/g;
        while ((cm = bfrangeRegex.exec(decomp)) !== null) {
          const start = parseInt(cm[1], 16);
          const end = parseInt(cm[2], 16);
          let dstStart = parseInt(cm[3], 16);
          for (let i = start; i <= end; i++) {
            map[i] = String.fromCharCode(dstStart++);
          }
        }
        charMaps[objNum] = map;
      } catch (e) {}
    }
  }
  streamPos = endObjIdx + 6;
}

console.log('Found CMap objects:', Object.keys(charMaps).length);

// Also look for direct text in content streams
const streams = fs.readFileSync('D:/AI TBG/AI AUTO/docs/extracted_profile_text.txt', 'utf-8').split('=== STREAM ');
const allExtractedText = [];

streams.forEach((s, idx) => {
  if (!s.trim()) return;
  const lines = s.split('\n');
  const pageText = [];
  
  // Find font switches /F...
  let currentFont = '';
  
  for (const line of lines) {
    // Check for font change /F12 12 Tf
    const fMatch = line.match(/\/F(\w+)\s+[\d\.]+\s+Tf/);
    if (fMatch) currentFont = fMatch[1];
    
    // Tj with hex <...>
    const hexTj = line.match(/<([0-9A-Fa-f]+)>\s*Tj/g);
    if (hexTj) {
      for (const ht of hexTj) {
        const hex = ht.replace(/<|>\s*Tj/g, '');
        // try decoding with all cmaps or UTF-16
        let decoded = '';
        // try direct utf-16be
        for (let i = 0; i < hex.length; i += 4) {
          const code = parseInt(hex.substr(i, 4), 16);
          let ch = '';
          for (const cm of Object.values(charMaps)) {
            if (cm[code]) { ch = cm[code]; break; }
          }
          if (!ch) ch = String.fromCharCode(code);
          decoded += ch;
        }
        if (decoded.trim()) pageText.push(decoded.trim());
      }
    }
    
    // TJ array with hex
    const hexArray = line.match(/\[(.*?)\]\s*TJ/);
    if (hexArray) {
      const parts = hexArray[1].match(/<([0-9A-Fa-f]+)>/g);
      if (parts) {
        let decoded = '';
        for (const p of parts) {
          const hex = p.replace(/<|>/g, '');
          for (let i = 0; i < hex.length; i += 4) {
            const code = parseInt(hex.substr(i, 4), 16);
            let ch = '';
            for (const cm of Object.values(charMaps)) {
              if (cm[code]) { ch = cm[code]; break; }
            }
            if (!ch) ch = String.fromCharCode(code);
            decoded += ch;
          }
        }
        if (decoded.trim()) pageText.push(decoded.trim());
      }
      // Also check string parts (text) in TJ
      const strParts = hexArray[1].match(/\((.*?)\)/g);
      if (strParts) {
        const decoded = strParts.map(p => p.slice(1, -1)).join('');
        if (decoded.trim()) pageText.push(decoded.trim());
      }
    }
    
    // Tj with parentheses (text)
    const strTj = line.match(/\((.*?)\)\s*Tj/g);
    if (strTj) {
      for (const st of strTj) {
        const txt = st.replace(/\(|\)\s*Tj/g, '');
        if (txt.trim()) pageText.push(txt.trim());
      }
    }
  }
  
  if (pageText.length > 0) {
    allExtractedText.push(`--- SECTION ${idx} ---\n` + pageText.join('\n'));
  }
});

const fullResult = allExtractedText.join('\n\n');
fs.writeFileSync('D:/AI TBG/AI AUTO/docs/parsed_profile_readable.txt', fullResult, 'utf-8');
console.log('Saved parsed readable text! Total sections:', allExtractedText.length);
console.log('\nPreview first 1500 chars:\n');
console.log(fullResult.substring(0, 1500));
