import fs from 'fs';
import path from 'path';

const root = process.cwd();
const files = ['AGENTS.md', 'SPEC.md', 'index.md', 'log.md'];
let out = '# XEON-NEXUS-SENTINEL-LLM-WIKI-MASTER.md\n- Cuaderno Oficial: https://notebook.google.com/notebook/1bd607be-628c-4228-a1f5-5b4f5dd59093\n- Arquitectura: Google OKF v0.2 + Karpathy LLM Wiki\n';

for (const f of files) {
  const p = path.join(root, f);
  if (fs.existsSync(p)) {
    out += `\n\n================================================================================\n# FILE: ${f}\n================================================================================\n\n` + fs.readFileSync(p, 'utf8');
  }
}

const scan = (dir, prefix) => {
  if (!fs.existsSync(dir)) return;
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) {
      scan(full, `${prefix}/${e.name}`);
    } else if (e.name.endsWith('.md')) {
      out += `\n\n================================================================================\n# FILE: ${prefix}/${e.name}\n================================================================================\n\n` + fs.readFileSync(full, 'utf8');
    }
  }
};

scan(path.join(root, 'wiki'), 'wiki');
scan(path.join(root, 'raw'), 'raw');

const outPath = path.join(root, 'wiki', 'master-wiki-bundle.md');
fs.writeFileSync(outPath, out, 'utf8');
console.log(`Master bundle escrito en ${outPath} (${out.length} caracteres)`);
