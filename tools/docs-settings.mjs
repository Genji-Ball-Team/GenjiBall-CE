// Settings docs: regenerates the Workshop settings tables in docs/hosting.md
// from the createWorkshopSetting* calls in src/. `npm run check` fails when the
// tables are out of date.
//
// Usage: npm run docs:settings   (rewrites docs/hosting.md)
//
// Each table follows a `<!-- settings: <category> -->` marker. The Setting,
// Default and Range columns come from the source, in in-game sort order. The
// "What it does" column and any unit after a range (" s", " m", "°") are
// hand-written: they're kept from the existing row with the same setting name.
import { readdir, readFile, writeFile } from "node:fs/promises";
import { join, relative, resolve } from "node:path";
import { pathToFileURL } from "node:url";

const root = resolve(import.meta.dirname, "..");
export const docsPath = resolve(root, "docs/hosting.md");

const MARKER = /^<!-- settings: (.+) -->$/;
const HEADER = "| Setting | Default | Range | What it does |";
const CALL = /createWorkshopSetting(Int|Float|Bool|Enum)\(/g;

async function opyFiles(dir) {
  const files = [];
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) files.push(...(await opyFiles(path)));
    else if (entry.name.endsWith(".opy")) files.push(path);
  }
  return files.sort();
}

// The text between a call's opening paren and its matching closing paren.
function callArgs(source, start) {
  let depth = 1;
  let inString = false;
  for (let i = start; i < source.length; i++) {
    const c = source[i];
    if (inString) {
      if (c === "\\") i++;
      else if (c === '"') inString = false;
    } else if (c === '"') inString = true;
    else if (c === "(" || c === "[") depth++;
    else if ((c === ")" || c === "]") && --depth === 0) return source.slice(start, i);
  }
  throw new Error("unterminated createWorkshopSetting call");
}

// Blanks out /* */ comments and whole-line # comments, keeping offsets and
// newlines, so commented-out calls don't count. Skips over strings.
function stripComments(source) {
  source = source.replace(/^\s*#.*$/gm, (line) => " ".repeat(line.length));
  let out = "";
  let inString = false;
  for (let i = 0; i < source.length; i++) {
    const c = source[i];
    if (inString) {
      if (c === "\\") out += c + (source[++i] ?? "");
      else {
        if (c === '"') inString = false;
        out += c;
      }
    } else if (c === '"') {
      inString = true;
      out += c;
    } else if (c === "/" && source[i + 1] === "*") {
      const close = source.indexOf("*/", i + 2);
      const end = close < 0 ? source.length : close + 2;
      out += source.slice(i, end).replace(/[^\n]/g, " ");
      i = end - 1;
    } else out += c;
  }
  return out;
}

// Every createWorkshopSetting* call in src/, as {category, name, type, default, min, max, options, sort}.
export async function readSettings() {
  const settings = [];
  for (const file of await opyFiles(resolve(root, "src"))) {
    const source = stripComments(await readFile(file, "utf8"));
    for (const match of source.matchAll(CALL)) {
      const type = match[1];
      const where = `${relative(root, file)}: createWorkshopSetting${type}`;
      const text = callArgs(source, match.index + match[0].length);
      let args;
      try {
        // Literal OverPy arguments (strings, numbers, booleans, arrays) are valid JSON.
        args = JSON.parse(`[${text}]`);
      } catch {
        throw new Error(`${where}(${text}): arguments must be literals`);
      }
      const [category, name, value] = args;
      const setting = { category, name, type, default: value, sort: 0 };
      if (type === "Int" || type === "Float") [, , , setting.min, setting.max, setting.sort = 0] = args;
      else if (type === "Bool") [, , , setting.sort = 0] = args;
      else [, , , setting.options, setting.sort = 0] = args;
      settings.push(setting);
    }
  }
  const seen = new Set();
  for (const { category, name } of settings) {
    const key = `${category} > ${name}`;
    if (seen.has(key)) throw new Error(`Setting "${key}" is created twice. Read each setting once.`);
    seen.add(key);
  }
  return settings;
}

// An enum option as shown in the docs: the first line, without the "~..." subtitle.
const optionName = (option) => option.split("\n")[0];

function defaultCell(setting) {
  if (setting.type === "Bool") return setting.default ? "on" : "off";
  if (setting.type === "Enum") return optionName(setting.options[setting.default]);
  return String(setting.default);
}

function rangeCell(setting, unit) {
  if (setting.type === "Bool") return "";
  if (setting.type === "Enum") return setting.options.map(optionName).join(" / ");
  return `${setting.min}–${setting.max}${unit}`;
}

// A table row; an empty cell is written as "| |", like the hand-written tables.
const row = (cells) => `|${cells.map((cell) => (cell === "" ? " " : ` ${cell} `)).join("|")}|`;
const splitRow = (line) => line.trim().replace(/^\||\|$/g, "").split(/(?<!\\)\|/).map((cell) => cell.trim());

// Hand-written parts of an existing table, by setting name: description and range unit.
function readTable(lines) {
  const [header, , ...rows] = lines.map(splitRow);
  const column = (name) => header.indexOf(name);
  const kept = new Map();
  for (const cells of rows) {
    const range = column("Range") >= 0 ? cells[column("Range")] : "";
    const unit = range.match(/^-?[\d.]+–-?[\d.]+(.*)$/)?.[1] ?? "";
    kept.set(cells[column("Setting")], { unit, description: cells[column("What it does")] ?? "" });
  }
  return kept;
}

// Returns docs/hosting.md with every marked table regenerated, any problems that
// need a human (a category without a table, a setting without a description),
// and the rows dropped because src/ no longer has that setting (e.g. a rename).
export async function generate() {
  const settings = await readSettings();
  const docs = (await readFile(docsPath, "utf8")).replace(/\r\n/g, "\n");
  const lines = docs.split("\n");
  const out = [];
  const problems = [];
  const dropped = [];
  const documented = new Set();
  for (let i = 0; i < lines.length; i++) {
    out.push(lines[i]);
    const category = lines[i].match(MARKER)?.[1];
    if (category === undefined) continue;
    documented.add(category);
    let end = i + 1;
    while (end < lines.length && lines[end].startsWith("|")) end++;
    const kept = readTable(lines.slice(i + 1, end));
    const rows = settings
      .filter((setting) => setting.category === category)
      .map((setting, order) => ({ setting, order }))
      .sort((a, b) => a.setting.sort - b.setting.sort || a.order - b.order)
      .map(({ setting }) => {
        const { unit = "", description = "" } = kept.get(setting.name) ?? {};
        kept.delete(setting.name);
        if (description === "") problems.push(`"${category} > ${setting.name}" has no description`);
        return row([setting.name, defaultCell(setting), rangeCell(setting, unit), description]);
      });
    for (const name of kept.keys()) dropped.push(`${category} > ${name}`);
    if (rows.length === 0) problems.push(`docs/hosting.md has a table for "${category}", but src/ has no such category`);
    out.push(HEADER, "|---|---|---|---|", ...rows);
    i = end - 1;
  }
  for (const category of new Set(settings.map((setting) => setting.category))) {
    if (!documented.has(category)) problems.push(`"${category}" has no \`<!-- settings: ${category} -->\` table in docs/hosting.md`);
  }
  return { docs, generated: out.join("\n"), problems, dropped };
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const { docs, generated, problems, dropped } = await generate();
  if (generated !== docs) {
    await writeFile(docsPath, generated);
    console.log("Updated the settings tables in docs/hosting.md");
  } else {
    console.log("docs/hosting.md is already up to date");
  }
  for (const name of dropped) {
    console.log(`  Removed "${name}": src/ has no such setting. If it was renamed, copy its description over.`);
  }
  for (const problem of problems) console.error(`  - ${problem}`);
  if (problems.length > 0) {
    console.error("Write the missing descriptions in docs/hosting.md, then run `npm run docs:settings` again.");
    process.exit(1);
  }
}
