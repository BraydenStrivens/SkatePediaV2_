const fs = require("fs");
const path = require("path");

const inputFilePath = path.join(
  __dirname,
  "../functions/src/data/trickList.json"
);
const outputFilePath = path.join(
  __dirname,
  "../functions/src/data/trickList_lower.json"
);

const rawData = fs.readFileSync(inputFilePath, "utf-8");
const tricks = JSON.parse(rawData);

if (!Array.isArray(tricks)) {
  console.log("TRICK LIST NOT AN ARRAY");
}

const updateTricks = tricks.map((trick) => {
  if (typeof trick.stance === "string") {
    let newDiff = trick.difficulty.toLowerCase();
    if (newDiff === "easy") newDiff = "beginner";

    return {
      ...trick,
      stance: trick.stance.toLowerCase(),
      difficulty: newDiff,
    };
  }

  return trick;
});

fs.writeFileSync(
  outputFilePath,
  JSON.stringify(updateTricks, null, 2),
  "utf-8"
);

console.log("UPDATED STANCE VALUES TO LOWERCASE");

// export {};
