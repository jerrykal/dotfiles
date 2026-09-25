import { readFileSync } from "node:fs";
import { deflateSync } from "node:zlib";

// sysexits codes; EX_DATAERR is reserved for a diagram that doesn't parse, so
// callers can tell "fix the diagram" apart from every other failure.
const EX_USAGE = 64;
const EX_DATAERR = 65;
const EX_NOINPUT = 66;

const usage = "usage: mermaid-link [--edit] [file]  (reads stdin without a file)";
const fail = (code, msg) => {
  console.error(msg);
  process.exit(code);
};

let mode = "view";
let file;
let options = true;
for (const arg of process.argv.slice(2)) {
  if (options && arg === "--") options = false;
  else if (options && (arg === "-e" || arg === "--edit")) mode = "edit";
  else if (options && (arg === "-h" || arg === "--help")) {
    console.log(usage);
    process.exit(0);
  } else if (options && arg.startsWith("-") && arg !== "-") fail(EX_USAGE, usage);
  else if (file !== undefined) fail(EX_USAGE, usage);
  else file = arg;
}

const fromStdin = file === undefined || file === "-";
if (fromStdin && process.stdin.isTTY) fail(EX_USAGE, usage);

let code;
try {
  code = readFileSync(fromStdin ? 0 : file, "utf8").trim();
} catch (e) {
  fail(EX_NOINPUT, `mermaid-link: ${e.message}`);
}
if (!code) fail(EX_NOINPUT, "mermaid-link: empty diagram");

// Some diagram types (class, state, ...) sanitize labels with DOMPurify, which
// needs a DOM even when only parsing.
const { JSDOM } = await import("jsdom");
const { window } = new JSDOM("");
globalThis.window = window;
globalThis.document = window.document;
const { default: mermaid } = await import("mermaid");

try {
  await mermaid.parse(code);
} catch (e) {
  // mermaid.live also bundles diagram types that plain mermaid lacks (zenuml),
  // so an unrecognised type still gets a link.
  if (e?.name === "UnknownDiagramError") {
    console.error("mermaid-link: diagram type not recognised locally; syntax unchecked");
  } else {
    fail(EX_DATAERR, `mermaid-link: ${e?.message ?? e}`);
  }
}

// mermaid.live's `pako:` state: zlib-deflated JSON, base64url. It lives in the
// URL fragment, which browsers never send to the server.
const state = {
  code,
  mermaid: JSON.stringify({ theme: "default" }, null, 2),
  autoSync: true,
  updateDiagram: true,
};
const pako = deflateSync(JSON.stringify(state), { level: 9 }).toString("base64url");
console.log(`https://mermaid.live/${mode}#pako:${pako}`);
