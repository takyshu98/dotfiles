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

test('sets GH_TOKEN from the Keychain value', async ($, on) => {
  const set = stub(on, 0, 'ghp_test\n')

  await $.session.start({ cwd: '/tmp', surface: 'terminal' } as never)

  expect(set).toEqual([{ name: 'GH_TOKEN', value: 'ghp_test' }])
})

test('leaves GH_TOKEN alone when the Keychain has no item', async ($, on) => {
  const set = stub(on, 44, '')

  await $.session.start({ cwd: '/tmp', surface: 'terminal' } as never)

  expect(set).toEqual([])
})
