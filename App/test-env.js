const { exec } = require('child_process');

console.log('Current directory:', process.cwd());
console.log('DEV_1080:', process.env.DEV_1080);
console.log('RASPBERRY_PI:', process.env.RASPBERRY_PI);

// Simuliere die main.ts Logik
const isDev1080Mode =
  process.argv.includes('--dev1080') || process.env.DEV_1080 === 'true';

const isFullscreenMode =
  process.argv.includes('--fullscreen') ||
  process.argv.includes('--kiosk') ||
  process.env.KIOSK_MODE === 'true';

let windowWidth = 1024;
let windowHeight = 728;

if (isDev1080Mode || isFullscreenMode) {
  windowWidth = 1920;
  windowHeight = 1080;
}

console.log(
  `🖥️  Window size: ${windowWidth}x${windowHeight} (Fullscreen: ${isFullscreenMode}, Dev1080: ${isDev1080Mode})`,
);
console.log('Process args:', process.argv);
