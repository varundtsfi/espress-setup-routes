const configuration = {
  extends: ["@commitlint/config-conventional"],
  parserPreset: {
    parserOpts: {
      // issuePrefixes: [ 'PC-' ],
      noteKeywords: ["JIRA-ID", "TASK-ID"],
    },
  },
  plugins: [
    {
      rules: {
        "task-id-rule": (parsed, _when, taskPrefixes = ["PC", "ID"]) => {
          const { footer, notes } = parsed;
          let status = true;
          let message = "Validation successful";
          if (_when === "never") {
            if (footer.includes("JIRA-ID") || footer.includes("TASK-ID")) {
              return [status, message];
            }
          }
          const idPattern = taskPrefixes
            .map((id) => `${id}-\\d+(/${id}-\\d+)?`)
            .join("|");
          const TASK_ID_PATTERN = new RegExp(`^(${idPattern})$`);

          if (notes.length == 0) {
            status = false;
            message = "TASK-ID NOT FOUND";
          } else if (notes.length > 1) {
            status = false;
            message = `footer shoud have only 1 instance of  TASK-ID field found ${notes.length}\n${footer} `;
          } else if (!TASK_ID_PATTERN.test(notes[0].text.trim())) {
            message = `TASK ID have to match the pattern ${TASK_ID_PATTERN}`;
            status = false;
          }

          return [status, message];
        },
      },
    },
  ],
  ignores: [
    (commitMsg) => {
      const excludedCommitMsg = new RegExp(
        "Merge pull request|Merge|pull|Merge branch|Merge branch.*development",
        "i",
      );
      return excludedCommitMsg.test(commitMsg);
    },
  ],
  rules: {
    "body-leading-blank": [2, "always"],
    "footer-max-line-length": [2, "always", 150],
    "body-max-line-length": [2, "always", 150],
    "footer-leading-blank": [1, "always"],
    "header-max-length": [0, "always", 200],
    "type-enum": [
      2,
      "always",
      [
        "build",
        "chore",
        "ci",
        "docs",
        "feat",
        "fix",
        "perf",
        "refactor",
        "revert",
        "style",
        "test",
        "enhance",
      ],
    ],
    "task-id-rule": [2, "always"],
    "body-empty": [2, "never"],
  },
};

module.exports = configuration;
