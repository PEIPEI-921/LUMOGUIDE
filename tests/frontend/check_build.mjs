// =============================================================================
// 前端构建产物完整性校验（node 脚本，无依赖）
//
// 用途：前端改动重新构建后，验证 dist 产物完整、引用正确。
// 运行：node tests/frontend/check_build.mjs
// =============================================================================
import { readFileSync, existsSync, statSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const DIST = join(__dirname, '../../backend/frontend/dist');

let fails = 0;
const check = (ok, msg) => {
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${msg}`);
  if (!ok) fails++;
};

// 1. dist 目录与 index.html 存在
const htmlPath = join(DIST, 'index.html');
if (!existsSync(htmlPath)) {
  check(false, `dist/index.html 不存在（需先运行 node frontend/build.mjs）`);
  process.exit(1);
}
const html = readFileSync(htmlPath, 'utf-8');

// 2. index.html 中所有本地资源引用（/css/ /js/ 或 /dist/css/ /dist/js/）在 dist 中真实存在且非空
const refs = [...html.matchAll(/(?:src|href)="(\/(?:dist\/)?(?:css|js)\/[^"]+)"/g)].map((m) => m[1]);
check(refs.length > 0, `index.html 引用 ${refs.length} 个本地资源`);
for (const ref of refs) {
  const file = join(DIST, ref.replace(/^\/dist\//, '/'));
  const ok = existsSync(file) && statSync(file).size > 1024;
  check(ok, `资源存在且非空: ${ref}${ok ? ` (${statSync(file).size}B)` : ''}`);
}

// 3. 所有引用均为带 hash 的 bundle 产物（构建输出），不允许引用源文件
const sourceRefs = refs.filter((r) => !/app\.bundle\.[a-f0-9]{6,}\.(js|css)$/.test(r));
check(sourceRefs.length === 0, `所有引用均为 bundle 产物（发现 ${sourceRefs.length} 个源文件引用: ${sourceRefs.join(', ')}）`);

// 4. JS bundle 内容健康：可被解析（语法检查）
for (const ref of refs.filter((r) => r.endsWith('.js'))) {
  const file = join(DIST, ref.replace(/^\/dist\//, '/'));
  try {
    new Function(readFileSync(file, 'utf-8'));
    check(true, `JS 语法检查通过: ${ref}`);
  } catch (e) {
    check(false, `JS 语法错误: ${ref} — ${e.message}`);
  }
}

// 5. index.html 基本结构：有 html 与 body 闭合，含移动端 viewport
check(/<html[\s\S]*<\/html>/.test(html), 'HTML 结构完整');
check(/name="viewport"/.test(html), '包含移动端 viewport 配置');

console.log('======================================');
console.log(fails === 0 ? '前端构建产物校验全部通过 ✓' : `存在 ${fails} 个问题`);
process.exit(fails > 0 ? 1 : 0);
