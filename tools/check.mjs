// Compiles src/main.opy and fails if workshop/genjiball.txt is out of date,
// or if a feel-locked core rule changed (see tools/feel-lock.mjs).
// CI runs this on every push and pull request.
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { compareSnapshot, compileSource, lockedRules, readSnapshot } from "./feel-lock.mjs";

const root = resolve(import.meta.dirname, "..");
const outPath = resolve(root, "workshop/genjiball.txt");

const result = await compileSource();
const committed = (await readFile(outPath, "utf8")).replace(/\r\n/g, "\n");
let failed = false;

if (result !== committed) {
  console.error("workshop/genjiball.txt is out of date. Run `npm run build` and commit the result.");
  failed = true;
}

const problems = compareSnapshot(await readSnapshot(), await lockedRules(result));
if (problems.length > 0) {
  console.error("Feel-lock: core ball rules differ from tools/feel-lock.json:");
  for (const problem of problems) console.error(`  - ${problem}`);
  console.error(
    "If this is a deliberate ball feel change, run `npm run feel-lock:update`, commit tools/feel-lock.json," +
      " and add the `ball feel` label to the PR. See docs/development.md.",
  );
  failed = true;
}

if (failed) process.exit(1);
console.log("OK: src/ compiles and matches workshop/genjiball.txt");
console.log("OK: feel-locked core rules match tools/feel-lock.json");
