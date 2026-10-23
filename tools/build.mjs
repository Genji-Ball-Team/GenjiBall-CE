// Compiles src/main.opy to workshop/genjiball.txt, with the build id filled in (tools/build-id.mjs).
// Prints OverPy's warnings, as `overpy compile` does.
import { writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import { compile } from "./feel-lock.mjs";

const root = resolve(import.meta.dirname, "..");
const { result } = await compile();
await writeFile(resolve(root, "workshop/genjiball.txt"), result);
console.log("Wrote workshop/genjiball.txt");
