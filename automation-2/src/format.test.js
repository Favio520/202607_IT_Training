import { test } from 'node:test';
import assert from 'node:assert/strict';
import { slugify } from './format.js';

test('lowercases and joins words with dashes', () => {
  assert.equal(slugify('Hello World'), 'hello_world');
});

test('strips accents and punctuation', () => {
  assert.equal(slugify('  Café & Bar!  '), 'cafe-bar');
});

test('rejects non-string input', () => {
  assert.throws(() => slugify(42), TypeError);
});
