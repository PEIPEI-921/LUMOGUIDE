import { readFileSync, writeFileSync, mkdirSync, rmSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { transform } from 'esbuild';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');

const SRC_HTML = join(__dirname, 'index.html');
const DIST_DIR = join(__dirname, 'dist');
const DIST_JS = join(DIST_DIR, 'js');
const DIST_CSS = join(DIST_DIR, 'css');
const DIST_HTML = join(DIST_DIR, 'index.html');

// ── Step 1: Parse index.html ──
const html = readFileSync(SRC_HTML, 'utf-8');

// Extract local CSS <link> hrefs (in document order)
const cssHrefs = [];
for (const m of html.matchAll(/<link\s+rel="stylesheet"\s+href="(\/css\/[^"]+)"/g)) {
  cssHrefs.push(m[1]);
}
console.log(`[build] Found ${cssHrefs.length} CSS files`);

// Extract local JS <script> srcs (in document order)
const jsSrcs = [];
for (const m of html.matchAll(/<script\s+defer\s+src="(\/js\/[^"]+)"/g)) {
  jsSrcs.push(m[1]);
}
console.log(`[build] Found ${jsSrcs.length} JS files`);

// ── Step 2: Concatenate CSS ──
let cssSource = '';
for (const href of cssHrefs) {
  const cssPath = href.replace(/^\/css\//, '');
  const file = join(__dirname, 'css', cssPath);
  if (!existsSync(file)) {
    console.error(`[build] ERROR: CSS file not found: ${file}`);
    process.exit(1);
  }
  cssSource += `/* ${cssPath} */\n${readFileSync(file, 'utf-8')}\n`;
}

// ── Step 3: Concatenate JS ──
let jsSource = '';
for (const src of jsSrcs) {
  const jsPath = src.replace(/^\/js\//, '');
  const file = join(__dirname, 'js', jsPath);
  if (!existsSync(file)) {
    console.error(`[build] ERROR: JS file not found: ${file}`);
    process.exit(1);
  }
  jsSource += `/* ${jsPath} */\n${readFileSync(file, 'utf-8')}\n;\n`;
}

// ── Step 4: Minify with esbuild ──
console.log(`[build] CSS source: ${(cssSource.length / 1024).toFixed(1)} KB`);
console.log(`[build] JS source:  ${(jsSource.length / 1024).toFixed(1)} KB`);

const cssResult = await transform(cssSource, { loader: 'css', minify: true });
const jsResult = await transform(jsSource, {
  loader: 'js',
  minifyWhitespace: true,
  minifySyntax: true,
  minifyIdentifiers: false, // CRITICAL: router references page globals by name
});

console.log(`[build] CSS output: ${(cssResult.code.length / 1024).toFixed(1)} KB (${((1 - cssResult.code.length / cssSource.length) * 100).toFixed(0)}% reduction)`);
console.log(`[build] JS output:  ${(jsResult.code.length / 1024).toFixed(1)} KB (${((1 - jsResult.code.length / jsSource.length) * 100).toFixed(0)}% reduction)`);

// ── Step 5: Write with content-hash filenames ──
const cssHash = createHash('md5').update(cssResult.code).digest('hex').slice(0, 8);
const jsHash = createHash('md5').update(jsResult.code).digest('hex').slice(0, 8);

const cssFilename = `app.bundle.${cssHash}.css`;
const jsFilename = `app.bundle.${jsHash}.js`;

// Clean and recreate dist
if (existsSync(DIST_DIR)) rmSync(DIST_DIR, { recursive: true });
mkdirSync(DIST_CSS, { recursive: true });
mkdirSync(DIST_JS, { recursive: true });

writeFileSync(join(DIST_CSS, cssFilename), cssResult.code);
writeFileSync(join(DIST_JS, jsFilename), jsResult.code);

console.log(`[build] Written: dist/css/${cssFilename}`);
console.log(`[build] Written: dist/js/${jsFilename}`);

// ── Step 6: Generate production HTML ──
let prodHtml = html;

// Replace CSS block: remove individual <link rel="stylesheet" href="/css/..."> lines
// and insert the single bundle link at the position of the first CSS link
const firstCssMatch = prodHtml.match(/<link\s+rel="stylesheet"\s+href="\/css\/[^"]+">/);
if (firstCssMatch) {
  // Remove all local CSS links
  prodHtml = prodHtml.replace(/[ \t]*<link\s+rel="stylesheet"\s+href="\/css\/[^"]+">\n?/g, '');
  // Insert bundle CSS at the original CSS section position (after the "<!-- CSS -->" comment)
  prodHtml = prodHtml.replace(
    '<!-- CSS -->',
    `<!-- CSS (production bundle) -->\n  <link rel="stylesheet" href="/dist/css/${cssFilename}">`
  );
}

// Remove all local JS script tags
prodHtml = prodHtml.replace(/[ \t]*<script\s+defer\s+src="\/js\/[^"]+"><\/script>\n?/g, '');
// Strip standalone short HTML comment lines in <head> (now orphaned after script/link removal)
// Keep purpose comments: "CSS (production bundle)", "App bundle (production)"
prodHtml = prodHtml.replace(/^\s*<!-- (?!CSS \(|App bundle).*? -->\s*?\n/gm, '');
// Collapse consecutive blank lines
prodHtml = prodHtml.replace(/\n{3,}/g, '\n\n');

// Insert bundle JS after the last CDN script
const lastCdnInsert = prodHtml.lastIndexOf('</script>');
if (lastCdnInsert !== -1) {
  const insertPos = prodHtml.indexOf('\n', lastCdnInsert) + 1;
  prodHtml = prodHtml.slice(0, insertPos) +
    `\n  <!-- App bundle (production) -->\n  <script defer src="/dist/js/${jsFilename}"></script>\n` +
    prodHtml.slice(insertPos);
}

writeFileSync(DIST_HTML, prodHtml);
console.log(`[build] Written: dist/index.html`);
console.log(`[build] Done! HTTP requests: 2 CDN + 1 JS + 1 CSS = 4 total`);
