// hack to use a proxy for fetch()

const fs = require('fs')

// since undici is a transitive dependency, we need to load it manually from pnpm store
const modules = fs.readdirSync('./node_modules/.pnpm')
const undiciDirname = modules.find(x => x.startsWith('undici@'))
const undici = require('./node_modules/.pnpm/' + undiciDirname + '/node_modules/undici/index.js')

undici.setGlobalDispatcher(new undici.ProxyAgent('http://172.17.0.1:7890'))

// ssrf protection uses a custom dispatcher that will override the one above
// we don't actually need ssrf protection since we're proxying all requests,
// so whatever lol
process.env.PDS_DISABLE_SSRF_PROTECTION = 'true'

// continue with the rest of the actual entrypoint
require('./index.js')