#!/usr/bin/env node

/**
 * MthBdeIotClient - Release Version Script (Node.js)
 * Automatische Versionsverwaltung mit Git Tags, package.json und .env Updates
 */

const fs = require("fs");
const path = require("path");
const { exec, execSync } = require("child_process");
const readline = require("readline");

// Farben für Console Output
const colors = {
  red: "\x1b[31m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  magenta: "\x1b[35m",
  cyan: "\x1b[36m",
  white: "\x1b[37m",
  reset: "\x1b[0m",
};

// Emojis
const emojis = {
  success: "✅",
  error: "❌",
  info: "ℹ️",
  rocket: "🚀",
  tag: "🏷️",
  gear: "⚙️",
};

// Projektverzeichnisse
const projectRoot = path.resolve(__dirname, "..");
const appDir = path.join(projectRoot, "App");
const packageJsonPath = path.join(appDir, "package.json");
const envFilePath = path.join(appDir, ".env");

// Command line arguments
const args = process.argv.slice(2);
const options = {
  type: null,
  version: null,
  force: false,
  dryRun: false,
};

// Parse command line arguments
for (let i = 0; i < args.length; i++) {
  const arg = args[i];
  switch (arg) {
    case "--type":
      options.type = args[++i];
      break;
    case "--version":
      options.version = args[++i];
      break;
    case "--force":
      options.force = true;
      break;
    case "--dry-run":
      options.dryRun = true;
      break;
    case "--help":
      showHelp();
      process.exit(0);
    default:
      if (arg.match(/^[0-9]+\.[0-9]+\.[0-9]+$/)) {
        options.version = arg;
      } else if (["patch", "minor", "major"].includes(arg)) {
        options.type = arg;
      }
  }
}

function showHelp() {
  console.log(`
${colors.cyan}MthBdeIotClient Version Manager${colors.reset}

Usage:
  node release-version.js [options]
  npm run release [-- options]

Options:
  --type <patch|minor|major>  Increment version type
  --version <x.y.z>          Set specific version
  --force                    Force execution (skip confirmations)
  --dry-run                  Show what would be done without making changes
  --help                     Show this help

NPM Scripts:
  npm run release           Interactive version selection
  npm run release:patch     Increment patch version
  npm run release:minor     Increment minor version
  npm run release:major     Increment major version

Examples:
  node release-version.js --type patch
  node release-version.js --version 1.2.3
  npm run release:minor
`);
}

function coloredOutput(message, color = "white", emoji = "") {
  const output = emoji ? `${emoji} ${message}` : message;
  console.log(colors[color] + output + colors.reset);
}

function execCommand(command, options = {}) {
  try {
    const result = execSync(command, {
      encoding: "utf8",
      stdio: options.silent ? "pipe" : "inherit",
      cwd: options.cwd || process.cwd(),
      ...options,
    });
    return result || "";
  } catch (error) {
    if (!options.silent) {
      throw error;
    }
    return "";
  }
}

function getPackageVersion(packageJsonPath) {
  try {
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));
    return packageJson.version || "0.0.0";
  } catch (error) {
    return "0.0.0";
  }
}

function setPackageVersion(packageJsonPath, version) {
  try {
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));
    packageJson.version = version;
    fs.writeFileSync(
      packageJsonPath,
      JSON.stringify(packageJson, null, 2) + "\n"
    );
    return true;
  } catch (error) {
    coloredOutput(
      `Error updating ${packageJsonPath}: ${error.message}`,
      "red",
      emojis.error
    );
    return false;
  }
}

function incrementVersion(version, type) {
  // Clean version string (remove beta, alpha, etc.)
  const cleanVersion = version.replace(/-(beta|alpha|rc|dev).*$/, "");
  const parts = cleanVersion.split(".").map(Number);

  // Ensure we have 3 parts
  while (parts.length < 3) {
    parts.push(0);
  }

  let [major, minor, patch] = parts;

  // Ensure all parts are valid numbers
  if (isNaN(major)) major = 0;
  if (isNaN(minor)) minor = 0;
  if (isNaN(patch)) patch = 0;

  switch (type) {
    case "major":
      major++;
      minor = 0;
      patch = 0;
      break;
    case "minor":
      minor++;
      patch = 0;
      break;
    case "patch":
      patch++;
      break;
    default:
      throw new Error(`Invalid version type: ${type}`);
  }

  return `${major}.${minor}.${patch}`;
}

function updateEnvFile(envFilePath, version) {
  try {
    let envContent = [];
    let versionLineExists = false;
    let appVersionLineExists = false;

    if (fs.existsSync(envFilePath)) {
      envContent = fs.readFileSync(envFilePath, "utf8").split("\n");

      // Update existing VERSION and APP_VERSION lines
      envContent = envContent.map((line) => {
        if (line.startsWith("VERSION=")) {
          versionLineExists = true;
          return `VERSION=${version}`;
        }
        if (line.startsWith("APP_VERSION=")) {
          appVersionLineExists = true;
          return `APP_VERSION=${version}`;
        }
        return line;
      });
    }

    // Add VERSION line if not exists
    if (!versionLineExists) {
      if (envContent.length === 0) {
        envContent = [
          "# MthBdeIotClient Environment Variables",
          "NODE_ENV=production",
          `VERSION=${version}`,
          `APP_VERSION=${version}`,
          "ELECTRON_BUILDER_ALLOW_UNRESOLVED_DEPENDENCIES=true",
        ];
        appVersionLineExists = true; // Already added above
      } else {
        envContent.push(`VERSION=${version}`);
      }
    }

    // Add APP_VERSION line if not exists
    if (!appVersionLineExists) {
      envContent.push(`APP_VERSION=${version}`);
    }

    // Remove empty lines at the end and add single newline
    while (envContent.length > 0 && envContent[envContent.length - 1] === "") {
      envContent.pop();
    }

    fs.writeFileSync(envFilePath, envContent.join("\n") + "\n");
    return true;
  } catch (error) {
    coloredOutput(
      `Error updating .env file: ${error.message}`,
      "red",
      emojis.error
    );
    return false;
  }
}

async function promptUser(question) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer);
    });
  });
}

async function main() {
  // Header
  coloredOutput("==========================================", "cyan");
  coloredOutput("MthBdeIotClient Version Manager", "cyan", emojis.rocket);
  coloredOutput("==========================================", "cyan");
  console.log("");

  // Check if we're in the right directory
  if (!fs.existsSync(packageJsonPath)) {
    coloredOutput(
      `package.json not found in ${packageJsonPath}`,
      "red",
      emojis.error
    );
    coloredOutput(
      "Please run this script from the project root directory",
      "yellow",
      emojis.info
    );
    process.exit(1);
  }

  // Check Git status
  coloredOutput("Checking Git status...", "blue", emojis.info);
  const gitStatus = execCommand("git status --porcelain", { silent: true });
  if (gitStatus && gitStatus.trim() && !options.force) {
    coloredOutput("Working directory has uncommitted changes:", "yellow");
    execCommand("git status --porcelain");
    console.log("");
    const continueAnswer = await promptUser(
      "Do you want to continue anyway? (y/N): "
    );
    if (!continueAnswer.match(/^[Yy]$/)) {
      coloredOutput("Aborted by user", "red", emojis.error);
      process.exit(1);
    }
  } else {
    coloredOutput("Working directory is clean", "green", emojis.success);
  }

  // Read current version
  coloredOutput("Reading current version...", "blue", emojis.info);
  const currentVersion = getPackageVersion(packageJsonPath);
  coloredOutput(
    `Current version in package.json: ${currentVersion}`,
    "magenta",
    emojis.info
  );

  // Fetch Git tags
  coloredOutput("Fetching Git tags...", "blue", emojis.info);
  execCommand("git fetch --tags --quiet", { silent: true });

  // Find last Git tag
  let lastVersion = "0.0.0";
  try {
    const tagOutput = execCommand('git tag -l --sort=-version:refname "v*"', {
      silent: true,
    });
    if (tagOutput && tagOutput.trim()) {
      const tags = tagOutput
        .split("\n")
        .map((tag) => tag.trim())
        .filter((tag) => tag);

      // Find the latest stable release (no beta/alpha/rc suffix)
      let latestStableTag = null;
      let latestBetaTag = null;

      for (const tag of tags) {
        if (tag.match(/-(beta|alpha|rc|dev)/)) {
          if (!latestBetaTag) latestBetaTag = tag;
        } else {
          if (!latestStableTag) latestStableTag = tag;
        }
      }

      // Prefer stable releases over beta releases
      const selectedTag = latestStableTag || latestBetaTag || tags[0];

      if (selectedTag) {
        let tagVersion = selectedTag.substring(1); // Remove 'v' prefix
        // Clean version (remove beta, alpha, etc.)
        const cleanVersion = tagVersion.replace(/-(beta|alpha|rc|dev).*$/, "");
        if (cleanVersion.match(/^[0-9]+\.[0-9]+\.[0-9]+$/)) {
          lastVersion = cleanVersion;
          if (selectedTag.includes("-")) {
            coloredOutput(
              `Last stable Git tag: ${selectedTag} (using clean version: ${lastVersion})`,
              "magenta",
              emojis.info
            );
          } else {
            coloredOutput(
              `Last Git tag: ${selectedTag} (version: ${lastVersion})`,
              "magenta",
              emojis.info
            );
          }
        } else {
          coloredOutput(
            `Last Git tag: ${selectedTag} (invalid format, using ${lastVersion})`,
            "yellow",
            emojis.info
          );
        }
      } else {
        coloredOutput(
          `No previous Git tags found, starting from ${lastVersion}`,
          "magenta",
          emojis.info
        );
      }
    } else {
      coloredOutput(
        `No previous Git tags found, starting from ${lastVersion}`,
        "magenta",
        emojis.info
      );
    }
  } catch (error) {
    coloredOutput(
      `Could not read Git tags, starting from ${lastVersion}`,
      "yellow",
      emojis.info
    );
  }

  // Determine base version for increment
  let baseVersion = lastVersion;
  if (currentVersion !== "0.0.0") {
    // Compare versions and use the higher one
    const currentParts = currentVersion.split(".").map(Number);
    const lastParts = lastVersion.split(".").map(Number);

    // Ensure arrays have 3 elements
    while (currentParts.length < 3) currentParts.push(0);
    while (lastParts.length < 3) lastParts.push(0);

    // Compare versions
    const isCurrentHigher =
      currentParts[0] > lastParts[0] ||
      (currentParts[0] === lastParts[0] && currentParts[1] > lastParts[1]) ||
      (currentParts[0] === lastParts[0] &&
        currentParts[1] === lastParts[1] &&
        currentParts[2] > lastParts[2]);

    if (isCurrentHigher) {
      baseVersion = currentVersion;
      coloredOutput(
        `Using package.json version ${currentVersion} as base (higher than Git tag)`,
        "green",
        emojis.info
      );
    } else {
      coloredOutput(
        `Using Git tag version ${lastVersion} as base (higher than package.json)`,
        "green",
        emojis.info
      );
    }
  } else {
    coloredOutput(
      `Using Git tag version ${lastVersion} as base`,
      "green",
      emojis.info
    );
  }

  let newVersion;

  // Determine new version
  if (options.version) {
    if (options.version.match(/^[0-9]+\.[0-9]+\.[0-9]+$/)) {
      newVersion = options.version;
      coloredOutput(
        `Using provided version: ${newVersion}`,
        "green",
        emojis.success
      );
    } else {
      coloredOutput(
        `Invalid version format: ${options.version}`,
        "red",
        emojis.error
      );
      coloredOutput(
        "Please use semantic versioning (e.g., 1.2.3)",
        "yellow",
        emojis.info
      );
      process.exit(1);
    }
  } else if (options.type) {
    newVersion = incrementVersion(baseVersion, options.type);
    coloredOutput(
      `Using ${options.type} increment: ${newVersion}`,
      "green",
      emojis.success
    );
  } else {
    // Interactive version selection
    const suggestedPatch = incrementVersion(baseVersion, "patch");
    const suggestedMinor = incrementVersion(baseVersion, "minor");
    const suggestedMajor = incrementVersion(baseVersion, "major");

    console.log("");
    coloredOutput(
      `Version suggestions based on current version (${baseVersion}):`,
      "cyan",
      emojis.gear
    );
    console.log(`  1) Patch release: ${suggestedPatch} (bugfixes)`);
    console.log(`  2) Minor release: ${suggestedMinor} (new features)`);
    console.log(`  3) Major release: ${suggestedMajor} (breaking changes)`);
    console.log(`  4) Custom version`);
    console.log("");

    let validInput = false;
    while (!validInput) {
      const versionInput = await promptUser(
        "Select version type (1-4) or enter custom version: "
      );

      switch (versionInput) {
        case "1":
          newVersion = suggestedPatch;
          validInput = true;
          break;
        case "2":
          newVersion = suggestedMinor;
          validInput = true;
          break;
        case "3":
          newVersion = suggestedMajor;
          validInput = true;
          break;
        case "4":
          const customVersion = await promptUser(
            "Enter custom version (e.g., 2.1.0): "
          );
          if (customVersion.match(/^[0-9]+\.[0-9]+\.[0-9]+$/)) {
            newVersion = customVersion;
            validInput = true;
          } else {
            coloredOutput(
              "Invalid version format. Please use semantic versioning (e.g., 1.2.3)",
              "red",
              emojis.error
            );
          }
          break;
        default:
          // Check if user entered version directly
          if (versionInput.match(/^[0-9]+\.[0-9]+\.[0-9]+$/)) {
            newVersion = versionInput;
            validInput = true;
          } else {
            coloredOutput(
              "Invalid input. Please select 1-4 or enter a valid version",
              "red",
              emojis.error
            );
          }
      }
    }
  }

  const newTag = `v${newVersion}`;

  console.log("");
  coloredOutput(`Selected version: ${newVersion}`, "green", emojis.rocket);
  coloredOutput(`Git tag will be: ${newTag}`, "green", emojis.tag);
  console.log("");

  // Check if tag already exists
  const tagExists = execCommand(`git rev-parse ${newTag}`, { silent: true });
  if (tagExists && !options.force) {
    coloredOutput(`Tag ${newTag} already exists!`, "red", emojis.error);
    coloredOutput("Existing tags:", "yellow", emojis.info);
    execCommand('git tag -l --sort=-version:refname "v*" | head -5');
    process.exit(1);
  }

  // Dry run mode
  if (options.dryRun) {
    coloredOutput(
      "DRY RUN MODE - No changes will be made",
      "yellow",
      emojis.info
    );
    console.log("");
    coloredOutput("Would update:", "cyan", emojis.info);
    console.log(`  • package.json version to ${newVersion}`);
    console.log(
      `  • .env file with VERSION=${newVersion} and APP_VERSION=${newVersion}`
    );
    console.log(`  • Create Git tag: ${newTag}`);
    console.log(`  • Push changes and tag to origin`);
    process.exit(0);
  }

  // Confirmation
  coloredOutput("This will:", "yellow", emojis.info);
  console.log(`  • Update package.json version to ${newVersion}`);
  console.log(
    `  • Update .env file with VERSION=${newVersion} and APP_VERSION=${newVersion}`
  );
  console.log(`  • Commit changes with message: 'Release ${newVersion}'`);
  console.log(`  • Create Git tag: ${newTag}`);
  console.log(`  • Push changes and tag to origin`);
  console.log("");

  if (!options.force) {
    const continueAnswer = await promptUser("Continue? (y/N): ");
    if (!continueAnswer.match(/^[Yy]$/)) {
      coloredOutput("Aborted by user", "red", emojis.error);
      process.exit(1);
    }
  }

  // 1. Update package.json
  coloredOutput("Updating package.json...", "blue", emojis.gear);
  if (setPackageVersion(packageJsonPath, newVersion)) {
    coloredOutput(
      `Updated package.json version to ${newVersion}`,
      "green",
      emojis.success
    );
  } else {
    coloredOutput("Failed to update package.json", "red", emojis.error);
    process.exit(1);
  }

  // 2. Update .env file
  coloredOutput("Updating .env file...", "blue", emojis.gear);
  if (updateEnvFile(envFilePath, newVersion)) {
    const envExists = fs.existsSync(envFilePath);
    if (envExists) {
      coloredOutput(
        `Updated .env file with VERSION=${newVersion} and APP_VERSION=${newVersion}`,
        "green",
        emojis.success
      );
    } else {
      coloredOutput(
        `Created new .env file with VERSION=${newVersion} and APP_VERSION=${newVersion}`,
        "green",
        emojis.success
      );
    }
  } else {
    coloredOutput("Failed to update .env file", "red", emojis.error);
    process.exit(1);
  }

  // 3. Update release package.json (if exists)
  const releasePackageJsonPath = path.join(
    appDir,
    "release",
    "app",
    "package.json"
  );
  if (fs.existsSync(releasePackageJsonPath)) {
    coloredOutput("Updating release/app/package.json...", "blue", emojis.gear);
    if (setPackageVersion(releasePackageJsonPath, newVersion)) {
      coloredOutput(
        `Updated release/app/package.json version to ${newVersion}`,
        "green",
        emojis.success
      );
    }
  }

  // 4. Commit changes
  coloredOutput("Committing changes...", "blue", emojis.gear);
  try {
    execCommand(`git add "${packageJsonPath}" "${envFilePath}"`);
    if (fs.existsSync(releasePackageJsonPath)) {
      execCommand(`git add "${releasePackageJsonPath}"`);
    }

    const commitMessage = `Release ${newVersion}

- Updated package.json version to ${newVersion}
- Updated .env file with VERSION=${newVersion} and APP_VERSION=${newVersion}
- Prepared for release build

[skip ci]`;

    execCommand(`git commit -m "${commitMessage}"`);
    coloredOutput("Committed changes", "green", emojis.success);
  } catch (error) {
    coloredOutput(
      `Error committing changes: ${error.message}`,
      "red",
      emojis.error
    );
    // Don't exit, continue with tagging
  }

  // 5. Create Git tag
  coloredOutput("Creating Git tag...", "blue", emojis.gear);
  try {
    const tagMessage = `Release ${newVersion}

MthBdeIotClient Raspberry Pi Release v${newVersion}

Features:
- Electron App für Raspberry Pi 3+ (ARMv7l)
- Debian Package (.deb) für einfache Installation
- Automatische Pipeline mit Azure DevOps
- GitHub Release Integration

Installation:
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/latest/download/mthbdeiotclient_${newVersion}_armhf.deb
sudo dpkg -i mthbdeiotclient_${newVersion}_armhf.deb
sudo apt-get install -f`;

    execCommand(`git tag -a "${newTag}" -m "${tagMessage}"`);
    coloredOutput(`Created tag ${newTag}`, "green", emojis.success);
  } catch (error) {
    coloredOutput(`Error creating tag: ${error.message}`, "red", emojis.error);
    process.exit(1);
  }

  // 6. Push to origin (Commit und Tag zusammen)
  coloredOutput("Pushing changes and tag to origin...", "blue", emojis.gear);
  try {
    execCommand(`git push origin HEAD ${newTag}`);
    coloredOutput(
      "Pushed changes and tag to origin (triggers pipeline)",
      "green",
      emojis.success
    );
  } catch (error) {
    coloredOutput(
      `Error pushing to origin: ${error.message}`,
      "red",
      emojis.error
    );
    coloredOutput("You may need to push manually:", "yellow", emojis.info);
    console.log(`  git push origin HEAD ${newTag}`);
  }

  // 6. Summary
  console.log("");
  coloredOutput("==========================================", "cyan");
  coloredOutput("VERSION RELEASE COMPLETED", "cyan", emojis.success);
  coloredOutput("==========================================", "cyan");
  console.log("");
  coloredOutput("Summary:", "green", emojis.info);
  console.log(`  • Version: ${newVersion}`);
  console.log(`  • Tag: ${newTag}`);

  try {
    const commitHash = execCommand("git rev-parse --short HEAD", {
      silent: true,
    });
    const branch = execCommand("git branch --show-current", { silent: true });

    if (commitHash && commitHash.trim()) {
      console.log(`  • Commit: ${commitHash.trim()}`);
    }
    if (branch && branch.trim()) {
      console.log(`  • Branch: ${branch.trim()}`);
    }
  } catch (error) {
    // Ignore errors when getting git info
  }

  console.log("");
  coloredOutput("Next steps:", "green", emojis.rocket);
  console.log("  1. Azure DevOps Pipeline will start automatically");
  console.log("  2. .deb package will be built for Raspberry Pi");
  console.log("  3. GitHub Release will be created automatically");
  console.log("  4. Package will be available as 'latest' release");
  console.log("");
  coloredOutput("Useful links:", "blue", emojis.info);
  console.log(
    "  • Azure DevOps: https://dev.azure.com/mth-it-service/MthBdeIotClient/_build"
  );
  console.log(
    "  • GitHub Repository: https://github.com/MTHBDEIOTClient/MTHBDEIOTClient"
  );
  console.log(
    "  • Latest Release: https://github.com/MTHBDEIOTClient/MTHBDEIOTClient/tree/master/releases/latest"
  );
  console.log("");
  coloredOutput(
    `Version ${newVersion} released successfully!`,
    "green",
    emojis.success
  );
}

// Run main function
main().catch((error) => {
  coloredOutput(`Error: ${error.message}`, "red", emojis.error);
  process.exit(1);
});
