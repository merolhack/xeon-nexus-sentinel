#!/usr/bin/env node
/**
 * Sincroniza la LLM Wiki (wiki/, raw/, AGENTS.md, SPEC.md, index.md, log.md)
 * con el Gemini Notebook oficial de Xeon-Nexus-Sentinel:
 * https://notebook.google.com/notebook/1bd607be-628c-4228-a1f5-5b4f5dd59093
 * mediante @arlinamid/notebooklm-mcp (JSON-RPC 2.0 over stdio).
 *
 * Uso:
 *   node scripts/sync-wiki-to-notebook.mjs
 *   node scripts/sync-wiki-to-notebook.mjs --if-changed
 *   node scripts/sync-wiki-to-notebook.mjs --ask="¿Cómo se calcula el límite de hilos en RandomX?"
 */

import crypto from 'crypto';
import fs from 'fs';
import path from 'path';
import { spawn } from 'child_process';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const ROOT_DIR = path.resolve(__dirname, '..');
const WIKI_DIR = path.join(ROOT_DIR, 'wiki');
const RAW_DIR = path.join(ROOT_DIR, 'raw');
const STATE_FILE = path.join(ROOT_DIR, '.git', 'xeon-wiki-sync-state.json');

const NOTEBOOK_UUID = '1bd607be-628c-4228-a1f5-5b4f5dd59093';
const NOTEBOOK_ID = 'xeon-nexus-sentinel';
const MASTER_SOURCE_TITLE = 'XEON-NEXUS-SENTINEL-LLM-WIKI-MASTER.md';

const args = process.argv.slice(2);
const ifChangedOnly = args.includes('--if-changed');
const dryRun = args.includes('--dry-run');
const askArg = args.find((a) => a.startsWith('--ask='));
const askQuestionText = askArg ? askArg.slice('--ask='.length) : null;

function collectWikiFiles() {
  const ordered = [];
  const rootFiles = ['AGENTS.md', 'SPEC.md', 'index.md'];
  for (const rf of rootFiles) {
    const full = path.join(ROOT_DIR, rf);
    if (fs.existsSync(full)) ordered.push({ rel: rf, full });
  }

  const scanDir = (dirPath, relPrefix) => {
    if (!fs.existsSync(dirPath)) return;
    const entries = fs.readdirSync(dirPath, { withFileTypes: true });
    for (const entry of entries) {
      const full = path.join(dirPath, entry.name);
      if (entry.isDirectory()) {
        scanDir(full, `${relPrefix}/${entry.name}`);
      } else if (entry.name.endsWith('.md')) {
        if (entry.name === 'master-wiki-bundle.md') continue;
        ordered.push({ rel: `${relPrefix}/${entry.name}`, full });
      }
    }
  };

  scanDir(WIKI_DIR, 'wiki');
  scanDir(RAW_DIR, 'raw');

  return ordered;
}

function buildMasterWikiBundle() {
  const files = collectWikiFiles();
  const chunks = [];

  for (const file of files) {
    const body = fs.readFileSync(file.full, 'utf8').trim();
    chunks.push(`\n\n================================================================================\n# FILE: ${file.rel}\n================================================================================\n\n${body}`);
  }

  const logPath = path.join(ROOT_DIR, 'log.md');
  if (fs.existsSync(logPath)) {
    const logLines = fs.readFileSync(logPath, 'utf8').split(/\r?\n/).slice(0, 150).join('\n');
    chunks.push(`\n\n================================================================================\n# FILE: log.md (HISTORIAL Y BITÁCORA RECIENTE)\n================================================================================\n\n${logLines}`);
  }

  const rawBody = chunks.join('\n');
  const sha256 = crypto.createHash('sha256').update(rawBody, 'utf8').digest('hex');

  const header = [
    `# ${MASTER_SOURCE_TITLE} — Compendio Maestro de Conocimiento Xeon-Nexus-Sentinel`,
    `- **Notebook URL:** https://notebook.google.com/notebook/${NOTEBOOK_UUID}`,
    `- **Arquitectura:** Google OKF v0.2 + Karpathy 3-Layer LLM Wiki (\`raw/\`, \`wiki/\`, \`SPEC.md\`)`,
    `- **Archivos Compilados:** ${files.length + 1}`,
    `- **SHA-256:** \`${sha256}\``,
    `- **Fecha de Compilación:** ${new Date().toISOString()}`,
  ].join('\n');

  return {
    content: `${header}\n${rawBody}\n`,
    sha256,
    fileCount: files.length + 1,
  };
}

function hasGitWikiChanges(currentSha256) {
  try {
    if (fs.existsSync(STATE_FILE)) {
      const saved = JSON.parse(fs.readFileSync(STATE_FILE, 'utf8'));
      if (saved.sha256 === currentSha256) {
        return false;
      }
    }
  } catch {
    // Ignorar si el archivo de estado está corrupto
  }
  return true;
}

class McpStdioClient {
  constructor() {
    this.proc = null;
    this.buffer = '';
    this.pending = new Map();
    this.nextId = 1;
  }

  async start() {
    const isWin = process.platform === 'win32';
    const cmd = isWin ? 'npx.cmd' : 'npx';
    this.proc = spawn(cmd, ['-y', '-p', '@arlinamid/notebooklm-mcp@latest', 'notebooklm-mcp'], {
      stdio: ['pipe', 'pipe', 'pipe'],
      shell: isWin,
    });

    this.proc.stdout.on('data', (chunk) => {
      this.buffer += chunk.toString('utf8');
      let idx;
      while ((idx = this.buffer.indexOf('\n')) !== -1) {
        const line = this.buffer.slice(0, idx).trim();
        this.buffer = this.buffer.slice(idx + 1);
        if (!line.startsWith('{')) continue;
        try {
          const msg = JSON.parse(line);
          if (msg.id && this.pending.has(msg.id)) {
            const { resolve, reject } = this.pending.get(msg.id);
            this.pending.delete(msg.id);
            if (msg.error) reject(new Error(msg.error.message || JSON.stringify(msg.error)));
            else resolve(msg.result);
          }
        } catch {
          // Ignorar lineas no-JSON
        }
      }
    });

    await this.request('initialize', {
      protocolVersion: '2024-11-05',
      capabilities: {},
      clientInfo: { name: 'xeon-wiki-sync', version: '1.0.0' },
    });
    this.notify('notifications/initialized', {});
  }

  request(method, params, timeoutMs = 180000) {
    const id = this.nextId++;
    const payload = JSON.stringify({ jsonrpc: '2.0', id, method, params }) + '\n';
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`MCP timeout (${timeoutMs}ms) en ${method}`));
      }, timeoutMs);
      this.pending.set(id, {
        resolve: (val) => {
          clearTimeout(timer);
          resolve(val);
        },
        reject: (err) => {
          clearTimeout(timer);
          reject(err);
        },
      });
      this.proc.stdin.write(payload);
    });
  }

  notify(method, params) {
    this.proc.stdin.write(JSON.stringify({ jsonrpc: '2.0', method, params }) + '\n');
  }

  async callTool(name, argsObj, timeoutMs = 180000) {
    const res = await this.request('tools/call', { name, arguments: argsObj }, timeoutMs);
    if (res?.structuredContent) return res.structuredContent;
    const text = res?.content?.[0]?.text;
    if (text) {
      try {
        return JSON.parse(text);
      } catch {
        return { raw: text };
      }
    }
    return res;
  }

  close() {
    if (this.proc) {
      try {
        this.proc.stdin.end();
        this.proc.kill('SIGTERM');
      } catch {
        // Ignorar
      }
    }
  }
}

async function main() {
  const bundle = buildMasterWikiBundle();
  console.log(`📚 Compilados ${bundle.fileCount} archivos de la LLM Wiki (${bundle.content.length} caracteres, SHA-256: ${bundle.sha256.slice(0, 12)}...)`);

  // Actualizar copia local compilada de la Wiki
  fs.writeFileSync(path.join(WIKI_DIR, 'master-wiki-bundle.md'), bundle.content, 'utf8');

  if (ifChangedOnly && !hasGitWikiChanges(bundle.sha256) && !askQuestionText) {
    console.log('✅ El hash SHA-256 coincide con el último estado sincronizado. Saltando subida.');
    process.exit(0);
  }

  if (dryRun) {
    console.log('✅ Modo dry-run completado.');
    process.exit(0);
  }

  const client = new McpStdioClient();
  let sessionId;
  try {
    await client.start();
    const health = await client.callTool('get_health', {});
    if (!health?.data?.authenticated) {
      throw new Error('notebooklm-mcp no está autenticado. Ejecuta setup_auth primero.');
    }

    if (!ifChangedOnly || hasGitWikiChanges(bundle.sha256)) {
      console.log('🔍 Verificando fuentes existentes en Gemini Notebook...');
      const sourcesRes = await client.callTool('list_sources', { notebook_id: NOTEBOOK_ID });
      sessionId = sourcesRes?.data?.session_id || sessionId;
      const sources = sourcesRes?.data?.sources || [];
      const oldWikiSources = sources.filter(
        (s) =>
          typeof s.title === 'string' &&
          (s.title.startsWith('XEON-NEXUS-SENTINEL-LLM-WIKI') ||
           s.title === MASTER_SOURCE_TITLE ||
           s.title.includes('master-wiki-bundle'))
      );

      console.log(`📤 Subiendo ${MASTER_SOURCE_TITLE} a Gemini Notebook (${NOTEBOOK_UUID})...`);
      const addRes = await client.callTool('add_source', {
        notebook_id: NOTEBOOK_ID,
        ...(sessionId ? { session_id: sessionId } : {}),
        type: 'text',
        title: MASTER_SOURCE_TITLE,
        content: bundle.content,
      });
      sessionId = addRes?.data?.session_id || sessionId;

      if (!addRes?.success) {
        throw new Error(`Fallo al subir fuente a Gemini Notebook: ${JSON.stringify(addRes)}`);
      }
      console.log(`✅ Fuente subida exitosamente: ${MASTER_SOURCE_TITLE}`);

      for (const oldSrc of oldWikiSources) {
        console.log(`🧹 Eliminando captura previa: ${oldSrc.title} (${oldSrc.id})...`);
        await client.callTool('delete_source', {
          notebook_id: NOTEBOOK_ID,
          ...(sessionId ? { session_id: sessionId } : {}),
          source: oldSrc.id,
          confirm: true,
        });
      }

      fs.writeFileSync(
        STATE_FILE,
        JSON.stringify(
          {
            sha256: bundle.sha256,
            syncedAt: new Date().toISOString(),
            fileCount: bundle.fileCount,
            charCount: bundle.content.length,
          },
          null,
          2
        ),
        'utf8'
      );
    }

    if (askQuestionText) {
      console.log(`💬 Preguntando a Gemini Notebook: "${askQuestionText}"...`);
      const askRes = await client.callTool(
        'ask_question',
        {
          notebook_id: NOTEBOOK_ID,
          ...(sessionId ? { session_id: sessionId } : {}),
          question: askQuestionText,
        },
        240000
      );
      console.log('\n================ RESPUESTA GEMINI NOTEBOOK ================\n');
      console.log(askRes?.data?.answer || JSON.stringify(askRes, null, 2));
      console.log('\n===========================================================\n');
    }
  } finally {
    client.close();
  }
  process.exit(0);
}

main().catch((err) => {
  console.error(`❌ Fallo en sincronización de la Wiki: ${err.message}`);
  process.exit(1);
});
