'use strict'

process.env.DEBUG = '*'

const { gray } = require('picocolors')
const { promisify } = require('util')
const splashy = require('splashy')
const got = require('got')

const exec = promisify(require('child_process').exec)

const run = cmd =>
  exec(cmd).then(
    ({ stdout }) =>
      `${cmd}: 
${gray(stdout)}\n`
  )

const debugInformation = () =>
  Promise.all([
    run('node -e "console.log(process.platform)"'),
    run('node -e "console.log(process.arch)"'),
    run('node --version'),
    run('npm --version'),
    run('convert --version'),
    run('convert -list format')
  ]).then(info => console.log(info.join('')))

const palette = url =>
  got(url, { responseType: 'buffer' }).then(({ body }) => splashy(body))

const main = async url => {
  console.log()
  await debugInformation()
  return palette(url)
}

main('https://www.google.com/favicon.ico')
  .then(data => {
    const status = data.length > 0 ? 'SUCCESS' : 'FAILED'
    console.log(status, data)
    process.exit()
  })
  .catch(error => {
    console.error(error)
    process.exit(1)
  })
