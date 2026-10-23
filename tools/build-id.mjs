// Build id: the first 8 hex digits of the SHA-256 of the OverPy source in src/. The game writes it
// at the end of the GBR line (docs/ranked-log.md, "Build id"), so a match can be traced to the code
// that logged it even though every merge into v1.3.3R is re-released as 1.3.3R.
//
// It changes exactly when src/ changes, so nobody bumps it. `npm run build` and `npm run check`
// put it into the compiled code (see compile() in tools/feel-lock.mjs).
//
// Usage: node tools/build-id.mjs            the build id of the working tree
//        node tools/build-id.mjs <id> [ref] the commit (searching back from ref, default HEAD)
//                                           that introduced this build id
import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { readFile, readdir } from "node:fs/promises";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";

const root = resolve(import.meta.dirname, "..");
const ID_LENGTH = 8;
const SEARCH_LIMIT = 500;

// files: [[path under src/, text]]. Order and line endings don't change the id.
export function hashSources(files) {
  const hash = createHash("sha256");
  const sorted = [...files].sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0));
  for (const [path, text] of sorted) hash.update(`${path}\0${text.replace(/\r\n/g, "\n")}\0`);
  return hash.digest("hex").slice(0, ID_LENGTH);
}

async function sourcePaths(dir, prefix = "") {
  const paths = [];
  for (const entry of await readdir(resolve(dir, prefix), { withFileTypes: true })) {
    const path = prefix ? `${prefix}/${entry.name}` : entry.name;
    if (entry.isDirectory()) paths.push(...(await sourcePaths(dir, path)));
    else if (entry.name.endsWith(".opy")) paths.push(path);
  }
  return paths;
}

// The build id of the src/ folder in the working tree.
export async function buildId() {
  const srcDir = resolve(root, "src");
  const files = await Promise.all(
    (await sourcePaths(srcDir)).map(async (path) => [path, await readFile(resolve(srcDir, path), "utf8")]),
  );
  return hashSources(files);
}

const git = (...args) => execFileSync("git", args, { cwd: root, encoding: "utf8", maxBuffer: 1 << 28 });

// The build id of src/ as it was in a commit.
function buildIdAt(commit, blobs) {
  const files = git("ls-tree", "-r", commit, "--", "src")
    .split("\n")
    .filter((line) => line.endsWith(".opy"))
    .map((line) => {
      const [info, path] = line.split("\t");
      const sha = info.split(" ")[2];
      if (!blobs.has(sha)) blobs.set(sha, git("cat-file", "blob", sha));
      return [path.slice("src/".length), blobs.get(sha)];
    });
  return hashSources(files);
}

// The oldest commit (of the first-parent history of ref that touched src/) whose src/ has this build id.
export function findCommit(id, ref = "HEAD") {
  const commits = git("log", "--first-parent", "--format=%H", `-n${SEARCH_LIMIT}`, ref, "--", "src").split("\n").filter(Boolean);
  const blobs = new Map();
  let found = null;
  for (const commit of commits) {
    if (buildIdAt(commit, blobs) === id) found = commit;
    else if (found) break;
  }
  return found;
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const [id, ref] = process.argv.slice(2);
  if (!id) {
    console.log(await buildId());
  } else {
    const commit = findCommit(id, ref);
    if (!commit) {
      console.error(`No commit that touched src/ in the last ${SEARCH_LIMIT} on ${ref ?? "HEAD"} has build id ${id}.`);
      process.exit(1);
    }
    console.log(git("log", "-1", "--format=%H %ad %s", "--date=short", commit).trim());
  }
}
