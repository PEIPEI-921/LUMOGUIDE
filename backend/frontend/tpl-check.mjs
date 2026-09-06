// Web 前端 Vue 模板靜態檢查：用 @vue/compiler-dom 編譯所有組件 template，
// 防止「缺 > / 多餘閉合標籤」導致整頁無法渲染的問題回歸。
// 用法：node frontend/tpl-check.mjs（或 npm run check:templates）
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join, extname } from 'node:path';
import { compile } from '@vue/compiler-dom';

function walk(dir, acc = []) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    const st = statSync(p);
    if (st.isDirectory()) walk(p, acc);
    else if (extname(p) === '.js') acc.push(p);
  }
  return acc;
}

function* templateStrings(src) {
  const re = /template\s*:\s*(`|'|")/g;
  let m;
  while ((m = re.exec(src))) {
    const q = m[1];
    let i = re.lastIndex;
    let esc = false;
    let end = -1;
    for (; i < src.length; i++) {
      const c = src[i];
      if (esc) { esc = false; continue; }
      if (c === '\\') { esc = true; continue; }
      if (c === q) { end = i; break; }
    }
    if (end < 0) continue;
    yield src.slice(re.lastIndex, end);
    re.lastIndex = end + 1;
  }
}

const files = walk('frontend/js');
let total = 0;
const fails = [];
for (const fp of files) {
  const src = readFileSync(fp, 'utf8');
  for (const tpl of templateStrings(src)) {
    total++;
    try { compile(tpl, { mode: 'function' }); }
    catch (e) {
      fails.push(`${fp}: ${String(e.message || e).split('\n')[0]}`);
    }
  }
}
console.log(`templates: ${total}, failures: ${fails.length}`);
if (fails.length) {
  console.log([...new Set(fails)].join('\n'));
  process.exit(1);
}
