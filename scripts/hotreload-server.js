// Hot reload server for local development
//
// Description: This script implements a simple web socket server that watches
// relevant directories for changes and sends a reload signal to the connected
// browser clients to reload the page on a change. When the change occurs in the
// less files, it also recompiles the less files to css.
//
// Requirements: bun
//
// Usage:
// 1) enable hot_reload in the kivitendo.conf
//    (this injects the minimal javascript required on the client side)
// 2) run this server script alongside your regular web server using:
//
//      bun run -p 7575 hotreload-server.js
//
// 3) the browser client has to be refreshed once manually in order to load the
//    javascript and connect to the websocket server, after that the browser
//    should automatically reload the page when a change occurred (e.g. saving a file)
//
// Currently the port is hard coded in the javascript client. If you want to change
// the port, you have to change it in the client script. See js/hotreload.js
//
import { watch } from "fs";
import { $ } from "bun";

const directories = [
  '../bin',
  '../css',
  '../dispatcher.fcgi',
  '../dispatcher.pl',
  '../locale',
  '../SL',
  '../templates',
  '../config',
  '../dispatcher.fpl',
  '../js',
  '../t',
];

let connections = [];

const rateLimit = (fn, delay) => {
  let timer = null;
  return (...args) => {
    if (timer === null) {
      fn(...args);
      timer = setTimeout(() => {
        timer = null;
      }, delay);
    }
  };
};

const reloadCallback = async (event, filename) => {
  connections.forEach(async ws => {
    console.log(`Detected ${event} in ${filename}`);
    if (filename === "design40/main.css") {
      // avoid re-detecting changes after compiling less
      console.log("return");
      return;
    }
    if (filename.startsWith('design40/less/')) {
      // execute lessc compiler
      console.log("Compiling less files");
      const output = await $`lessc -x ../css/design40/less/style.less ../css/design40/style.css`.text();
      console.log(output);
    }
    console.log("Sending reload");
    ws.send("reload");
    ws.close()
  });
}

directories.forEach(dir => {
  const watcher = watch(
    dir,
    { recursive: true, },
    rateLimit(reloadCallback, 1000),
  );
});

Bun.serve({
  fetch(req, server) {
    // upgrade the request to a WebSocket
    // (according to bun example code)
    if (server.upgrade(req)) {
      return; // do not return a Response
    }
    return new Response("Upgrade failed", { status: 500 });
  },
  websocket: {
    open(ws) {
      console.log("WebSocket opened");
      connections.push(ws);
    },
    close(ws) {
      console.log("WebSocket closed");
      connections = connections.filter(conn => conn !== ws);
    },
  }, // handlers
});
