const fs = require("fs");
const path = require("path");

// camelCase -> snake_case
function camelToSnake(key) {
  return key.replace(/[A-Z]/g, (letter) => `_${letter.toLowerCase()}`);
}

function convertKeysToSnake(obj) {
  if (Array.isArray(obj)) {
    return obj.map(convertKeysToSnake);
  } else if (obj && typeof obj === "object") {
    const newObj = {};

    for (const key in obj) {
      if (!obj.hasOwnProperty(key)) continue;
      const value = obj[key];
      newObj[camelToSnake(key)] = convertKeysToSnake(value);
    }
    return newObj;
  } else {
    return obj;
  }
}

const inputFilePath = path.join(
  __dirname,
  "../functions/src/data/trickList.json"
);
const outputFilePath = path.join(
  __dirname,
  "../functions/src/data/trickList_snake.json"
);

const data = JSON.parse(fs.readFileSync(inputFilePath, "utf-8"));

const converted = convertKeysToSnake(data);

fs.writeFileSync(outputFilePath, JSON.stringify(converted, null, 2));

console.log("CONVERTED TRICK LIST TO SNAKE_CASE");

export {};
