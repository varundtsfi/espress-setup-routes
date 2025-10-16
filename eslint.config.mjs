import js from "@eslint/js";
import globals from "globals";

export default [
  js.configs.recommended,
  {
    // CommonJS files (.js, .cjs)
    files: ["**/*.js", "**/*.cjs"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "commonjs",
      globals: {
        ...globals.node,
      },
    },
  },
  {
    // ES Module files (.mjs)
    files: ["**/*.mjs"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: {
        ...globals.node,
      },
    },
  },
  {
    ignores: ["node_modules/**"],
  },
];
