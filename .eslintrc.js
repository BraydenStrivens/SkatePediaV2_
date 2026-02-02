module.exports = {
  root: true,
  env: {
    es2021: true,
    node: true,
  },
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaVersion: 2021,
    sourceType: "module",
  },
  plugins: ["@typescript-eslint", "import"],
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:import/recommended",
    "plugin:import/typescript",
    "prettier",
  ],
  ignorePatterns: [
    "functions/lib/**",
    "functions/node_modules/***",
    "node_modules/**",
  ],
  overrides: [
    {
      files: ["functions/src/**/*.ts"],
      parser: "@typescript-eslint/parser",
      parserOptions: {
        project: `./functions/tsconfig.json`,
        sourceType: "module",
      },
      rules: {
        "@typescript-eslint/explicit-function-return-type": "off",
        "@typescript-eslint/no-unused-vars": [
          "warn",
          { argsIgnorePattern: "^_", varsIgnorePattern: "^_" },
        ],
        "@typescript-eslint/no-explicit-any": "off",
        "@typescript-eslint/no-non-null-assertion": "off",
        "@typescript-eslint/fnction-return-type": "off",
        "@typescript-eslint/consistent-type-imports": "warn",
        "@typescript-eslint/no-floating-promises": "warn",
      },
    },
    {
      files: ["*.js"],
      parserOptions: {
        project: null,
      },
      rules: {},
    },
  ],
  rules: {
    "no-console": "off",
    "no-debugger": "warn",
    "prefer-const": "warn",
    "no-var": "error",
    "prefer-template": "warn",
    "no-shadow": "warn",
    eqeqeq: "error",

    "no-duplicate-imports": "warn",
    "import/order": [
      "warn",
      {
        groups: [
          "builtin",
          "external",
          "internal",
          ["parent", "sibling", "index"],
        ],
        "newlines-between": "always",
        alphabetize: { order: "asc", caseInsensitive: true },
      },
    ],
    "import/no-unresolved": "off",
    "import/no-extraneous-dependencies": "warn",

    "object-curly-spacing": ["warn", "always"],
    "array-bracket-spacing": ["warn", "never"],
    "computed-property-spacing": ["warn", "never"],
  },
};
