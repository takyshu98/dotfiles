import { test, expect } from 'claude-code/testing'
import type { On } from 'claude-code/testing'

// The Keychain and the process environment are stubbed beneath the plugin:
// the test never reads a real credential.
const stub = (on: On, exitCode: number, stdout: string) => {
  const set: Array<{ name: string; value?: string }> = []
  on('session.start', () => ({ cwd: '/tmp' }))
  on('process.run', () => ({
    value: { exitCode, stdout, stderr: '', isStdoutTruncated: false, isStderrTruncated: false },
  }))
  on('env.set', (_$, e) => {
    set.push(e)
    return { value: undefined }
  })
  on('ui.toast', () => ({ value: undefined }))
  return set
}

test('sets CLOUDFLARE_API_TOKEN from the Keychain value', async ($, on) => {
  const set = stub(on, 0, 'cfut_test\n')

  await $.session.start({ cwd: '/tmp', surface: 'terminal' } as never)

  expect(set).toEqual([{ name: 'CLOUDFLARE_API_TOKEN', value: 'cfut_test' }])
})

test('leaves CLOUDFLARE_API_TOKEN alone when the Keychain has no item', async ($, on) => {
  const set = stub(on, 44, '')

  await $.session.start({ cwd: '/tmp', surface: 'terminal' } as never)

  expect(set).toEqual([])
})
