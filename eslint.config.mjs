import js from "@eslint/js";
import { defineConfig } from "eslint";
import ts from "@typescript-eslint/eslint-plugin"; // For TypeScript
import tsParser from "@typescript-eslint/parser"; // TypeScript parser
import json from "@eslint/json";
import markdown from "@eslint/markdown";
import css from "@eslint/css";

export default defineConfig([
  // JS and TypeScript files
  {
    files: ["**/*.{js,mjs,cjs,ts}"],
    languageOptions: {
      parser: tsParser, // Use the TypeScript parser for TypeScript files
    },
    extends: ["js/recommended", "plugin:@typescript-eslint/recommended"], // JS and TS recommended rules
    plugins: { js, ts },
  },
  
  // JS-specific files
  {
    files: ["**/*.js"],
    languageOptions: { sourceType: "script" },
  },
  
  // TypeScript files
  {
    files: ["**/*.ts"],
    extends: ["plugin:@typescript-eslint/recommended"],
    parserOptions: { project: './tsconfig.json' }, // Make sure to reference your tsconfig if needed
  },

  // JSON files
  {
    files: ["**/*.json"],
    plugins: { json },
    extends: ["json/recommended"],
  },
  
  // JSON5 files
  {
    files: ["**/*.json5"],
    plugins: { json },
    extends: ["json/recommended"],
  },
  
  // Markdown files
  {
    files: ["**/*.md"],
    plugins: { markdown },
    extends: ["markdown/recommended"],
  },
  
  // CSS files
  {
    files: ["**/*.css"],
    plugins: { css },
    extends: ["css/recommended"],
  },
]);
