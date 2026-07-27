'use strict';
const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');
const { URL } = require('url');

const PORT = Number(process.env.PORT || 8765);
const ROOT = __dirname;

const TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.md': 'text/markdown; charset=utf-8',
  '.txt': 'text/plain; charset=utf-8'
};

const ALLOWED_HOSTS = new Set([
  'www.jma.go.jp',
  'cyberjapandata.gsi.go.jp'
]);

function send(res, code, body, headers) {
  res.writeHead(code, Object.assign({
    'Cache-Control': 'no-store',
    'Access-Control-Allow-Origin': '*'
  }, headers || {}));
  res.end(body);
}

function proxyRequest(targetUrl, res) {
  let parsed;
  try {
    parsed = new URL(targetUrl);
  } catch (e) {
    send(res, 400, 'Bad URL');
    return;
  }
  if (!ALLOWED_HOSTS.has(parsed.hostname)) {
    send(res, 403, 'Host not allowed');
    return;
  }
  const lib = parsed.protocol === 'http:' ? http : https;
  const req = lib.get(parsed, {
    headers: {
      'User-Agent': 'OsakaRainRadarSignage/1.0',
      'Accept': '*/*'
    },
    timeout: 20000
  }, (up) => {
    const chunks = [];
    up.on('data', (c) => chunks.push(c));
    up.on('end', () => {
      const buf = Buffer.concat(chunks);
      const type = up.headers['content-type'] || 'application/octet-stream';
      send(res, up.statusCode || 502, buf, { 'Content-Type': type });
    });
  });
  req.on('timeout', () => {
    req.destroy();
    if (!res.headersSent) send(res, 504, 'Upstream timeout');
  });
  req.on('error', (err) => {
    if (!res.headersSent) send(res, 502, 'Proxy error: ' + err.message);
  });
}

function serveFile(filePath, res) {
  fs.readFile(filePath, (err, data) => {
    if (err) {
      send(res, err.code === 'ENOENT' ? 404 : 500, err.code === 'ENOENT' ? 'Not Found' : 'Error');
      return;
    }
    const ext = path.extname(filePath).toLowerCase();
    send(res, 200, data, { 'Content-Type': TYPES[ext] || 'application/octet-stream' });
  });
}

const server = http.createServer((req, res) => {
  const raw = req.url || '/';
  const u = new URL(raw, 'http://127.0.0.1');
  const urlPath = decodeURIComponent(u.pathname);

  // CORS 回避: /api/jma/... → https://www.jma.go.jp/...
  if (urlPath.startsWith('/api/jma/')) {
    proxyRequest('https://www.jma.go.jp/' + urlPath.slice('/api/jma/'.length) + u.search, res);
    return;
  }
  // /api/gsi/... → https://cyberjapandata.gsi.go.jp/...
  if (urlPath.startsWith('/api/gsi/')) {
    proxyRequest('https://cyberjapandata.gsi.go.jp/' + urlPath.slice('/api/gsi/'.length) + u.search, res);
    return;
  }

  let filePath = path.join(ROOT, urlPath === '/' ? 'index.html' : urlPath);
  const rootResolved = path.resolve(ROOT);
  if (!path.resolve(filePath).startsWith(rootResolved)) {
    send(res, 403, 'Forbidden');
    return;
  }
  serveFile(filePath, res);
});

server.listen(PORT, '0.0.0.0', () => {
  console.log('雨雲レーダー 640×192 http://127.0.0.1:' + PORT + '/');
  console.log('自販機実寸 http://127.0.0.1:' + PORT + '/?native640=1');
});
