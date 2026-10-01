// Compiles src/main.opy and fails if workshop/genjiball.txt is out of date,
// if a feel-locked core rule changed (see tools/feel-lock.mjs), or if the mode
// is close to a Workshop resource limit (see tools/budget.mjs), or if the settings
// tables in docs/hosting.md don't match the source (see tools/docs-settings.mjs).
// CI runs this on every push and pull request.
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { checkBudget } from "./budget.mjs";
import { generate as generateSettingsDocs } from "./docs-settings.mjs";
import { compareSnapshot, compile, lockedRules, readSnapshot } from "./feel-lock.mjs";

const root = resolve(import.meta.dirname, "..");
const outPath = resolve(root, "workshop/genjiball.txt");

const compiled = await compile();
const { result } = compiled;
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

const budget = checkBudget(compiled);
console.log("Resource budget (used / limit):");
for (const line of budget.lines) console.log(line);
if (budget.tooClose.length > 0) {
  console.error(
    `Resource budget: ${budget.tooClose.join(", ")} too close to the Workshop limit.` +
      " Free some up (reuse or merge variables, drop dead code) before adding more. See docs/architecture.md.",
  );
  failed = true;
}

const settingsDocs = await generateSettingsDocs();
if (settingsDocs.generated !== settingsDocs.docs || settingsDocs.problems.length > 0) {
  console.error("Settings docs: the tables in docs/hosting.md don't match the createWorkshopSetting* calls in src/.");
  for (const problem of settingsDocs.problems) console.error(`  - ${problem}`);
  console.error("Run `npm run docs:settings` and commit docs/hosting.md. See docs/development.md.");
  failed = true;
}

if (failed) process.exit(1);
console.log("OK: src/ compiles and matches workshop/genjiball.txt");
console.log("OK: feel-locked core rules match tools/feel-lock.json");
console.log("OK: every resource is within budget");
console.log("OK: the settings tables in docs/hosting.md match src/");
