/**
 * Turn a title into a URL-safe slug.
 *
 * "Hello World"      -> "hello-world"
 * "  Café & Bar!  "  -> "cafe-bar"
 *
 * This is the function the workshop CI pipeline tests.
 * Keep it small on purpose — the point is the pipeline, not the algorithm.
 */
export function slugify(input) {
  if (typeof input !== 'string') {
    throw new TypeError('slugify() expects a string');
  }

  return input
    .normalize('NFD')                 // split accented chars into base + accent
    .replace(/\p{Diacritic}/gu, '')   // drop the accents
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, '-')      // anything not alphanumeric becomes a dash
    .replace(/^-+|-+$/g, '');         // trim leading/trailing dashes
}
