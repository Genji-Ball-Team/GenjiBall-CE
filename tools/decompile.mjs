// Decompiles Workshop code (copied from the in-game editor) into a single OverPy file.
// Usage: npm run decompile -- <input.txt> <output.opy>
//
// Use this to bring changes made in-game back into src/. The output is one big file;
// copy the rules you changed into the matching file under src/ (see src/main.opy).
import { readFile, writeFile } from "node:fs/promises";
import overpy from "overpy";

const [input, output] = process.argv.slice(2);
if (!input || !output) {
  console.error("Usage: npm run decompile -- <input.txt> <output.opy>");
  process.exit(2);
}

await overpy.readyPromise;
let opy = overpy.decompileAllRules(await readFile(input, "utf8"), "en-US");

// OverPy 9.7.16 decompiles `Start Rule(sub, Restart Rule)` as `startRule(sub)`,
// which its own compiler rejects. Rewrite it to the equivalent async() call.
opy = opy.replace(/^(\s*)startRule\((\w+)\)$/gm, "$1async($2, AsyncBehavior.RESTART)");

await writeFile(output, opy, "utf8");
console.log(`Wrote ${output}`);
