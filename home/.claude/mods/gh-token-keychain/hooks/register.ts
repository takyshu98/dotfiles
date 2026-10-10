import type { Register } from 'claude-code'

// The Keychain item is created by the user, never by this mod:
//   ! security add-generic-password -s claude-code-gh-token -a "$USER" -w
const KEYCHAIN_SERVICE = 'claude-code-gh-token'

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    // argv, no shell. -w prints the password alone. The value goes only to
    // $.env.set: never to the UI, a log or the transcript.
    const found = await $.process.run([
      '/usr/bin/security',
      'find-generic-password',
      '-s',
      KEYCHAIN_SERVICE,
      '-w',
    ])
    const token = found.stdout.trim()

    if (found.exitCode === 0 && token !== '') {
      await $.env.set('GH_TOKEN', token)
    } else {
      $.ui.toast(`${$.plugin.name}: no Keychain item "${KEYCHAIN_SERVICE}"; GH_TOKEN left as is.`)
    }

    return next(e)
  }).catch(($, e, next) => {
    $.ui.toast(`${$.plugin.name}: could not read the Keychain; GH_TOKEN left as is.`)
    return next(e)
  })
}
