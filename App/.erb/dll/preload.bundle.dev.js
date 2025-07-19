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
//# sourceMappingURL=data:application/json;charset=utf-8;base64,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QUFFLENBQUMsSUFBSSxDQUFDLEdBQUcsSUFBSSxDQUFDLENBQUMsQ0FBQztRQUNoRSxDQUFDO1FBQ0Qsa0JBQWtCLENBQUMsT0FBaUI7WUFDbEMsc0JBQVcsQ0FBQyxrQkFBa0IsQ0FBQyxPQUFPLENBQUMsQ0FBQztRQUMxQyxDQUFDO1FBQ0QsTUFBTSxDQUFDLE9BQWUsRUFBRSxHQUFHLElBQWU7WUFDeEMsT0FBTyxzQkFBVyxDQUFDLE1BQU0sQ0FBQyxPQUFPLEVBQUUsR0FBRyxJQUFJLENBQUMsQ0FBQztRQUM5QyxDQUFDO0tBQ0Y7Q0FDRixDQUFDO0FBRUYsd0JBQWEsQ0FBQyxpQkFBaUIsQ0FBQyxVQUFVLEVBQUUsZUFBZSxDQUFDLENBQUMiLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly9tdGhiZGVpb3RjbGllbnQvd2VicGFjay91bml2ZXJzYWxNb2R1bGVEZWZpbml0aW9uIiwid2VicGFjazovL210aGJkZWlvdGNsaWVudC9leHRlcm5hbCBub2RlLWNvbW1vbmpzIFwiZWxlY3Ryb25cIiIsIndlYnBhY2s6Ly9tdGhiZGVpb3RjbGllbnQvd2VicGFjay9ib290c3RyYXAiLCJ3ZWJwYWNrOi8vbXRoYmRlaW90Y2xpZW50Ly4vc3JjL21haW4vcHJlbG9hZC50cyJdLCJzb3VyY2VzQ29udGVudCI6WyIoZnVuY3Rpb24gd2VicGFja1VuaXZlcnNhbE1vZHVsZURlZmluaXRpb24ocm9vdCwgZmFjdG9yeSkge1xuXHRpZih0eXBlb2YgZXhwb3J0cyA9PT0gJ29iamVjdCcgJiYgdHlwZW9mIG1vZHVsZSA9PT0gJ29iamVjdCcpXG5cdFx0bW9kdWxlLmV4cG9ydHMgPSBmYWN0b3J5KCk7XG5cdGVsc2UgaWYodHlwZW9mIGRlZmluZSA9PT0gJ2Z1bmN0aW9uJyAmJiBkZWZpbmUuYW1kKVxuXHRcdGRlZmluZShbXSwgZmFjdG9yeSk7XG5cdGVsc2Uge1xuXHRcdHZhciBhID0gZmFjdG9yeSgpO1xuXHRcdGZvcih2YXIgaSBpbiBhKSAodHlwZW9mIGV4cG9ydHMgPT09ICdvYmplY3QnID8gZXhwb3J0cyA6IHJvb3QpW2ldID0gYVtpXTtcblx0fVxufSkoZ2xvYmFsLCAoKSA9PiB7XG5yZXR1cm4gIiwibW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKFwiZWxlY3Ryb25cIik7IiwiLy8gVGhlIG1vZHVsZSBjYWNoZVxudmFyIF9fd2VicGFja19tb2R1bGVfY2FjaGVfXyA9IHt9O1xuXG4vLyBUaGUgcmVxdWlyZSBmdW5jdGlvblxuZnVuY3Rpb24gX193ZWJwYWNrX3JlcXVpcmVfXyhtb2R1bGVJZCkge1xuXHQvLyBDaGVjayBpZiBtb2R1bGUgaXMgaW4gY2FjaGVcblx0dmFyIGNhY2hlZE1vZHVsZSA9IF9fd2VicGFja19tb2R1bGVfY2FjaGVfX1ttb2R1bGVJZF07XG5cdGlmIChjYWNoZWRNb2R1bGUgIT09IHVuZGVmaW5lZCkge1xuXHRcdHJldHVybiBjYWNoZWRNb2R1bGUuZXhwb3J0cztcblx0fVxuXHQvLyBDcmVhdGUgYSBuZXcgbW9kdWxlIChhbmQgcHV0IGl0IGludG8gdGhlIGNhY2hlKVxuXHR2YXIgbW9kdWxlID0gX193ZWJwYWNrX21vZHVsZV9jYWNoZV9fW21vZHVsZUlkXSA9IHtcblx0XHQvLyBubyBtb2R1bGUuaWQgbmVlZGVkXG5cdFx0Ly8gbm8gbW9kdWxlLmxvYWRlZCBuZWVkZWRcblx0XHRleHBvcnRzOiB7fVxuXHR9O1xuXG5cdC8vIEV4ZWN1dGUgdGhlIG1vZHVsZSBmdW5jdGlvblxuXHRfX3dlYnBhY2tfbW9kdWxlc19fW21vZHVsZUlkXShtb2R1bGUsIG1vZHVsZS5leHBvcnRzLCBfX3dlYnBhY2tfcmVxdWlyZV9fKTtcblxuXHQvLyBSZXR1cm4gdGhlIGV4cG9ydHMgb2YgdGhlIG1vZHVsZVxuXHRyZXR1cm4gbW9kdWxlLmV4cG9ydHM7XG59XG5cbiIsIi8vIERpc2FibGUgbm8tdW51c2VkLXZhcnMsIGJyb2tlbiBmb3Igc3ByZWFkIGFyZ3Ncbi8qIGVzbGludCBuby11bnVzZWQtdmFyczogb2ZmICovXG5pbXBvcnQgeyBjb250ZXh0QnJpZGdlLCBpcGNSZW5kZXJlciwgSXBjUmVuZGVyZXJFdmVudCB9IGZyb20gJ2VsZWN0cm9uJztcblxuZXhwb3J0IHR5cGUgQ2hhbm5lbHMgPVxuICB8ICdpcGMtZXhhbXBsZSdcbiAgfCAndXBkYXRlLWF2YWlsYWJsZSdcbiAgfCAnZG93bmxvYWQtcHJvZ3Jlc3MnXG4gIHwgJ3VwZGF0ZS1kb3dubG9hZGVkJ1xuICB8ICd1cGRhdGUtbm90LWF2YWlsYWJsZSdcbiAgfCAndXBkYXRlLWVycm9yJztcblxuY29uc3QgZWxlY3Ryb25IYW5kbGVyID0ge1xuICBhcHA6IHtcbiAgICByZXN0YXJ0OiAoKSA9PiBpcGNSZW5kZXJlci5pbnZva2UoJ3Jlc3RhcnQtYXBwJyksXG4gIH0sXG4gIGRiQ29uZmlnOiB7XG4gICAgZ2V0SW5pdGlhbENvbmZpZzogKCkgPT4gaXBjUmVuZGVyZXIuaW52b2tlKCdnZXQtaW5pdGlhbC1jb25maWcnKSxcblxuICAgIHJlYWRBbGxDb25maWc6ICgpID0+IGlwY1JlbmRlcmVyLmludm9rZSgnZGItY29uZmlnLWdldC1hbGwnKSxcbiAgICBnZXRCeUtleTogKGtleTogc3RyaW5nKSA9PiBpcGNSZW5kZXJlci5pbnZva2UoJ2RiLWNvbmZpZy1nZXQtYnkta2V5Jywga2V5KSxcbiAgICBjcmVhdGVPclVwZGF0ZTogKGtleTogc3RyaW5nLCB2YWx1ZTogc3RyaW5nKSA9PlxuICAgICAgaXBjUmVuZGVyZXIuaW52b2tlKCdkYi1jb25maWctY3JlYXRlLW9yLXVwZGF0ZScsIGtleSwgdmFsdWUpLFxuICAgIGRlbGV0ZUJ5S2V5OiAoa2V5OiBzdHJpbmcpID0+XG4gICAgICBpcGNSZW5kZXJlci5pbnZva2UoJ2RiLWNvbmZpZy1kZWxldGUtYnkta2V5Jywga2V5KSxcbiAgfSxcbiAgZGJRdWVyeTogKHF1ZXJ5OiBzdHJpbmcpID0+IGlwY1JlbmRlcmVyLmludm9rZSgnZGItcXVlcnknLCBxdWVyeSksXG4gIGdldEVudjogKCkgPT4gaXBjUmVuZGVyZXIuaW52b2tlKCdnZXQtZW52JyksXG4gIGF1dG9VcGRhdGVyOiB7XG4gICAgY2hlY2tGb3JVcGRhdGVzOiAoKSA9PiBpcGNSZW5kZXJlci5pbnZva2UoJ2NoZWNrLWZvci11cGRhdGVzJyksXG4gICAgZG93bmxvYWRVcGRhdGU6ICgpID0+IGlwY1JlbmRlcmVyLmludm9rZSgnZG93bmxvYWQtdXBkYXRlJyksXG4gICAgaW5zdGFsbFVwZGF0ZTogKCkgPT4gaXBjUmVuZGVyZXIuaW52b2tlKCdpbnN0YWxsLXVwZGF0ZScpLFxuICAgIGdldEFwcFZlcnNpb246ICgpID0+IGlwY1JlbmRlcmVyLmludm9rZSgnZ2V0LWFwcC12ZXJzaW9uJyksXG4gICAgZ2V0VXBkYXRlSW5mbzogKCkgPT4gaXBjUmVuZGVyZXIuaW52b2tlKCdnZXQtdXBkYXRlLWluZm8nKSxcbiAgfSxcbiAgaXBjUmVuZGVyZXI6IHtcbiAgICBzZW5kTWVzc2FnZShjaGFubmVsOiBDaGFubmVscywgLi4uYXJnczogdW5rbm93bltdKSB7XG4gICAgICBpcGNSZW5kZXJlci5zZW5kKGNoYW5uZWwsIC4uLmFyZ3MpO1xuICAgIH0sXG4gICAgb24oY2hhbm5lbDogQ2hhbm5lbHMsIGZ1bmM6ICguLi5hcmdzOiB1bmtub3duW10pID0+IHZvaWQpIHtcbiAgICAgIGNvbnN0IHN1YnNjcmlwdGlvbiA9IChfZXZlbnQ6IElwY1JlbmRlcmVyRXZlbnQsIC4uLmFyZ3M6IHVua25vd25bXSkgPT5cbiAgICAgICAgZnVuYyguLi5hcmdzKTtcbiAgICAgIGlwY1JlbmRlcmVyLm9uKGNoYW5uZWwsIHN1YnNjcmlwdGlvbik7XG5cbiAgICAgIHJldHVybiAoKSA9PiB7XG4gICAgICAgIGlwY1JlbmRlcmVyLnJlbW92ZUxpc3RlbmVyKGNoYW5uZWwsIHN1YnNjcmlwdGlvbik7XG4gICAgICB9O1xuICAgIH0sXG4gICAgb25jZShjaGFubmVsOiBDaGFubmVscywgZnVuYzogKC4uLmFyZ3M6IHVua25vd25bXSkgPT4gdm9pZCkge1xuICAgICAgaXBjUmVuZGVyZXIub25jZShjaGFubmVsLCAoX2V2ZW50LCAuLi5hcmdzKSA9PiBmdW5jKC4uLmFyZ3MpKTtcbiAgICB9LFxuICAgIHJlbW92ZUFsbExpc3RlbmVycyhjaGFubmVsOiBDaGFubmVscykge1xuICAgICAgaXBjUmVuZGVyZXIucmVtb3ZlQWxsTGlzdGVuZXJzKGNoYW5uZWwpO1xuICAgIH0sXG4gICAgaW52b2tlKGNoYW5uZWw6IHN0cmluZywgLi4uYXJnczogdW5rbm93bltdKSB7XG4gICAgICByZXR1cm4gaXBjUmVuZGVyZXIuaW52b2tlKGNoYW5uZWwsIC4uLmFyZ3MpO1xuICAgIH0sXG4gIH0sXG59O1xuXG5jb250ZXh0QnJpZGdlLmV4cG9zZUluTWFpbldvcmxkKCdlbGVjdHJvbicsIGVsZWN0cm9uSGFuZGxlcik7XG5cbmV4cG9ydCB0eXBlIEVsZWN0cm9uSGFuZGxlciA9IHR5cGVvZiBlbGVjdHJvbkhhbmRsZXI7XG4iXSwibmFtZXMiOltdLCJzb3VyY2VSb290IjoiIn0=