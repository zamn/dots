module.exports =
/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	"use strict";

	Object.defineProperty(exports, "__esModule", {
		value: true
	});

	var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

	var _http = __webpack_require__(1);

	var _http2 = _interopRequireDefault(_http);

	var _open2 = __webpack_require__(2);

	var _open3 = _interopRequireDefault(_open2);

	var _express = __webpack_require__(3);

	var _express2 = _interopRequireDefault(_express);

	var _connectLivereload = __webpack_require__(4);

	var _connectLivereload2 = _interopRequireDefault(_connectLivereload);

	var _tinyLr = __webpack_require__(5);

	var _tinyLr2 = _interopRequireDefault(_tinyLr);

	var _watch = __webpack_require__(6);

	var _watch2 = _interopRequireDefault(_watch);

	var _url = __webpack_require__(7);

	var _url2 = _interopRequireDefault(_url);

	var _extend = __webpack_require__(8);

	var _extend2 = _interopRequireDefault(_extend);

	var _serveIndex = __webpack_require__(9);

	var _serveIndex2 = _interopRequireDefault(_serveIndex);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

	var TsServer = function () {
		function TsServer(options) {
			_classCallCheck(this, TsServer);

			this.options = null;
			this.livereloadServer = null;
			this.watcher = null;
			this.server = null;
			this.status = false;

			if ((typeof options === "undefined" ? "undefined" : _typeof(options)) === "object") {
				this.set(options);
			}
		}

		_createClass(TsServer, [{
			key: "set",
			value: function set(options) {
				var defaults = {
					host: "localhost",
					port: 8978,
					root: ".",
					open: "/",
					livereload: {
						enable: true,
						port: 9572,
						directory: ".",
						filter: function filter(file) {
							if (file.match(/node_modules/)) {
								return false;
							} else {
								return true;
							}
						},
						callback: function callback(file, current, previous) {}
					},
					middleware: [],
					indexes: false,
					onStart: function onStart(app) {},
					onOpen: function onOpen() {},
					onReload: function onReload() {},
					onRestart: function onRestart() {},
					onStop: function onStop() {}
				};
				this.options = (0, _extend2.default)(true, {}, defaults, options);

				return this;
			}
		}, {
			key: "start",
			value: function start() {
				if (!this.options) {
					console.log("options have not been set. use set(options) to set.");
					return;
				}

				if (this.status) {
					console.log("this server is running, stop it first.");
					return;
				}

				var options = this.options;
				var app = (0, _express2.default)();

				// middleware routers
				if (options.middleware instanceof Array) {
					options.middleware.filter(function (item) {
						return typeof item === "function";
					}).forEach(function (item) {
						return app.use(item);
					});
				}

				// livereload
				if (options.livereload.enable) {
					// setup routers
					app.use((0, _connectLivereload2.default)({
						port: options.livereload.port
					}));
					// setup a tiny server for livereload backend
					var livereloadServer = (0, _tinyLr2.default)();
					livereloadServer.listen(options.livereload.port, options.host);
					this.livereloadServer = livereloadServer;
					// watch files for livereload
					this.watcher = _watch2.default.watchTree(options.livereload.directory, {
						ignoreDotFiles: options.livereload.ignoreDotFiles,
						filter: options.livereload.filter,
						ignoreDirectoryPattern: options.livereload.ignoreDirectoryPattern
					}, function (file, current, previous) {
						if ((typeof file === "undefined" ? "undefined" : _typeof(file)) == "object" && previous === null && current === null) {
							// ready
						} else {
							// changed
							livereloadServer.changed({
								body: {
									files: file
								}
							});
							if (typeof options.onReload === "function") {
								options.onReload();
							}
							if (typeof options.livereload.onChange === "function") {
								options.livereload.callback(file, current, previous);
							}
						}
					});
				}

				// directory list can be seen if there is not a index.html
				if (options.indexes) {
					app.use((0, _serveIndex2.default)(options.root));
				}

				// our local path routers
				app.use(_express2.default.static(options.root));

				// backend server
				if (typeof options.onStart === "function") {
					options.onStart(app);
				}

				var self = this;
				var server = this.server = _http2.default.createServer(app).listen(options.port, options.host, function () {
					self.open(options.open);
					self.status = true;
				});
			}
		}, {
			key: "stop",
			value: function stop() {
				var options = this.options;
				var server = this.server;
				if (server && typeof server.close === "function") {
					server.close();
				}

				var livereloadServer = this.livereloadServer;
				if (livereloadServer && typeof livereloadServer.close === "function") {
					livereloadServer.close();
					if (this.watcher) {
						this.watcher.unwatchTree(options.livereload.directory);
					}
				}

				if (typeof options.onStop === "function") {
					options.onStop();
				}

				this.status = false;
			}
		}, {
			key: "restart",
			value: function restart() {
				this.stop();
				this.options.open = false; // prevent to open another browser
				this.start();

				var options = this.options;
				if (typeof options.onRestart === "function") {
					options.onRestart();
				}
			}
		}, {
			key: "reload",
			value: function reload() {
				var options = this.options;
				var livereloadServer = this.livereloadServer;
				if (livereloadServer && typeof livereloadServer.changed === "function") {
					livereloadServer.changed({
						body: {
							files: "."
						}
					});

					if (typeof options.onReload === "function") {
						options.onReload();
					}
				}
			}

			// open helper to open a uri base on current url root

		}, {
			key: "open",
			value: function open(uri) {
				if (!uri) {
					return;
				}
				var options = this.options;
				var page = _url2.default.format({
					protocol: "http",
					hostname: options.host,
					port: options.port,
					pathname: uri
				});
				(0, _open3.default)(page);
				if (typeof options.onOpen === "function") {
					options.onOpen(page);
				}
			}
		}]);

		return TsServer;
	}();

	exports.default = TsServer;

	module.exports = TsServer;

/***/ },
/* 1 */
/***/ function(module, exports) {

	module.exports = require("http");

/***/ },
/* 2 */
/***/ function(module, exports) {

	module.exports = require("open");

/***/ },
/* 3 */
/***/ function(module, exports) {

	module.exports = require("express");

/***/ },
/* 4 */
/***/ function(module, exports) {

	module.exports = require("connect-livereload");

/***/ },
/* 5 */
/***/ function(module, exports) {

	module.exports = require("tiny-lr");

/***/ },
/* 6 */
/***/ function(module, exports) {

	module.exports = require("watch");

/***/ },
/* 7 */
/***/ function(module, exports) {

	module.exports = require("url");

/***/ },
/* 8 */
/***/ function(module, exports) {

	module.exports = require("extend");

/***/ },
/* 9 */
/***/ function(module, exports) {

	module.exports = require("serve-index");

/***/ }
/******/ ]);