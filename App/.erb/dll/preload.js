(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory();
	else if(typeof define === 'function' && define.amd)
		define([], factory);
	else {
		var a = factory();
		for(var i in a) (typeof exports === 'object' ? exports : root)[i] = a[i];
	}
})(global, () => {
return /******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "electron":
/*!***************************!*\
  !*** external "electron" ***!
  \***************************/
/***/ ((module) => {

module.exports = require("electron");

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
var __webpack_exports__ = {};
// This entry needs to be wrapped in an IIFE because it needs to be isolated against other modules in the chunk.
(() => {
var exports = __webpack_exports__;
/*!*****************************!*\
  !*** ./src/main/preload.ts ***!
  \*****************************/

Object.defineProperty(exports, "__esModule", ({ value: true }));
// Disable no-unused-vars, broken for spread args
/* eslint no-unused-vars: off */
const electron_1 = __webpack_require__(/*! electron */ "electron");
const electronHandler = {
    app: {
        restart: () => electron_1.ipcRenderer.invoke('restart-app'),
    },
    dbConfig: {
        getInitialConfig: () => electron_1.ipcRenderer.invoke('get-initial-config'),
        readAllConfig: () => electron_1.ipcRenderer.invoke('db-config-get-all'),
        getByKey: (key) => electron_1.ipcRenderer.invoke('db-config-get-by-key', key),
        createOrUpdate: (key, value) => electron_1.ipcRenderer.invoke('db-config-create-or-update', key, value),
        deleteByKey: (key) => electron_1.ipcRenderer.invoke('db-config-delete-by-key', key),
    },
    dbQuery: (query) => electron_1.ipcRenderer.invoke('db-query', query),
    getEnv: () => electron_1.ipcRenderer.invoke('get-env'),
    autoUpdater: {
        checkForUpdates: () => electron_1.ipcRenderer.invoke('check-for-updates'),
        downloadUpdate: () => electron_1.ipcRenderer.invoke('download-update'),
        installUpdate: () => electron_1.ipcRenderer.invoke('install-update'),
        getAppVersion: () => electron_1.ipcRenderer.invoke('get-app-version'),
        getUpdateInfo: () => electron_1.ipcRenderer.invoke('get-update-info'),
    },
    ipcRenderer: {
        sendMessage(channel, ...args) {
            electron_1.ipcRenderer.send(channel, ...args);
        },
        on(channel, func) {
            const subscription = (_event, ...args) => func(...args);
            electron_1.ipcRenderer.on(channel, subscription);
            return () => {
                electron_1.ipcRenderer.removeListener(channel, subscription);
            };
        },
        once(channel, func) {
            electron_1.ipcRenderer.once(channel, (_event, ...args) => func(...args));
        },
        removeAllListeners(channel) {
            electron_1.ipcRenderer.removeAllListeners(channel);
        },
        invoke(channel, ...args) {
            return electron_1.ipcRenderer.invoke(channel, ...args);
        },
    },
};
electron_1.contextBridge.exposeInMainWorld('electron', electronHandler);

})();

/******/ 	return __webpack_exports__;
/******/ })()
;
});
//# sourceMappingURL=data:application/json;charset=utf-8;base64,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QUksQ0FBQyxHQUFHLElBQUksQ0FBQyxDQUFDLENBQUM7UUFDaEUsQ0FBQztRQUNELGtCQUFrQixDQUFDLE9BQWlCO1lBQ2xDLHNCQUFXLENBQUMsa0JBQWtCLENBQUMsT0FBTyxDQUFDLENBQUM7UUFDMUMsQ0FBQztRQUNELE1BQU0sQ0FBQyxPQUFlLEVBQUUsR0FBRyxJQUFlO1lBQ3hDLE9BQU8sc0JBQVcsQ0FBQyxNQUFNLENBQUMsT0FBTyxFQUFFLEdBQUcsSUFBSSxDQUFDLENBQUM7UUFDOUMsQ0FBQztLQUNGO0NBQ0YsQ0FBQztBQUVGLHdCQUFhLENBQUMsaUJBQWlCLENBQUMsVUFBVSxFQUFFLGVBQWUsQ0FBQyxDQUFDIiwic291cmNlcyI6WyJ3ZWJwYWNrOi8vbXRoYmRlaW90Y2xpZW50L3dlYnBhY2svdW5pdmVyc2FsTW9kdWxlRGVmaW5pdGlvbiIsIndlYnBhY2s6Ly9tdGhiZGVpb3RjbGllbnQvZXh0ZXJuYWwgbm9kZS1jb21tb25qcyBcImVsZWN0cm9uXCIiLCJ3ZWJwYWNrOi8vbXRoYmRlaW90Y2xpZW50L3dlYnBhY2svYm9vdHN0cmFwIiwid2VicGFjazovL210aGJkZWlvdGNsaWVudC8uL3NyYy9tYWluL3ByZWxvYWQudHMiXSwic291cmNlc0NvbnRlbnQiOlsiKGZ1bmN0aW9uIHdlYnBhY2tVbml2ZXJzYWxNb2R1bGVEZWZpbml0aW9uKHJvb3QsIGZhY3RvcnkpIHtcblx0aWYodHlwZW9mIGV4cG9ydHMgPT09ICdvYmplY3QnICYmIHR5cGVvZiBtb2R1bGUgPT09ICdvYmplY3QnKVxuXHRcdG1vZHVsZS5leHBvcnRzID0gZmFjdG9yeSgpO1xuXHRlbHNlIGlmKHR5cGVvZiBkZWZpbmUgPT09ICdmdW5jdGlvbicgJiYgZGVmaW5lLmFtZClcblx0XHRkZWZpbmUoW10sIGZhY3RvcnkpO1xuXHRlbHNlIHtcblx0XHR2YXIgYSA9IGZhY3RvcnkoKTtcblx0XHRmb3IodmFyIGkgaW4gYSkgKHR5cGVvZiBleHBvcnRzID09PSAnb2JqZWN0JyA/IGV4cG9ydHMgOiByb290KVtpXSA9IGFbaV07XG5cdH1cbn0pKGdsb2JhbCwgKCkgPT4ge1xucmV0dXJuICIsIm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZShcImVsZWN0cm9uXCIpOyIsIi8vIFRoZSBtb2R1bGUgY2FjaGVcbnZhciBfX3dlYnBhY2tfbW9kdWxlX2NhY2hlX18gPSB7fTtcblxuLy8gVGhlIHJlcXVpcmUgZnVuY3Rpb25cbmZ1bmN0aW9uIF9fd2VicGFja19yZXF1aXJlX18obW9kdWxlSWQpIHtcblx0Ly8gQ2hlY2sgaWYgbW9kdWxlIGlzIGluIGNhY2hlXG5cdHZhciBjYWNoZWRNb2R1bGUgPSBfX3dlYnBhY2tfbW9kdWxlX2NhY2hlX19bbW9kdWxlSWRdO1xuXHRpZiAoY2FjaGVkTW9kdWxlICE9PSB1bmRlZmluZWQpIHtcblx0XHRyZXR1cm4gY2FjaGVkTW9kdWxlLmV4cG9ydHM7XG5cdH1cblx0Ly8gQ3JlYXRlIGEgbmV3IG1vZHVsZSAoYW5kIHB1dCBpdCBpbnRvIHRoZSBjYWNoZSlcblx0dmFyIG1vZHVsZSA9IF9fd2VicGFja19tb2R1bGVfY2FjaGVfX1ttb2R1bGVJZF0gPSB7XG5cdFx0Ly8gbm8gbW9kdWxlLmlkIG5lZWRlZFxuXHRcdC8vIG5vIG1vZHVsZS5sb2FkZWQgbmVlZGVkXG5cdFx0ZXhwb3J0czoge31cblx0fTtcblxuXHQvLyBFeGVjdXRlIHRoZSBtb2R1bGUgZnVuY3Rpb25cblx0X193ZWJwYWNrX21vZHVsZXNfX1ttb2R1bGVJZF0obW9kdWxlLCBtb2R1bGUuZXhwb3J0cywgX193ZWJwYWNrX3JlcXVpcmVfXyk7XG5cblx0Ly8gUmV0dXJuIHRoZSBleHBvcnRzIG9mIHRoZSBtb2R1bGVcblx0cmV0dXJuIG1vZHVsZS5leHBvcnRzO1xufVxuXG4iLCIvLyBEaXNhYmxlIG5vLXVudXNlZC12YXJzLCBicm9rZW4gZm9yIHNwcmVhZCBhcmdzXG4vKiBlc2xpbnQgbm8tdW51c2VkLXZhcnM6IG9mZiAqL1xuaW1wb3J0IHsgY29udGV4dEJyaWRnZSwgaXBjUmVuZGVyZXIsIElwY1JlbmRlcmVyRXZlbnQgfSBmcm9tICdlbGVjdHJvbic7XG5cbmV4cG9ydCB0eXBlIENoYW5uZWxzID1cbiAgfCAnaXBjLWV4YW1wbGUnXG4gIHwgJ3VwZGF0ZS1hdmFpbGFibGUnXG4gIHwgJ2Rvd25sb2FkLXByb2dyZXNzJ1xuICB8ICd1cGRhdGUtZG93bmxvYWRlZCdcbiAgfCAndXBkYXRlLW5vdC1hdmFpbGFibGUnXG4gIHwgJ3VwZGF0ZS1lcnJvcic7XG5cbmNvbnN0IGVsZWN0cm9uSGFuZGxlciA9IHtcbiAgYXBwOiB7XG4gICAgcmVzdGFydDogKCkgPT4gaXBjUmVuZGVyZXIuaW52b2tlKCdyZXN0YXJ0LWFwcCcpLFxuICB9LFxuICBkYkNvbmZpZzoge1xuICAgIGdldEluaXRpYWxDb25maWc6ICgpID0+IGlwY1JlbmRlcmVyLmludm9rZSgnZ2V0LWluaXRpYWwtY29uZmlnJyksXG5cbiAgICByZWFkQWxsQ29uZmlnOiAoKSA9PiBpcGNSZW5kZXJlci5pbnZva2UoJ2RiLWNvbmZpZy1nZXQtYWxsJyksXG4gICAgZ2V0QnlLZXk6IChrZXk6IHN0cmluZykgPT4gaXBjUmVuZGVyZXIuaW52b2tlKCdkYi1jb25maWctZ2V0LWJ5LWtleScsIGtleSksXG4gICAgY3JlYXRlT3JVcGRhdGU6IChrZXk6IHN0cmluZywgdmFsdWU6IHN0cmluZykgPT5cbiAgICAgIGlwY1JlbmRlcmVyLmludm9rZSgnZGItY29uZmlnLWNyZWF0ZS1vci11cGRhdGUnLCBrZXksIHZhbHVlKSxcbiAgICBkZWxldGVCeUtleTogKGtleTogc3RyaW5nKSA9PlxuICAgICAgaXBjUmVuZGVyZXIuaW52b2tlKCdkYi1jb25maWctZGVsZXRlLWJ5LWtleScsIGtleSksXG4gIH0sXG4gIGRiUXVlcnk6IChxdWVyeTogc3RyaW5nKSA9PiBpcGNSZW5kZXJlci5pbnZva2UoJ2RiLXF1ZXJ5JywgcXVlcnkpLFxuICBnZXRFbnY6ICgpID0+IGlwY1JlbmRlcmVyLmludm9rZSgnZ2V0LWVudicpLFxuICBhdXRvVXBkYXRlcjoge1xuICAgIGNoZWNrRm9yVXBkYXRlczogKCkgPT4gaXBjUmVuZGVyZXIuaW52b2tlKCdjaGVjay1mb3ItdXBkYXRlcycpLFxuICAgIGRvd25sb2FkVXBkYXRlOiAoKSA9PiBpcGNSZW5kZXJlci5pbnZva2UoJ2Rvd25sb2FkLXVwZGF0ZScpLFxuICAgIGluc3RhbGxVcGRhdGU6ICgpID0+IGlwY1JlbmRlcmVyLmludm9rZSgnaW5zdGFsbC11cGRhdGUnKSxcbiAgICBnZXRBcHBWZXJzaW9uOiAoKSA9PiBpcGNSZW5kZXJlci5pbnZva2UoJ2dldC1hcHAtdmVyc2lvbicpLFxuICAgIGdldFVwZGF0ZUluZm86ICgpID0+IGlwY1JlbmRlcmVyLmludm9rZSgnZ2V0LXVwZGF0ZS1pbmZvJyksXG4gIH0sXG4gIGlwY1JlbmRlcmVyOiB7XG4gICAgc2VuZE1lc3NhZ2UoY2hhbm5lbDogQ2hhbm5lbHMsIC4uLmFyZ3M6IHVua25vd25bXSkge1xuICAgICAgaXBjUmVuZGVyZXIuc2VuZChjaGFubmVsLCAuLi5hcmdzKTtcbiAgICB9LFxuICAgIG9uKGNoYW5uZWw6IENoYW5uZWxzLCBmdW5jOiAoLi4uYXJnczogdW5rbm93bltdKSA9PiB2b2lkKSB7XG4gICAgICBjb25zdCBzdWJzY3JpcHRpb24gPSAoX2V2ZW50OiBJcGNSZW5kZXJlckV2ZW50LCAuLi5hcmdzOiB1bmtub3duW10pID0+XG4gICAgICAgIGZ1bmMoLi4uYXJncyk7XG4gICAgICBpcGNSZW5kZXJlci5vbihjaGFubmVsLCBzdWJzY3JpcHRpb24pO1xuXG4gICAgICByZXR1cm4gKCkgPT4ge1xuICAgICAgICBpcGNSZW5kZXJlci5yZW1vdmVMaXN0ZW5lcihjaGFubmVsLCBzdWJzY3JpcHRpb24pO1xuICAgICAgfTtcbiAgICB9LFxuICAgIG9uY2UoY2hhbm5lbDogQ2hhbm5lbHMsIGZ1bmM6ICguLi5hcmdzOiB1bmtub3duW10pID0+IHZvaWQpIHtcbiAgICAgIGlwY1JlbmRlcmVyLm9uY2UoY2hhbm5lbCwgKF9ldmVudCwgLi4uYXJncykgPT4gZnVuYyguLi5hcmdzKSk7XG4gICAgfSxcbiAgICByZW1vdmVBbGxMaXN0ZW5lcnMoY2hhbm5lbDogQ2hhbm5lbHMpIHtcbiAgICAgIGlwY1JlbmRlcmVyLnJlbW92ZUFsbExpc3RlbmVycyhjaGFubmVsKTtcbiAgICB9LFxuICAgIGludm9rZShjaGFubmVsOiBzdHJpbmcsIC4uLmFyZ3M6IHVua25vd25bXSkge1xuICAgICAgcmV0dXJuIGlwY1JlbmRlcmVyLmludm9rZShjaGFubmVsLCAuLi5hcmdzKTtcbiAgICB9LFxuICB9LFxufTtcblxuY29udGV4dEJyaWRnZS5leHBvc2VJbk1haW5Xb3JsZCgnZWxlY3Ryb24nLCBlbGVjdHJvbkhhbmRsZXIpO1xuXG5leHBvcnQgdHlwZSBFbGVjdHJvbkhhbmRsZXIgPSB0eXBlb2YgZWxlY3Ryb25IYW5kbGVyO1xuIl0sIm5hbWVzIjpbXSwic291cmNlUm9vdCI6IiJ9