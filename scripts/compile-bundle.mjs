import fs from 'fs';
import path from 'path';
import crypto from 'crypto';

const ROOT_DIR = process.cwd();
const files = [];

for (const rf of ['AGENTS.md', 'SPEC.md', 'index.md']) {
  const p = path.join(ROOT_DIR, rf);
  if (fs.existsSync(p)) files.push({ rel: rf, full: p });
}

const scanDir = (dirPath, relPrefix) => {
  if (!fs.existsSync(dirPath)) return;
  const entries = fs.readdirSync(dirPath, { withFileTypes: true });
  for (const entry of entries) {
    const full = path.join(dirPath, entry.name);
    if (entry.isDirectory()) {
      scanDir(full, `${relPrefix}/${entry.name}`);
    } else if (entry.name.endsWith('.md') && entry.name !== 'master-wiki-bundle.md') {
      files.push({ rel: `${relPrefix}/${entry.name}`, full });
    }
  }
};

scanDir(path.join(ROOT_DIR, 'wiki'), 'wiki');
scanDir(path.join(ROOT_DIR, 'raw'), 'raw');

const chunks = [];
for (const f of files) {
  chunks.push(`\n\n================================================================================\n# FILE: ${f.rel}\n================================================================================\n\n${fs.readFileSync(f.full, 'utf8').trim()}`);
}

if (fs.existsSync(path.join(ROOT_DIR, 'log.md'))) {
  chunks.push(`\n\n================================================================================\n# FILE: log.md\n================================================================================\n\n${fs.readFileSync(path.join(ROOT_DIR, 'log.md'), 'utf8')}`);
}

const rawBody = chunks.join('\n');
const sha256 = crypto.createHash('sha256').update(rawBody, 'utf8').digest('hex');
const header = `# XEON-NEXUS-SENTINEL-LLM-WIKI-MASTER.md — Compendio Maestro de Conocimiento Xeon-Nexus-Sentinel
- **Notebook URL:** https://notebook.google.com/notebook/1bd607be-628c-4228-a1f5-5b4f5dd59093
- **Archivos Compilados:** ${files.length + 1}
- **SHA-256:** \`${sha256}\`
- **Fecha:** ${new Date().toISOString()}
`;

fs.writeFileSync('master-wiki-bundle.md', header + rawBody);
console.log(`Compilado master-wiki-bundle.md: ${(header + rawBody).length} caracteres, ${files.length + 1} archivos, SHA-256: ${sha256}`);
