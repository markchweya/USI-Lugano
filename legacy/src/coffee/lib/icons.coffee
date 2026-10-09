# Inline SVG icons (stroke-based, currentColor).
define ->
  svg = (body, size = 20) ->
    "<svg class=\"icon\" width=\"#{size}\" height=\"#{size}\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.7\" stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\" focusable=\"false\">#{body}</svg>"

  ICONS =
    search: '<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>'
    arrow: '<path d="M5 12h14M13 6l6 6-6 6"/>'
    arrowLeft: '<path d="M19 12H5M11 6l-6 6 6 6"/>'
    external: '<path d="M14 4h6v6M20 4l-9 9M18 14v5a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h5"/>'
    menu: '<path d="M4 7h16M4 12h16M4 17h16"/>'
    close: '<path d="M6 6l12 12M18 6 6 18"/>'
    sun: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>'
    moon: '<path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5Z"/>'
    system: '<rect x="3" y="4" width="18" height="12" rx="2"/><path d="M8 20h8M12 16v4"/>'
    globe: '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/>'
    lock: '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/>'
    play: '<path d="M8 5v14l11-7Z" fill="currentColor" stroke="none"/>'
    chevron: '<path d="m9 6 6 6-6 6"/>'
    chevronLeft: '<path d="m15 6-6 6 6 6"/>'
    page: '<path d="M7 3h7l5 5v12a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1Z"/><path d="M14 3v5h5"/>'
    cap: '<path d="m2 9 10-5 10 5-10 5Z"/><path d="M6 11v5c0 1.5 3 3 6 3s6-1.5 6-3v-5"/>'
    compass: '<circle cx="12" cy="12" r="9"/><path d="m15.5 8.5-2 5-5 2 2-5Z"/>'
    pin: '<path d="M12 21s7-6.2 7-12a7 7 0 0 0-14 0c0 5.8 7 12 7 12Z"/><circle cx="12" cy="9" r="2.5"/>'
    calendar: '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/>'
    layers: '<path d="m12 3 9 5-9 5-9-5Z"/><path d="m3 13 9 5 9-5"/>'

  icon = (name, size) -> svg(ICONS[name] ? ICONS.page, size)
  icon.names = Object.keys ICONS
  icon
