import { defineConfig, globalIgnores } from "eslint/config";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
    allConfig: js.configs.all
});

export default defineConfig([globalIgnores([
    "**/lwc/**/*.css",
    "**/lwc/**/*.html",
    "**/lwc/**/*.json",
    "**/lwc/**/*.svg",
    "**/lwc/**/*.xml",
    "**/aura/**/*.auradoc",
    "**/aura/**/*.cmp",
    "**/aura/**/*.css",
    "**/aura/**/*.design",
    "**/aura/**/*.evt",
    "**/aura/**/*.json",
    "**/aura/**/*.svg",
    "**/aura/**/*.tokens",
    "**/aura/**/*.xml",
    "**/aura/**/*.app",
    "**/.sfdx",
]), {
    extends: compat.extends("@salesforce/eslint-config-lwc/recommended"),

    rules: {
        "@lwc/lwc/no-api-reassignments": "off",
    },
}]);