// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.

import "../css/app.scss"
import "@fontsource/inter/variable.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import 'alpinejs'
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"

let Hooks = {}

Hooks.VkContainerLog = {
	updated() {
		var logsDiv = document.getElementById("clogsholder")
		logsDiv.scrollTop = logsDiv.scrollHeight
	}
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token: csrfToken } })
liveSocket.connect()
window.liveSocket = liveSocket
liveSocket.enableDebug()


