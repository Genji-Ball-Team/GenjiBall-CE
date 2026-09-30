// Compiles src/main.opy and fails if workshop/genjiball.txt is out of date.
// CI runs this on every push and pull request.
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import overpy from "overpy";

const root = resolve(import.meta.dirname, "..");
const outPath = resolve(root, "workshop/genjiball.txt");

await overpy.readyPromise;
const source = await readFile(resolve(root, "src/main.opy"), "utf8");
const { result } = await overpy.compile(source, "en-US", resolve(root, "src"), "main.opy");
const committed = (await readFile(outPath, "utf8")).replace(/\r\n/g, "\n");

if (result.replace(/\r\n/g, "\n") !== committed) {
  console.error("workshop/genjiball.txt is out of date. Run `npm run build` and commit the result.");
  process.exit(1);
}
console.log("OK: src/ compiles and matches workshop/genjiball.txt");
