// Pipeline Chalk Check Script
// Robuste Überprüfung für Chalk in CI/CD Umgebungen

try {
  const chalk = require('chalk');
  console.log('✅ Chalk test:', chalk.green('SUCCESS'));
  console.log(
    '✅ Chalk version:',
    chalk.yellow(require('chalk/package.json').version),
  );
  process.exit(0);
} catch (error) {
  console.log('❌ Chalk test failed:', error.message);
  console.log('⚠️  Attempting alternative chalk check...');

  try {
    // Fallback: Versuche chalk über npx zu laden
    const { execSync } = require('child_process');
    execSync('npx chalk --version', { stdio: 'pipe' });
    console.log('✅ Chalk fallback test: SUCCESS (via npx)');
    process.exit(0);
  } catch (fallbackError) {
    console.log('❌ Chalk fallback also failed:', fallbackError.message);
    console.log(
      '⚠️  Continuing without chalk - scripts may need manual color removal',
    );
    process.exit(1);
  }
}
