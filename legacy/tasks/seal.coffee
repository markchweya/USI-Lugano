# Sealing: GitHub Pages can't authenticate visitors, so the published bundle is
# encrypted instead. The page that ships is a small gate; the app itself (JS +
# CSS) only exists as AES-256-GCM ciphertext until the right password derives
# the key in the browser (PBKDF2-SHA256, Web Crypto).
#
# The password is read from the LEGACY_PASSWORD environment variable and is
# never written anywhere. ./sealed/manifest.json records a SHA-256 digest of
# the plaintext so CI can tell when the sealed copy is out of date.
path = require 'path'
crypto = require 'crypto'
zlib = require 'zlib'
CoffeeScript = require 'coffeescript'
less = require 'less'

ITERATIONS = 600000

module.exports = (grunt) ->
  p = (key) -> grunt.config "paths.#{key}"

  # The plaintext is fully determined by the sources, so its digest is reproducible.
  plaintext = ->
    JSON.stringify
      v: 1
      css: grunt.file.read path.join(p('build'), 'app.css')
      js: grunt.file.read path.join(p('build'), 'app.js')

  digest = (text) -> crypto.createHash('sha256').update(text).digest 'hex'

  gatePage = (done) ->
    gate = "#{p('src')}/gate"
    less.render(grunt.file.read("#{gate}/gate.less"), filename: path.resolve("#{gate}/gate.less"), compress: true, math: 'strict')
      .then (out) ->
        js = CoffeeScript.compile grunt.file.read("#{gate}/gate.coffee"), filename: 'gate.coffee'
        markup = grunt.file.read "#{gate}/gate.html"
        shell = grunt.file.read "#{gate}/shell.html"
        # Use function replacements: the inlined code may contain `$&`-like sequences.
        html = shell
          .replace('{{head}}', -> "<style>#{out.css}</style>")
          .replace('{{body}}', -> "#{markup}<script>#{js}</script>")
        done null, html
      .catch (err) -> done err

  grunt.registerTask 'encrypt', 'Encrypt the built bundle into ./sealed.', ->
    password = process.env.LEGACY_PASSWORD
    unless password
      return grunt.fail.warn 'Set LEGACY_PASSWORD in the environment (it is never stored).'
    if password.length < 8
      return grunt.fail.warn 'LEGACY_PASSWORD must be at least 8 characters.'

    done = @async()
    text = plaintext()
    salt = crypto.randomBytes 16
    iv = crypto.randomBytes 12
    key = crypto.pbkdf2Sync password, salt, ITERATIONS, 32, 'sha256'
    cipher = crypto.createCipheriv 'aes-256-gcm', key, iv
    # Compress first: ciphertext doesn't compress, so the server can't do it for us.
    packed = zlib.gzipSync Buffer.from(text, 'utf8'), level: 9
    body = Buffer.concat [cipher.update(packed), cipher.final()]
    # Web Crypto expects the GCM tag appended to the ciphertext.
    sealed = Buffer.concat [body, cipher.getAuthTag()]

    out = p('sealed')
    grunt.file.delete out if grunt.file.exists out
    grunt.file.write path.join(out, 'vault.json'), JSON.stringify
      v: 2
      kdf: { name: 'PBKDF2', hash: 'SHA-256', iterations: ITERATIONS, salt: salt.toString 'base64' }
      cipher: { name: 'AES-GCM', iv: iv.toString 'base64' }
      compression: 'gzip'
      data: 'vault.bin'
    grunt.file.write path.join(out, 'vault.bin'), sealed
    grunt.file.write path.join(out, 'manifest.json'), JSON.stringify({ digest: digest(text), bytes: Buffer.byteLength(text) }, null, 2) + '\n'
    for font in grunt.file.expand { cwd: path.join(p('build'), 'fonts') }, '*.woff2'
      grunt.file.copy path.join(p('build'), 'fonts', font), path.join(out, 'fonts', font)

    gatePage (err, html) ->
      return grunt.fail.warn(err) if err
      grunt.file.write path.join(out, 'index.html'), html
      grunt.log.ok "Sealed #{(sealed.length / 1024).toFixed 1} KB into #{out}/"
      done()

  grunt.registerTask 'check-seal', 'Fail if ./sealed is older than the sources.', ->
    manifest = path.join p('sealed'), 'manifest.json'
    return grunt.fail.warn 'No sealed bundle. Run `grunt seal`.' unless grunt.file.exists manifest
    expected = grunt.file.readJSON(manifest).digest
    actual = digest plaintext()
    if expected isnt actual
      grunt.fail.warn "The sealed bundle is stale (#{expected[0..11]} ≠ #{actual[0..11]}). Run `LEGACY_PASSWORD=… grunt seal` and commit ./sealed."
    else
      grunt.log.ok "Sealed bundle matches the sources (#{actual[0..11]})."
