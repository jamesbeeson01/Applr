// The review page. Reads everything from /api/data and writes only through
// POST /api/decide, which checks each move before recording it.
"use strict";

const STATUS_KEY = { "Agent approved": "you", "Rejected": "rejected", "Unreviewed": "agent", "Human approved": "approved" };
const STATUS_LABEL = { you: "your turn", rejected: "sent back", agent: "agent queue", approved: "approved" };
const GROUP_ORDER = ["you", "rejected", "agent", "approved"];
const VIEW_KIND = { image: "image", text: "text diff", states: "states + live" };
const QUICK_NOTES = ["Labels clipped", "Spacing too tight", "Line doesn't match the expected behaviour",
  "Wording unclear", "Legend wrong", "Agent note doesn't match what I see"];
const PAGES = ["overview", "inventory", "health", "principles", "structure"];

const arr = x => x == null ? [] : Array.isArray(x) ? x : [x];
const esc = s => String(s ?? "").replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]);

let DATA = null, OUT = {}, CASES = {}, ENTRIES = {}, GUIDE = {};
const forms = {};
const ui = { view: "case", sel: null, collapsed: false, compare: "swipe", filter: "", rejecting: false, draft: "",
  open: { you: true, rejected: true, agent: true, approved: false }, sessionTotal: null, done: 0, error: null, busy: false };

const key = o => STATUS_KEY[o.status] || "agent";
const ids = () => Object.keys(OUT).sort();
const yourQueue = () => ids().filter(id => key(OUT[id]) === "you");
const caseOf = o => CASES[o.case] || { name: o.case, covers: [], unknown: [], family: "not in the inventory" };
const pill = s => `<span class="pill s-${s}">${STATUS_LABEL[s]}</span>`;

async function load() {
  const r = await fetch("/api/data", { cache: "no-store" });
  DATA = await r.json();
  OUT = {}; CASES = {}; ENTRIES = {};
  arr(DATA.outputs).forEach(o => OUT[o.id] = o);
  arr(DATA.cases).forEach(c => CASES[c.name] = c);
  arr(DATA.inventory?.entries).forEach(e => ENTRIES[e.id] = e);
  if (ui.sessionTotal === null) ui.sessionTotal = yourQueue().length;
}

async function loadGuide() {
  const html = await (await fetch("/page/guide.html", { cache: "no-store" })).text();
  const doc = new DOMParser().parseFromString(html, "text/html");
  doc.querySelectorAll("template[id]").forEach(t => GUIDE[t.id] = t.innerHTML);
}

async function loadForm(id) {
  if (forms[id]) return forms[id];
  const r = await fetch("/api/form?id=" + encodeURIComponent(id), { cache: "no-store" });
  forms[id] = r.ok ? await r.json() : { error: (await r.json()).error };
  return forms[id];
}

// ---- URL: ?output=<id>, ?case=<case> or ?view=<page> ----
function readUrl() {
  const p = new URLSearchParams(location.search);
  const view = p.get("view"), output = p.get("output"), cs = p.get("case");
  ui.sel = yourQueue()[0] || null;
  ui.view = "overview";
  if (PAGES.includes(view)) { ui.view = view; return; }
  const linked = (output && OUT[output] && output) || (cs && firstOutputOf(cs));
  if (linked) { ui.view = "case"; ui.sel = linked; }
}
function syncUrl() {
  const u = new URL(location); u.search = "";
  if (ui.view !== "case") u.searchParams.set("view", ui.view);
  else if (ui.sel) u.searchParams.set("output", ui.sel);
  history.replaceState(null, "", u);
}
function go(view, sel) {
  ui.view = view; if (sel !== undefined) ui.sel = sel;
  ui.rejecting = false; ui.draft = ""; ui.error = null;
  syncUrl(); render();
  document.querySelector("main")?.scrollTo(0, 0);
}
const firstOutputOf = cs => ids().find(id => OUT[id].case === cs);

// ---- sidebar ----
function sidebar() {
  const q = yourQueue().length;
  if (ui.collapsed) return `<aside><div class="rail">
      <button title="Expand sidebar ( [ )" data-act="toggle">☰</button>
      <button title="Your queue" data-act="case" class="${ui.view === "case" ? "on" : ""}">✓${q ? `<span class="badge">${q}</span>` : ""}</button>
      <button title="Suite overview (o)" data-go="overview" class="${ui.view === "overview" ? "on" : ""}">▦</button>
      <button title="Behaviour inventory" data-go="inventory" class="${ui.view === "inventory" ? "on" : ""}">☷</button>
      <button title="Suite health" data-go="health" class="${ui.view === "health" ? "on" : ""}">♥</button>
      <button title="Guide" data-go="principles" class="rail-foot ${ui.view === "principles" || ui.view === "structure" ? "on" : ""}">?</button></div></aside>`;
  const f = ui.filter.toLowerCase();
  const shown = ids().filter(id => id.toLowerCase().includes(f) || OUT[id].type.toLowerCase().includes(f));
  const groups = GROUP_ORDER.map(g => {
    const gi = shown.filter(id => key(OUT[id]) === g);
    if (!gi.length) return "";
    const open = ui.open[g] || ui.filter;
    return `<div class="group-h" data-group="${g}"><span>${STATUS_LABEL[g]} (${gi.length})</span><span>${open ? "−" : "+"}</span></div>` +
      (open ? gi.map(id => `<div class="item ${ui.view === "case" && id === ui.sel ? "sel" : ""}" data-pick="${esc(id)}"><span>${esc(id)}</span>
        <span class="tag">${OUT[id].rejection_note ? "✎ " : ""}${esc(VIEW_KIND[OUT[id].view] || OUT[id].view)}</span></div>`).join("") : "");
  }).join("");
  const nav = (v, label, k) => `<div class="nav ${ui.view === v ? "sel" : ""}" data-go="${v}"><span>${label}</span>${k ? `<kbd>${k}</kbd>` : ""}</div>`;
  return `<aside><div class="side-top"><b>Applr review</b><button class="ghost" title="Collapse sidebar ( [ )" data-act="toggle">«</button></div>
    <div class="side-body">
      ${nav("overview", "▦ Suite overview", "o")}
      ${nav("inventory", "☷ Behaviour inventory")}
      ${nav("health", "♥ Suite health")}
      <div style="margin:10px 0 0"><input type="search" id="find" placeholder="Find an output…" value="${esc(ui.filter)}"></div>
      ${groups || `<p class="muted small">No judged outputs${ui.filter ? " match" : " yet: run <code>suite.R run</code>"}.</p>`}
      <p class="muted small" style="margin-top:16px"><kbd>j</kbd>/<kbd>k</kbd> next/prev in your queue · <kbd>a</kbd> approve · <kbd>r</kbd> reject with note · <kbd>s</kbd> swipe/side by side · <kbd>o</kbd> overview · <kbd>[</kbd> sidebar</p>
    </div>
    <div class="side-foot"><div class="nav-h">Guide</div>${nav("principles", "Principles")}${nav("structure", "Structure")}</div></aside>`;
}

// ---- case detail ----
function stateView(url, alt) {
  if (!url) return `<div class="noview">No view rendered. Views are rendered while an output is Unreviewed; run <code>suite.R run</code>.</div>`;
  return /\.html?$/i.test(url) ? `<iframe class="state-frame" src="${esc(url)}" title="${esc(alt)}"></iframe>` : `<img src="${esc(url)}" alt="${esc(alt)}">`;
}

function compareToggle() {
  return `<div class="actions"><h4 style="margin:0">Compare with last approved</h4>
    <button class="${ui.compare === "swipe" ? "on" : ""}" data-compare="swipe">Swipe</button>
    <button class="${ui.compare === "pair" ? "on" : ""}" data-compare="pair">Side by side</button><kbd>s</kbd></div>`;
}

function imageView(o) {
  const s = arr(o.states)[0] || {};
  const canCompare = s.approved_url && s.url && key(o) !== "approved" && !/\.html?$/i.test(s.url);
  if (!canCompare) {
    return `${s.approved_url || key(o) === "approved" ? "" : `<p class="muted small">No approved render to compare with yet: this output has never been Human approved.</p>`}
      <div style="max-width:900px">${stateView(s.url, s.name)}</div>`;
  }
  return compareToggle() + (ui.compare === "swipe"
    ? `<div class="swipe" data-swipe><img src="${esc(s.approved_url)}" alt="approved"><div class="newer" style="clip-path: inset(0 0 0 50%)"><img src="${esc(s.url)}" alt="new"></div>
        <div class="bar" style="left:50%"></div><span class="lbl" style="left:6px">approved</span><span class="lbl" style="right:6px">new</span></div>`
    : `<div class="pair"><div><h4>Approved</h4><img src="${esc(s.approved_url)}" alt="approved"></div><div><h4>New</h4><img src="${esc(s.url)}" alt="new"></div></div>`);
}

function statesView(o) {
  const states = arr(o.states);
  const anyApproved = states.some(s => s.approved_url) && key(o) !== "approved";
  const grid = which => `<div class="states">${states.map(s => `<div><h4>${which === "approved" ? "approved: " : "state: "}${esc(s.name)}</h4>
      ${stateView(which === "approved" ? s.approved_url : s.url, s.name)}</div>`).join("")}</div>`;
  const compare = anyApproved ? compareToggle().replace("Swipe", "New only").replace("Side by side", "With approved") : "";
  return `${compare}${grid("new")}${anyApproved && ui.compare === "pair" ? grid("approved") : ""}
    ${o.live ? `<details open><summary>Live widget: try it before approving</summary><iframe src="${esc(o.live)}" title="live widget"></iframe></details>` : ""}`;
}

function diffBlock(lines) {
  return `<div class="console">${arr(lines).map(l => {
    const c = /^\+(?!\+\+)/.test(l) ? "add" : /^-(?!--)/.test(l) ? "del" : /^@@/.test(l) ? "hunk" : "";
    return `<div class="${c}">${esc(l) || "&nbsp;"}</div>`;
  }).join("")}</div>`;
}

function formView(id, open) {
  const f = forms[id];
  if (!f) { loadForm(id).then(() => ui.view === "case" && ui.sel === id && render()); return `<p class="muted small">Loading the serialised form…</p>`; }
  if (f.error) return `<div class="error">${esc(f.error)}</div>`;
  const full = `<details ${open && !f.diff ? "open" : ""}><summary>Full serialised form (${arr(f.form).length} lines)</summary>${diffBlock(f.form)}</details>`;
  if (!f.diff) return `<p class="muted small">No approved version to diff against yet.</p>${full}`;
  const same = arr(f.diff).length === 1 && /identical/.test(f.diff[0]);
  return `${same ? `<p class="muted small">Identical to the last approved version.</p>` : `<div><h4>Changes since the last approved version</h4>${diffBlock(f.diff)}</div>`}${full}`;
}

function textView(o) { return formView(o.id, true); }

function expected(o) {
  const c = caseOf(o);
  const cited = arr(c.covers).map(id => ENTRIES[id]).filter(Boolean);
  const unknown = arr(c.unknown);
  if (!cited.length && !unknown.length) return `<div class="expect"><b>Expected:</b> <span class="muted">this case cites no inventory entries.</span></div>`;
  return `<div class="expect"><b>Expected</b> <span class="muted small">(from the inventory entries this case covers)</span><ul>
    ${cited.map(e => `<li>${esc(e.principle)} <a class="mono" href="?view=inventory" data-go="inventory">${esc(e.id)}</a></li>`).join("")}
    ${unknown.map(id => `<li class="tag-bad">Cites ${esc(id)}, which isn't in the inventory.</li>`).join("")}</ul></div>`;
}

function decisionBar(o) {
  const k = key(o);
  if (k === "agent") return `<p class="muted small">Waiting for an agent pass. Outputs come to you once an agent approves them.</p>`;
  if (k !== "you") return "";
  if (!ui.rejecting) return `<div class="actions"><button class="approve" data-act="approve" ${ui.busy ? "disabled" : ""}>Approve <kbd class="on-solid">a</kbd></button>
      <button class="reject" data-act="reject" ${ui.busy ? "disabled" : ""}>Reject… <kbd>r</kbd></button></div>`;
  return `<div class="rejectbox"><b>Send back to the agent</b>
    <div class="muted small">A note is required. The agent reads it before its next attempt.</div>
    <div class="chips">${QUICK_NOTES.map(n => `<button data-chip="${esc(n)}">${esc(n)}</button>`).join("")}</div>
    <textarea id="note" placeholder="What's wrong, and what would right look like?">${esc(ui.draft)}</textarea>
    <div class="actions"><button class="reject solid" data-act="confirm-reject" ${ui.busy ? "disabled" : ""}>Reject and send <kbd class="on-solid">Ctrl+Enter</kbd></button>
      <button class="ghost" data-act="cancel-reject">Cancel <kbd>Esc</kbd></button></div></div>`;
}

function notes(o) {
  const k = key(o), by = o.who === "human" ? "you" : o.who === "agent" ? "the agent" : o.who;
  return [
    k === "rejected" && o.rejection_note ? `<div class="yournote"><b>Rejected by ${esc(by)}:</b> ${esc(o.rejection_note)}</div>` : "",
    k === "approved" ? `<div class="oknote"><b>Approved by you</b> <span class="muted small">${esc(o.when)}</span>${o.human_note ? ": " + esc(o.human_note) : ""}</div>` : "",
    o.agent_note ? `<div class="agentnote"><b>Agent:</b> ${esc(o.agent_note)}</div>` : ""
  ].join("");
}

function caseView() {
  const o = OUT[ui.sel];
  const q = yourQueue();
  const total = Math.max(ui.sessionTotal, ui.done + q.length);
  const prog = total ? `<div class="small muted">Your queue: ${ui.done} of ${total} done${q.length ? "" : " ✓ nothing left for you"}</div>
    <div class="progress"><div style="width:${ui.done / total * 100}%"></div></div>` : "";
  if (!o) {
    const n = ids().length;
    return `${prog}<div class="empty"><h2>${q.length ? "Pick an output" : "Nothing needs you"}</h2>
      <p class="muted">${n ? `${n} judged output${n > 1 ? "s" : ""} in the suite. Outputs reach you after an agent approves them.` : "No judged outputs yet."}</p>
      <button data-go="overview">Open the suite overview</button></div>`;
  }
  const c = caseOf(o);
  const visual = o.view === "text" ? textView(o) : o.view === "states" ? statesView(o) : imageView(o);
  return `${prog}
    ${ui.error ? `<div class="error">${esc(ui.error)}</div>` : ""}
    <div class="head"><h2>${esc(o.id)}</h2>${pill(key(o))}</div>
    <div class="muted small">${esc(c.family)} · ${esc(o.type)} · ${esc(VIEW_KIND[o.view] || o.view)} · fingerprint <span class="mono">${esc(o.fingerprint)}</span>
      ${arr(o.parts).length > 1 ? ` (parts: ${arr(o.parts).map(esc).join(", ")})` : ""} · set by ${esc(o.who)} ${esc(o.when)}</div>
    ${decisionBar(o)}
    ${notes(o)}
    ${expected(o)}
    ${visual}
    ${o.view !== "text" ? `<details data-form><summary>Serialised form and what changed</summary>${forms[o.id] ? formView(o.id, false) : ""}</details>` : ""}`;
}

// ---- overview ----
function overview() {
  const fams = {};
  ids().forEach(id => (fams[caseOf(OUT[id]).family] ||= []).push(id));
  const count = s => ids().filter(id => key(OUT[id]) === s).length;
  const f = ui.filter.toLowerCase();
  const rows = Object.keys(fams).sort().map(fam => `<div class="fam"><div><b>${esc(fam)}</b><span class="muted">${fams[fam].length} output${fams[fam].length > 1 ? "s" : ""}</span></div>
    <div class="tiles">${fams[fam].map(id => `<div class="tile t-${key(OUT[id])} ${f && !id.toLowerCase().includes(f) ? "dim" : ""}" title="${esc(id)}: ${STATUS_LABEL[key(OUT[id])]}" data-pick="${esc(id)}"></div>`).join("")}</div></div>`).join("");
  return `<div class="head"><h2>Suite overview</h2><button data-act="next" ${yourQueue().length ? "" : "disabled"}>Next needing me →</button></div>
    <div class="legend small muted">${GROUP_ORDER.map(s => `<span><i class="sw t-${s}"></i>${STATUS_LABEL[s]}: ${count(s)}</span>`).join("")}</div>
    <div>${rows || `<p class="muted">No judged outputs yet.</p>`}</div>
    <p class="muted small">One tile per judged output, grouped by the family of the first function its case covers. Click a tile to open it; the sidebar search dims the rest.</p>`;
}

// ---- inventory ----
function coveredBy(id) { return Object.values(CASES).filter(c => arr(c.covers).includes(id)); }

function inventoryView() {
  const inv = DATA.inventory || {}, entries = arr(inv.entries), groups = arr(inv.groups);
  const f = ui.filter.toLowerCase();
  const err = DATA.inventory_error ? `<div class="error">${esc(DATA.inventory_error)}</div>` : "";
  const cov = entries.map(e => coveredBy(e.id).length);
  const nCovered = cov.filter(n => n > 0).length, nDeferred = entries.filter((e, i) => !cov[i] && e.deferred).length;
  const unknown = Object.values(CASES).filter(c => arr(c.unknown).length);
  const uncited = Object.values(CASES).filter(c => !arr(c.covers).length);
  const cell = e => {
    const by = coveredBy(e.id);
    const chips = by.map(c => `<span class="chip" data-case="${esc(c.name)}">${esc(c.name)}</span>`).join("");
    if (by.length) return chips + (e.deferred ? `<div class="small tag-warn">Also marked deferred: ${esc(e.deferred)}</div>` : "");
    return e.deferred ? `<span class="tag-warn">Deferred:</span> ${esc(e.deferred)}` : `<span class="tag-bad">Not covered</span>`;
  };
  const table = g => {
    const rows = entries.filter(e => e.group === g.name && (!f || (e.id + e.principle).toLowerCase().includes(f)));
    if (!rows.length) return "";
    return `<div class="card"><h3 style="margin-top:0">${esc(g.name)} ${g.shared ? `<span class="pill s-agent">shared</span>` : ""}</h3>
      ${g.purpose ? `<p class="muted" style="margin:0 0 8px">${esc(g.purpose)}</p>` : ""}
      ${g.shared && arr(g.functions).length ? `<p class="small muted" style="margin:0 0 8px">Applies to: ${arr(g.functions).map(esc).join(", ")}</p>` : ""}
      <table><tr><th style="width:24%">ID</th><th>Principle</th><th style="width:26%">Covered by</th></tr>
      ${rows.map(e => `<tr><td class="mono">${esc(e.id)}<div class="small muted">${esc(e.kind)}</div></td>
        <td>${esc(e.principle)}${e.source ? `<div class="small muted">Source: ${esc(e.source)}</div>` : ""}
          ${arr(e.options).length ? `<div class="small muted">Ways to test it:</div><ul class="small">${arr(e.options).map(x => `<li>${esc(x)}</li>`).join("")}</ul>` : ""}</td>
        <td>${cell(e)}</td></tr>`).join("")}</table></div>`;
  };
  return `<div class="head"><h2>Behaviour inventory</h2><span class="muted small mono">${esc(DATA.meta.inventory_file)}</span></div>
    ${err}
    <div class="stats"><div class="stat"><b>${entries.length}</b><span class="muted small">entries</span></div>
      <div class="stat"><b class="tag-ok">${nCovered}</b><span class="muted small">covered by a case</span></div>
      <div class="stat"><b class="tag-warn">${nDeferred}</b><span class="muted small">deferred</span></div>
      <div class="stat"><b class="tag-bad">${entries.length - nCovered - nDeferred}</b><span class="muted small">not covered</span></div></div>
    ${unknown.map(c => `<div class="error">Case <b>${esc(c.name)}</b> cites ${arr(c.unknown).map(esc).join(", ")}, which the inventory doesn't have.</div>`).join("")}
    ${uncited.length ? `<p class="small muted">Cases that cite no entry: ${uncited.map(c => `<span class="chip" data-case="${esc(c.name)}">${esc(c.name)}</span>`).join("")}</p>` : ""}
    ${groups.filter(g => !g.shared).map(table).join("")}${groups.filter(g => g.shared).map(table).join("")}`;
}

// ---- suite health ----
function latestStatus() {
  const t = DATA.health?.tests, m = DATA.health?.mutation;
  const line = (label, r, summary) => r
    ? `<tr><td>${label}</td><td>${summary}</td><td class="mono">${esc(r.when)}</td><td class="mono">${esc(r.commit || "not recorded")}</td></tr>`
    : `<tr><td>${label}</td><td class="tag-warn">No run recorded yet</td><td></td><td></td></tr>`;
  return `<table><tr><th>Run</th><th>Result</th><th>When</th><th>Commit</th></tr>
    ${line("Unit tests (<code>test.R</code>)", t, t && `<span class="${t.failed ? "tag-bad" : "tag-ok"}">${t.tests - t.failed} of ${t.tests} pass</span>`)}
    ${line("Mutation check (<code>mutate.R</code>)", m, m && `<span class="${m.caught < arr(m.breaks).length ? "tag-bad" : "tag-ok"}">${m.caught} of ${arr(m.breaks).length} breaks caught</span>`)}</table>`;
}

function healthView() {
  const t = DATA.health?.tests, m = DATA.health?.mutation;
  const tests = t ? `<table><tr><th>File</th><th>Test</th><th>Expectations</th><th>Result</th></tr>
      ${arr(t.results).map(r => `<tr><td class="mono">${esc(r.file)}</td><td>${esc(r.test)}</td><td>${r.expectations}</td>
        <td class="${r.passed ? "tag-ok" : "tag-bad"}">${r.passed ? (r.skipped ? "skipped" : "pass") : "FAIL"}</td></tr>`).join("")}</table>`
    : `<p class="muted">Run <code>Rscript tests/suite/test.R</code> to record one.</p>`;
  const muts = m ? `<table><tr><th>Break</th><th>File</th><th>Caught by</th></tr>
      ${arr(m.breaks).map(b => `<tr><td>${esc(b.name)}</td><td class="mono">${esc(b.file)}</td>
        <td>${b.caught ? arr(b.caught_by).slice(0, 3).map(x => `<div class="small">${esc(x)}</div>`).join("") : `<span class="tag-bad">NOT CAUGHT</span>`}</td></tr>`).join("")}</table>`
    : `<p class="muted">Run <code>Rscript tests/suite/mutate.R</code> to record one.</p>`;
  return `<div class="head"><h2>Suite health</h2></div>
    <p class="muted">The suite's own tests, so you can trust the backend without reading them. The mutation check breaks the suite on purpose, one rule at a time, and the unit tests must catch every break.</p>
    ${latestStatus()}
    <h3>Mutation check</h3>${m ? `<p class="small muted">Every break below was applied to a copy of the suite; the unbroken copy passed ${m.tests} tests first.</p>` : ""}${muts}
    <h3>Unit tests</h3>${t ? `<p class="small muted">${t.tests} tests in ${t.seconds} s${t.skipped ? `, ${t.skipped} skipped` : ""}.</p>` : ""}${tests}`;
}

// ---- guide ----
function guideView(name) {
  const html = GUIDE[name];
  if (!html) { loadGuide().then(() => render()); return `<p class="muted">Loading…</p>`; }
  return `<div class="guide">${html.replace("<div data-latest-status></div>", latestStatus())}</div>`;
}

// ---- render + events ----
function render() {
  const app = document.getElementById("app");
  const focusFind = document.activeElement?.id === "find";
  const body = ui.view === "overview" ? overview() : ui.view === "inventory" ? inventoryView() : ui.view === "health" ? healthView()
    : ui.view === "principles" || ui.view === "structure" ? guideView(ui.view) : caseView();
  const scroll = document.querySelector("main")?.scrollTop || 0;
  app.innerHTML = `<div class="shell ${ui.collapsed ? "collapsed" : ""}">${sidebar()}<main>${body}</main></div>`;
  app.querySelector("main").scrollTop = scroll;

  const find = app.querySelector("#find");
  if (find) {
    find.addEventListener("input", e => { ui.filter = e.target.value; render(); });
    find.addEventListener("keydown", e => {
      if (e.key === "Enter") { const m = ids().find(id => id.toLowerCase().includes(ui.filter.toLowerCase())); if (m) go("case", m); }
      if (e.key === "Escape") { ui.filter = ""; find.blur(); render(); }
    });
    if (focusFind) { find.focus(); find.setSelectionRange(find.value.length, find.value.length); }
  }
  const note = app.querySelector("#note");
  if (note) {
    note.addEventListener("input", e => ui.draft = e.target.value);
    note.addEventListener("keydown", e => {
      if (e.key === "Enter" && (e.ctrlKey || e.metaKey)) { e.preventDefault(); action("confirm-reject"); }
      if (e.key === "Escape") action("cancel-reject");
    });
    if (!focusFind) { note.focus(); note.setSelectionRange(note.value.length, note.value.length); }
  }
  app.querySelectorAll("[data-chip]").forEach(b => b.addEventListener("click", () => {
    ui.draft = (ui.draft ? ui.draft.replace(/\s*$/, "") + " " : "") + b.dataset.chip + ". "; render();
  }));
  app.querySelectorAll("[data-group]").forEach(h => h.addEventListener("click", () => { ui.open[h.dataset.group] = !ui.open[h.dataset.group]; render(); }));
  app.querySelectorAll("[data-pick]").forEach(d => d.addEventListener("click", () => go("case", d.dataset.pick)));
  app.querySelectorAll("[data-case]").forEach(d => d.addEventListener("click", () => { const id = firstOutputOf(d.dataset.case); if (id) go("case", id); }));
  app.querySelectorAll("[data-go]").forEach(d => d.addEventListener("click", e => { e.preventDefault(); go(d.dataset.go); }));
  app.querySelectorAll("[data-compare]").forEach(b => b.addEventListener("click", () => { ui.compare = b.dataset.compare; render(); }));
  app.querySelectorAll("[data-act]").forEach(b => b.addEventListener("click", () => action(b.dataset.act)));
  app.querySelectorAll("details[data-form]").forEach(d => d.addEventListener("toggle", () => {
    if (d.open && !forms[ui.sel]) { const id = ui.sel; loadForm(id).then(() => { if (ui.sel === id) { render(); app.querySelector("details[data-form]")?.setAttribute("open", ""); } }); }
  }));
  app.querySelectorAll("[data-swipe]").forEach(el => el.addEventListener("mousemove", e => {
    const r = el.getBoundingClientRect(), p = Math.max(0, Math.min(100, (e.clientX - r.left) / r.width * 100));
    el.querySelector(".newer").style.clipPath = `inset(0 0 0 ${p}%)`; el.querySelector(".bar").style.left = p + "%";
  }));
}

async function decide(decision, note) {
  const o = OUT[ui.sel];
  if (!o || ui.busy) return;
  if (decision === "reject" && !note.trim()) { ui.error = "A rejection needs a note for the agent."; render(); return; }
  ui.busy = true; ui.error = null; render();
  try {
    const r = await fetch("/api/decide", { method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id: o.id, decision, note, fingerprint: o.fingerprint }) });
    const j = await r.json();
    if (!r.ok) { ui.error = j.error || "The server refused the decision."; return; }
    ui.done++; ui.rejecting = false; ui.draft = "";
    delete forms[o.id];
    await load();
    const next = yourQueue()[0];
    if (next) ui.sel = next;
    syncUrl();
  } catch (e) {
    ui.error = "Couldn't reach the review server: " + e.message;
  } finally {
    ui.busy = false; render();
  }
}

function action(a) {
  const mine = ui.view === "case" && OUT[ui.sel] && key(OUT[ui.sel]) === "you";
  if (a === "toggle") { ui.collapsed = !ui.collapsed; render(); }
  if (a === "case") go("case", ui.sel || yourQueue()[0] || null);
  if (a === "next") { const n = yourQueue()[0]; if (n) go("case", n); }
  if (a === "approve" && mine) decide("approve", "");
  if (a === "reject" && mine) { ui.rejecting = true; render(); }
  if (a === "confirm-reject" && mine) decide("reject", ui.draft);
  if (a === "cancel-reject") { ui.rejecting = false; ui.error = null; render(); }
}

document.addEventListener("keydown", e => {
  if (!DATA || e.ctrlKey || e.metaKey || e.altKey) return;
  if (e.target.matches("input, textarea, [contenteditable]")) return;
  const q = yourQueue(), i = q.indexOf(ui.sel);
  if (e.key === "j" && q.length) go("case", q[i < 0 ? 0 : Math.min(q.length - 1, i + 1)]);
  else if (e.key === "k" && q.length) go("case", q[i < 0 ? 0 : Math.max(0, i - 1)]);
  else if (e.key === "a") action("approve");
  else if (e.key === "r") { e.preventDefault(); action("reject"); }
  else if (e.key === "s" && ui.view === "case") { ui.compare = ui.compare === "swipe" ? "pair" : "swipe"; render(); }
  else if (e.key === "o") go(ui.view === "overview" ? "case" : "overview");
  else if (e.key === "[") action("toggle");
  else if (e.key === "Escape" && ui.rejecting) action("cancel-reject");
});

(async () => {
  try {
    await Promise.all([load(), loadGuide()]);
    readUrl(); syncUrl(); render();
  } catch (e) {
    document.getElementById("app").innerHTML = `<p class="loading">Couldn't load the review state: ${esc(e.message)}. Is the review server running?</p>`;
  }
})();
