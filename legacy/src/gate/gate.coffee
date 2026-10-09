# The gate: derives an AES key from the password with PBKDF2 and decrypts the
# sealed app in the browser. Plain ES5 + Web Crypto; no libraries load before
# the password is accepted.

COPY =
  en:
    eyebrow: 'Università della Svizzera italiana'
    title: 'Legacy Edition'
    lede: 'A private preview of the USI website, rebuilt from scratch on a front-end stack the industry retired.'
    label: 'Password'
    show: 'Show'
    hide: 'Hide'
    unlock: 'Unlock'
    unlocking: 'Unlocking…'
    wrong: 'That password isn’t right. Try again.'
    empty: 'Enter the password to continue.'
    offline: 'The encrypted site couldn’t be loaded. Check your connection and refresh.'
    insecure: 'This browser can’t decrypt the site here. Open it over HTTPS in a current browser.'
    note: 'Encrypted with AES-256-GCM. Your password never leaves this browser.'
  it:
    eyebrow: 'Università della Svizzera italiana'
    title: 'Legacy Edition'
    lede: 'Un’anteprima privata del sito dell’USI, ricostruito da zero con uno stack front-end che il settore ha ormai abbandonato.'
    label: 'Password'
    show: 'Mostra'
    hide: 'Nascondi'
    unlock: 'Sblocca'
    unlocking: 'Sblocco in corso…'
    wrong: 'La password non è corretta. Riprova.'
    empty: 'Inserisci la password per continuare.'
    offline: 'Impossibile caricare il sito cifrato. Controlla la connessione e ricarica la pagina.'
    insecure: 'Questo browser non può decifrare il sito qui. Aprilo via HTTPS con un browser aggiornato.'
    note: 'Cifrato con AES-256-GCM. La password non lascia mai questo browser.'
  de:
    eyebrow: 'Università della Svizzera italiana'
    title: 'Legacy Edition'
    lede: 'Eine private Vorschau der USI-Website, von Grund auf neu gebaut mit einem Frontend-Stack, den die Branche längst ausgemustert hat.'
    label: 'Passwort'
    show: 'Anzeigen'
    hide: 'Verbergen'
    unlock: 'Entsperren'
    unlocking: 'Wird entsperrt…'
    wrong: 'Das Passwort ist nicht korrekt. Bitte erneut versuchen.'
    empty: 'Bitte geben Sie das Passwort ein.'
    offline: 'Die verschlüsselte Website konnte nicht geladen werden. Prüfen Sie die Verbindung und laden Sie neu.'
    insecure: 'Dieser Browser kann die Website hier nicht entschlüsseln. Öffnen Sie sie über HTTPS in einem aktuellen Browser.'
    note: 'Verschlüsselt mit AES-256-GCM. Ihr Passwort verlässt diesen Browser nie.'

SESSION_KEY = 'usi-legacy-key'

# The language the app will open in: the URL's, then the stored one, then the browser's.
pickLang = ->
  fromHash = /^#\/(en|it|de)(\/|$)/.exec(location.hash)?[1]
  return fromHash if fromHash
  try
    stored = localStorage.getItem 'usi-legacy-lang'
    return stored if COPY[stored]
  for l in (navigator.languages or [navigator.language or 'en'])
    short = String(l).slice(0, 2).toLowerCase()
    return short if COPY[short]
  'en'

lang = pickLang()
t = COPY[lang]
document.documentElement.lang = lang

$ = (sel) -> document.querySelector sel
gate = $('#gate')
form = $('.gate__form')
input = $('#gate-password')
reveal = $('.gate__reveal')
submit = $('.gate__submit')
status = $('#gate-status')

for el in document.querySelectorAll('[data-i18n]')
  el.textContent = t[el.getAttribute 'data-i18n']

fromB64 = (s) ->
  bin = atob s
  bytes = new Uint8Array bin.length
  bytes[i] = bin.charCodeAt(i) for i in [0...bin.length]
  bytes

toB64 = (buf) ->
  bytes = new Uint8Array buf
  s = ''
  s += String.fromCharCode(b) for b in bytes
  btoa s

say = (msg, kind) ->
  status.textContent = msg
  status.className = 'gate__status' + (if kind then " is-#{kind}" else '')

subtle = window.crypto?.subtle
vault = null

# Metadata (salt, IV) is JSON; the ciphertext is a separate binary file.
loadVault = ->
  get = (file, as) ->
    fetch(file, cache: 'no-cache').then (r) ->
      throw new Error(file) unless r.ok
      r[as]()
  get('vault.json', 'json').then (meta) ->
    get(meta.data, 'arrayBuffer').then (buf) ->
      meta.bytes = new Uint8Array buf
      meta

deriveKey = (password) ->
  enc = new TextEncoder()
  subtle.importKey('raw', enc.encode(password), 'PBKDF2', false, ['deriveKey']).then (base) ->
    subtle.deriveKey
      name: 'PBKDF2'
      hash: vault.kdf.hash
      salt: fromB64 vault.kdf.salt
      iterations: vault.kdf.iterations
    , base, { name: 'AES-GCM', length: 256 }, true, ['decrypt']

gunzip = (bytes) ->
  stream = new Blob([bytes]).stream().pipeThrough(new DecompressionStream 'gzip')
  new Response(stream).text()

decrypt = (key) ->
  subtle.decrypt({ name: 'AES-GCM', iv: fromB64 vault.cipher.iv }, key, vault.bytes)
    .then (plain) -> gunzip plain
    .then (text) -> JSON.parse text

# Hand the page over to the decrypted app.
boot = (payload) ->
  window.USI_LEGACY = { sealed: true, lang: lang }
  style = document.createElement 'style'
  style.textContent = payload.css
  document.head.appendChild style
  app = document.createElement 'div'
  app.id = 'app'
  gate.parentNode.replaceChild app, gate
  script = document.createElement 'script'
  script.textContent = payload.js
  document.body.appendChild script

# Same tab, same vault: reuse the key so a refresh doesn't ask again.
resume = ->
  try
    saved = JSON.parse sessionStorage.getItem(SESSION_KEY) or 'null'
  return Promise.reject() unless saved and saved.salt is vault.kdf.salt
  subtle.importKey('raw', fromB64(saved.key), 'AES-GCM', false, ['decrypt']).then(decrypt)

remember = (key) ->
  subtle.exportKey('raw', key).then (raw) ->
    try sessionStorage.setItem SESSION_KEY, JSON.stringify(salt: vault.kdf.salt, key: toB64 raw)

showForm = ->
  document.documentElement.className += ' gate-ready'
  input.focus()

unless subtle and window.TextEncoder and window.fetch and window.DecompressionStream
  say t.insecure, 'error'
  submit.disabled = true
  document.documentElement.className += ' gate-ready'
else
  loadVault()
    .then (v) ->
      vault = v
      resume().then(boot, showForm)
    .catch ->
      say t.offline, 'error'
      showForm()

reveal.addEventListener 'click', ->
  shown = input.type is 'text'
  input.type = if shown then 'password' else 'text'
  reveal.textContent = if shown then t.show else t.hide
  reveal.setAttribute 'aria-pressed', String(not shown)
  input.focus()

form.addEventListener 'submit', (e) ->
  e.preventDefault()
  return if submit.disabled
  unless input.value
    say t.empty, 'error'
    return input.focus()
  submit.disabled = true
  gate.className = 'gate is-busy'
  say t.unlocking
  ready = if vault then Promise.resolve(vault) else loadVault().then (v) -> vault = v
  key = null
  ready
    .then -> deriveKey input.value
    .then (k) -> key = k; decrypt k
    .then (payload) ->
      start = -> boot payload
      remember(key).then start, start
    .catch (err) ->
      submit.disabled = false
      gate.className = 'gate is-wrong'
      say (if vault then t.wrong else t.offline), 'error'
      input.select()
      setTimeout (-> gate.className = 'gate'), 450
