const crypto = require('crypto');

function buildSignedWebhook(webhook, secret) {
  let url = String(webhook || '').trim();
  if (!url) throw new Error('缺少钉钉 Webhook');
  if (!/^https:\/\/oapi\.dingtalk\.com\/robot\/send\?/i.test(url)) {
    throw new Error('Webhook 格式不正确，必须是钉钉机器人 Webhook');
  }
  if (!secret) return url;
  const timestamp = Date.now();
  const stringToSign = `${timestamp}\n${secret}`;
  const sign = encodeURIComponent(
    crypto.createHmac('sha256', secret).update(stringToSign).digest('base64')
  );
  url += url.includes('?') ? '&' : '?';
  return `${url}timestamp=${timestamp}&sign=${sign}`;
}

module.exports = async function handler(req, res) {
  // Same-origin calls from your Vercel site normally do not need CORS,
  // but these headers also allow preview deployments to call this function.
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }
  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: '只支持 POST 请求' });
  }

  try {
    const body = typeof req.body === 'string' ? JSON.parse(req.body || '{}') : (req.body || {});
    const webhook = body.webhook;
    const secret = body.secret || '';
    const title = body.title || '站长周报';
    const content = body.content || '';
    if (!content.trim()) throw new Error('周报内容为空');

    const url = buildSignedWebhook(webhook, secret);
    const dingRes = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        msgtype: 'markdown',
        markdown: { title, text: content }
      })
    });
    const dingText = await dingRes.text();
    let dingData = {};
    try { dingData = JSON.parse(dingText); } catch (_) { dingData = { raw: dingText }; }

    if (!dingRes.ok || (dingData.errcode && dingData.errcode !== 0)) {
      throw new Error(dingData.errmsg || dingData.message || `钉钉返回 HTTP ${dingRes.status}`);
    }

    return res.status(200).json({ ok: true, dingtalk: dingData });
  } catch (err) {
    return res.status(400).json({ ok: false, error: err.message || String(err) });
  }
};
