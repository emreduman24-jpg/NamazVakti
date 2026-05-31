import { defineConfig } from 'vite';
import { resolve } from 'path';
import fs from 'fs';

const dbPath = resolve(__dirname, 'db.json');

function readDb() {
  try {
    return JSON.parse(fs.readFileSync(dbPath, 'utf8'));
  } catch (e) {
    return {};
  }
}

function writeDb(data) {
  fs.writeFileSync(dbPath, JSON.stringify(data, null, 2), 'utf8');
}

export default defineConfig({
  server: {
    host: true,
    port: 5173,
  },
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        admin: resolve(__dirname, 'admin.html'),
      },
    },
  },
  plugins: [
    {
      name: 'api-server',
      configureServer(server) {
        server.middlewares.use(async (req, res, next) => {
          // Enable CORS
          res.setHeader('Access-Control-Allow-Origin', '*');
          res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
          res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

          if (req.method === 'OPTIONS') {
            res.statusCode = 204;
            res.end();
            return;
          }

          if (req.url.startsWith('/api/')) {
            res.setHeader('Content-Type', 'application/json');
            const db = readDb();

            // Read request body
            const body = await new Promise((resolve) => {
              let chunkStr = '';
              req.on('data', chunk => chunkStr += chunk);
              req.on('end', () => {
                try {
                  resolve(JSON.parse(chunkStr));
                } catch {
                  resolve(null);
                }
              });
            });

            const path = req.url.split('?')[0];

            // 1. DUAS ENDPOINTS
            if (path === '/api/duas') {
              if (req.method === 'GET') {
                res.end(JSON.stringify(db.duas || []));
              } else if (req.method === 'POST') {
                if (Array.isArray(body)) {
                  db.duas = body;
                } else if (body) {
                  db.duas = db.duas || [];
                  const newDua = {
                    id: body.id || Date.now(),
                    yazar: body.yazar || 'Anonim',
                    dua: body.dua || '',
                    amin: body.amin || 0,
                    durum: body.durum || 'bekliyor',
                    tarih: body.tarih || new Date().toLocaleString('tr-TR')
                  };
                  db.duas.unshift(newDua);
                }
                writeDb(db);
                res.end(JSON.stringify(db.duas));
              }
            } else if (path === '/api/duas/approve' && req.method === 'POST') {
              const id = body && body.id;
              if (id) {
                db.duas = db.duas || [];
                const target = db.duas.find(d => d.id === id);
                if (target) {
                  target.durum = 'yayinda';
                  writeDb(db);
                }
              }
              res.end(JSON.stringify(db.duas));
            } else if (path === '/api/duas/delete' && req.method === 'POST') {
              const id = body && body.id;
              if (id) {
                db.duas = (db.duas || []).filter(d => d.id !== id);
                writeDb(db);
              }
              res.end(JSON.stringify(db.duas));
            } else if (path === '/api/duas/amin' && req.method === 'POST') {
              const id = body && body.id;
              if (id) {
                db.duas = db.duas || [];
                const target = db.duas.find(d => d.id === id);
                if (target) {
                  target.amin = (target.amin || 0) + 1;
                  writeDb(db);
                }
              }
              res.end(JSON.stringify(db.duas));
            }

            // 2. QUESTIONS ENDPOINTS
            else if (path === '/api/questions') {
              if (req.method === 'GET') {
                res.end(JSON.stringify(db.questions || []));
              } else if (req.method === 'POST') {
                if (Array.isArray(body)) {
                  db.questions = body;
                } else if (body) {
                  db.questions = db.questions || [];
                  const newQ = {
                    id: body.id || Date.now(),
                    soru: body.soru || '',
                    cevap: body.cevap || '',
                    yazar: body.yazar || 'Anonim',
                    tarih: body.tarih || new Date().toLocaleString('tr-TR')
                  };
                  db.questions.unshift(newQ);
                }
                writeDb(db);
                res.end(JSON.stringify(db.questions));
              }
            } else if (path === '/api/questions/answer' && req.method === 'POST') {
              const { id, cevap } = body || {};
              if (id && cevap) {
                db.questions = db.questions || [];
                const target = db.questions.find(q => q.id === id);
                if (target) {
                  target.cevap = cevap;
                  writeDb(db);
                }
              }
              res.end(JSON.stringify(db.questions));
            } else if (path === '/api/questions/delete' && req.method === 'POST') {
              const id = body && body.id;
              if (id) {
                db.questions = (db.questions || []).filter(q => q.id !== id);
                writeDb(db);
              }
              res.end(JSON.stringify(db.questions));
            }

            // 3. CHAT ENDPOINTS
            else if (path === '/api/chat') {
              if (req.method === 'GET') {
                res.end(JSON.stringify(db.chat || []));
              } else if (req.method === 'POST') {
                if (Array.isArray(body)) {
                  db.chat = body;
                } else if (body) {
                  db.chat = db.chat || [];
                  const newMsg = {
                    id: body.id || Date.now(),
                    yazar: body.yazar || 'Anonim',
                    metin: body.metin || '',
                    tarih: body.tarih || new Date().toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' }),
                    isAdmin: body.isAdmin || false
                  };
                  db.chat.push(newMsg);
                  if (db.chat.length > 50) db.chat.shift();
                }
                writeDb(db);
                res.end(JSON.stringify(db.chat));
              }
            }

            // 4. STORIES ENDPOINTS
            else if (path === '/api/stories') {
              if (req.method === 'GET') {
                res.end(JSON.stringify(db.stories || []));
              } else if (req.method === 'POST') {
                if (Array.isArray(body)) {
                  db.stories = body;
                } else if (body) {
                  db.stories = db.stories || [];
                  const idx = db.stories.findIndex(s => s.id === body.id);
                  if (idx !== -1) {
                    db.stories[idx] = body;
                  } else {
                    db.stories.push(body);
                  }
                }
                writeDb(db);
                res.end(JSON.stringify(db.stories));
              }
            } else if (path === '/api/stories/delete' && req.method === 'POST') {
              const id = body && body.id;
              if (id) {
                db.stories = (db.stories || []).filter(s => s.id !== id);
                writeDb(db);
              }
              res.end(JSON.stringify(db.stories));
            }

            // 5. USERS ENDPOINTS
            else if (path === '/api/users') {
              if (req.method === 'GET') {
                res.end(JSON.stringify(db.users || []));
              } else if (req.method === 'POST') {
                if (Array.isArray(body)) {
                  db.users = body;
                } else if (body && body.eposta) {
                  db.users = db.users || [];
                  const target = db.users.find(u => u.eposta === body.eposta);
                  if (target) {
                    target.engelli = body.engelli !== undefined ? body.engelli : !target.engelli;
                  } else {
                    db.users.push(body);
                  }
                }
                writeDb(db);
                res.end(JSON.stringify(db.users));
              }
            }

            // 6. BLOCK STATUS
            else if (path === '/api/block_status') {
              if (req.method === 'GET') {
                res.end(JSON.stringify(db.block_status || { blocked: false }));
              } else if (req.method === 'POST') {
                if (body && body.blocked !== undefined) {
                  db.block_status = { blocked: body.blocked };
                  writeDb(db);
                }
                res.end(JSON.stringify(db.block_status));
              }
            }

            // 7. TOOLS ENDPOINTS
            else if (path === '/api/tools') {
              if (req.method === 'GET') {
                const tools = db.tools || [];
                res.end(JSON.stringify(tools));
              } else if (req.method === 'POST') {
                if (Array.isArray(body)) {
                  db.tools = body;
                  writeDb(db);
                }
                res.end(JSON.stringify(db.tools || []));
              }
            }

            else {
              res.statusCode = 404;
              res.end(JSON.stringify({ error: 'Endpoint not found' }));
            }
          } else {
            next();
          }
        });
      }
    }
  ]
});
