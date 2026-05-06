const fs = require('fs');
const base = 'http://localhost:5000';
const outdir = 's:/Projects/iStart/istart-backend/test_output';

if (!fs.existsSync(outdir)) fs.mkdirSync(outdir, { recursive: true });

async function run() {
  try {
    console.log('Registering founder...');
    const r1 = await fetch(`${base}/api/auth/register`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: 'Founder', email: 'founder@example.com', password: 'pass123', role: 'founder' })
    });
    const founder = await r1.json(); fs.writeFileSync(`${outdir}/founder.json`, JSON.stringify(founder, null, 2));

    console.log('Registering collaborator...');
    const r2 = await fetch(`${base}/api/auth/register`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: 'Collab', email: 'collab@example.com', password: 'pass123', role: 'collaborator' })
    });
    const collab = await r2.json(); fs.writeFileSync(`${outdir}/collab.json`, JSON.stringify(collab, null, 2));

    console.log('Registering investor...');
    const r3 = await fetch(`${base}/api/auth/register`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: 'Investor', email: 'investor@example.com', password: 'pass123', role: 'investor' })
    });
    const investor = await r3.json(); fs.writeFileSync(`${outdir}/investor.json`, JSON.stringify(investor, null, 2));

    console.log('Creating idea as founder...');
    const founderToken = founder.token;
    const r4 = await fetch(`${base}/api/ideas`, {
      method: 'POST', headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + founderToken },
      body: JSON.stringify({ title: 'Smoke Test Idea', description: 'Smoke test' })
    });
    const idea = await r4.json(); fs.writeFileSync(`${outdir}/idea.json`, JSON.stringify(idea, null, 2));

    console.log('Creating common thread (founder+collab+investor)');
    const collabToken = collab.token;
    const participants = [founder.user.id, collab.user.id, investor.user.id];
    const r5 = await fetch(`${base}/api/discussion`, {
      method: 'POST', headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + collabToken },
      body: JSON.stringify({ startupIdeaId: idea._id, title: 'Common Thread', participants })
    });
    const thread = await r5.json(); fs.writeFileSync(`${outdir}/thread.json`, JSON.stringify(thread, null, 2));

    console.log('Posting a message as collaborator...');
    const r6 = await fetch(`${base}/api/discussion/${thread._id}/messages`, {
      method: 'POST', headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + collabToken },
      body: JSON.stringify({ content: 'Hello from collaborator' })
    });
    const msg = await r6.json(); fs.writeFileSync(`${outdir}/message.json`, JSON.stringify(msg, null, 2));

    console.log('Fetching founder notifications...');
    const r7 = await fetch(`${base}/api/notifications`, { headers: { Authorization: 'Bearer ' + founderToken } });
    const notifs = await r7.json(); fs.writeFileSync(`${outdir}/notifications.json`, JSON.stringify(notifs, null, 2));

    console.log('Smoke test complete. Outputs written to', outdir);
  } catch (err) {
    console.error('Smoke test error:', err);
  }
}

run();
