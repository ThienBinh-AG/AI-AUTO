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
  
  // bfchar: <src> <dst>
  const bfcharRegex = /<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>/g;
  let m;
  while ((m = bfcharRegex.exec(cmapText)) !== null) {
    const src = parseInt(m[1], 16);
    const dstCodes = m[2].match(/.{1,4}/g).map(h => parseInt(h, 16));
    map[src] = String.fromCharCode(...dstCodes);
  }

  // bfrange: <start> <end> <dstStart>
  const bfrangeRegex = /<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>/g;
  while ((m = bfrangeRegex.exec(cmapText)) !== null) {
    const start = parseInt(m[1], 16);
    const end = parseInt(m[2], 16);
    let dstStart = parseInt(m[3], 16);
    for (let i = start; i <= end; i++) {
      map[i] = String.fromCharCode(dstStart++);
    }
  }

  // bfrange with array: <start> <end> [ <dst1> <dst2> ... ]
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

// 1. Collect all Fonts and their ToUnicode maps
const fontMaps = {}; // fontName -> { cmap }
const fontObjRegex = /(\d+)\s+(\d+)\s+obj\s*<<[\s\S]*?\/BaseFont\s*\/([^\s/>]+)[\s\S]*?\/ToUnicode\s+(\d+)\s+(\d+)\s+R[\s\S]*?>>/g;

let fm;
while ((fm = fontObjRegex.exec(str)) !== null) {
  const fontObjNum = fm[1];
  const baseFont = fm[3];
  const toUnicodeObjNum = parseInt(fm[4]);
  const cmapText = getObjStream(toUnicodeObjNum);
  const cmap = parseCMap(cmapText);
  fontMaps[fontObjNum] = cmap;
  fontMaps[baseFont] = cmap;
}
console.log('Parsed font CMaps:', Object.keys(fontMaps).length);

// Also create a global fallback CMap combining all
const globalCMap = {};
Object.values(fontMaps).forEach(cm => Object.assign(globalCMap, cm));

// 2. Find all Pages and their Contents
const pageRegex = /(\d+)\s+(\d+)\s+obj\s*<<[\s\S]*?\/Type\s*\/Page\b[\s\S]*?>>/g;
const pages = [];
let pm;
while ((pm = pageRegex.exec(str)) !== null) {
  const pageObj = pm[0];
  const contentsMatch = pageObj.match(/\/Contents\s+(\d+)\s+(\d+)\s+R/) || pageObj.match(/\/Contents\s*\[([^\]]+)\]/);
  let contentObjs = [];
  if (contentsMatch) {
    if (contentsMatch[1].includes('R')) {
      contentObjs = (contentsMatch[1].match(/(\d+)\s+\d+\s+R/g) || []).map(r => parseInt(r));
    } else {
      contentObjs = [parseInt(contentsMatch[1])];
    }
  }

  // Find fonts in Resources
  const fontResMatch = pageObj.match(/\/Font\s*<<([^>]+)>>/);
  const pageFontMap = {};
  if (fontResMatch) {
    const fPairs = fontResMatch[1].match(/\/(\w+)\s+(\d+)\s+\d+\s+R/g) || [];
    fPairs.forEach(fp => {
      const p = fp.match(/\/(\w+)\s+(\d+)/);
      if (p) pageFontMap[p[1]] = fontMaps[p[2]] || globalCMap;
    });
  }

  pages.push({
    pageObjNum: pm[1],
    contentObjs,
    pageFontMap
  });
}

console.log('Pages found:', pages.length);

function decodeString(hexOrStr, cmap) {
  let res = '';
  // Usually hex like 004A006E...
  const hex = hexOrStr.replace(/<|>|\s/g, '');
  if (/^[0-9A-Fa-f]+$/.test(hex) && hex.length % 4 === 0) {
    for (let i = 0; i < hex.length; i += 4) {
      const code = parseInt(hex.substr(i, 4), 16);
      const ch = (cmap && cmap[code]) || globalCMap[code] || String.fromCharCode(code);
      res += ch;
    }
  } else {
    res = hexOrStr;
  }
  return res;
}

// 3. Decode each page
const outputPages = [];

pages.forEach((p, pIdx) => {
  let pageStreams = '';
  p.contentObjs.forEach(cObj => {
    const s = getObjStream(cObj);
    if (s) pageStreams += '\n' + s;
  });

  const lines = pageStreams.split(/\r?\n/);
  let currentFont = '';
  let currentMap = globalCMap;
  const pageTexts = [];
  let currentLine = '';

  for (const l of lines) {
    // Font switch
    const fMatch = l.match(/\/(\w+)\s+[\d\.]+\s+Tf/);
    if (fMatch) {
      currentFont = fMatch[1];
      currentMap = p.pageFontMap[currentFont] || globalCMap;
    }

    // TJ array: [ (..) -10 (..) ] TJ or [ <..> -10 <..> ] TJ
    const tjArrayMatch = l.match(/\[(.*?)\]\s*TJ/);
    if (tjArrayMatch) {
      const inner = tjArrayMatch[1];
      const items = inner.match(/<[0-9A-Fa-f]+>|\([^)]*\)|-?\d+(\.\d+)?/g) || [];
      let tjText = '';
      for (const item of items) {
        if (item.startsWith('<')) {
          tjText += decodeString(item, currentMap);
        } else if (item.startsWith('(')) {
          tjText += item.slice(1, -1);
        } else {
          const kern = parseFloat(item);
          if (kern < -200) tjText += ' '; // space from negative kerning
        }
      }
      if (tjText.trim()) pageTexts.push(tjText.trim());
      continue;
    }

    // Tj: <hex> Tj
    const hexTjMatch = l.match(/<([0-9A-Fa-f]+)>\s*(Tj|'|")/);
    if (hexTjMatch) {
      const txt = decodeString(hexTjMatch[1], currentMap);
      if (txt.trim()) pageTexts.push(txt.trim());
      continue;
    }

    // Tj: (text) Tj
    const strTjMatch = l.match(/\((.*?)\)\s*(Tj|'|")/);
    if (strTjMatch) {
      const txt = strTjMatch[1];
      if (txt.trim()) pageTexts.push(txt.trim());
      continue;
    }
  }

  outputPages.push(`==================== TRANG ${pIdx + 1} ====================\n` + pageTexts.join('\n'));
});

const fullDoc = outputPages.join('\n\n');
fs.writeFileSync('D:/AI TBG/AI AUTO/docs/profile_thien_binh_full.txt', fullDoc, 'utf-8');
console.log('Saved fully decoded profile to profile_thien_binh_full.txt!');
console.log('\n--- PREVIEW PAGES 1-3 ---\n');
console.log(outputPages.slice(0, 3).join('\n\n'));
