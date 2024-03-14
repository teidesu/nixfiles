const fs = require('fs')
const path = require('path')

const LOCALES_DIR = '/sharkey/built/_frontend_dist_/locales'

const locales = fs.readdirSync(LOCALES_DIR)
const enLocale = locales.find(locale => locale.startsWith('en-US.') && locale.endsWith('.json'))
if (!enLocale) {
    throw new Error('en-US locale not found')
}

function parseInterpolations(str) {
    const regex = /{([^}]+)}/g
    const matches = str.match(regex)
    if (!matches) {
        return { parts: [str], variables: [] }
    }

    const parts = []
    const variables = []

    let lastIndex = 0
    for (const match of matches) {
        const index = str.indexOf(match)
        const part = str.slice(lastIndex, index)
        parts.push(part)

        const variable = match.slice(1, -1)
        variables.push(variable)

        lastIndex = index + match.length
    }

    const lastPart = str.slice(lastIndex)
    parts.push(lastPart)

    return { parts, variables }
}

function unparseInterpolations({ parts, variables }) {
    let str = parts[0]
    for (let i = 0; i < variables.length; i++) {
        str += `{${variables[i]}}${parts[i + 1]}`
    }
    return str
}

const enLocaleFull = path.join(LOCALES_DIR, enLocale)
const json = JSON.parse(fs.readFileSync(enLocaleFull, 'utf8'))

// recursively make every string lowercase
function patchObject(obj) {
    for (const [key, value] of Object.entries(obj)) {
        if (typeof value === 'object') {
            patchObject(value)
            continue
        }

        if (typeof value !== 'string') {
            continue
        }

        const { parts, variables } = parseInterpolations(value)
        const lowercasedParts = parts.map(part => part.toLowerCase())
        const newValue = unparseInterpolations({ parts: lowercasedParts, variables })
        obj[key] = newValue
    }
}

patchObject(json)

fs.writeFileSync(enLocaleFull, JSON.stringify(json, null))