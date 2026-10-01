// Resource budget: how much of each Workshop limit the compiled mode uses.
// `npm run check` prints the report and fails when anything gets within its
// margin of the limit, so we notice before the Workshop refuses the code.

// Workshop limits, and how close to each one counts as "too close".
const BUDGET = [
  { name: "Global variables", limit: 128, margin: 5, used: (c) => c.globalVariables.length },
  { name: "Player variables", limit: 128, margin: 5, used: (c) => c.playerVariables.length },
  { name: "Subroutines", limit: 128, margin: 5, used: (c) => c.subroutines.length },
  { name: "Elements", limit: 32768, margin: 1000, used: (c) => c.nbElements },
];

// Returns the report lines and the names of resources within their margin.
export function checkBudget(compiled) {
  const lines = [];
  const tooClose = [];
  for (const { name, limit, margin, used } of BUDGET) {
    const count = used(compiled);
    const left = limit - count;
    const warn = left <= margin;
    if (warn) tooClose.push(name);
    lines.push(
      `  ${name.padEnd(18)} ${String(count).padStart(6)} / ${String(limit).padEnd(6)} ${String(left).padStart(6)} left${warn ? `  <- within ${margin} of the limit` : ""}`,
    );
  }
  // Every remaining extension is used, and OverPy refuses to compile when they cost too many points, so this is info only.
  lines.push(`  ${"Extension points".padEnd(18)} ${String(compiled.spentExtensionPoints).padStart(6)} / ${compiled.availableExtensionPoints}`);
  return { lines, tooClose };
}
