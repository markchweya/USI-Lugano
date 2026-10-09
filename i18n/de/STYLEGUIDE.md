# German style guide for the USI site

Audience: prospective and current students, researchers and partners in German-speaking Switzerland.

## Register and spelling
- **Swiss Standard German**: always `ss`, never `ß` (Strasse, gross, massgebend).
- Formal address: **Sie / Ihr** (never du).
- Gender-inclusive, Swiss style: prefer neutral forms (Studierende, Forschende, Mitarbeitende, Dozierende, Doktorierende); otherwise pairs (Professorinnen und Professoren).
- Quotation marks: «…» (Swiss guillemets).
- Natural, idiomatic German — not word-for-word. Keep sentences clear and reasonably short.

## Terminology (be consistent)
| English | German |
|---|---|
| USI / Università della Svizzera italiana | unchanged |
| Faculty of Informatics | Fakultät für Informatik |
| Faculty of Economics | Fakultät für Wirtschaftswissenschaften |
| Faculty of Communication, Culture and Society | Fakultät für Kommunikation, Kultur und Gesellschaft |
| Faculty of Biomedical Sciences | Fakultät für Biomedizinische Wissenschaften |
| Academy of Architecture (Accademia di architettura) | Architekturakademie (Accademia di architettura) |
| Faculty of Theology of Lugano | Theologische Fakultät Lugano |
| Bachelor / Master | Bachelor / Master (Bachelorstudium, Masterstudium, Bachelorstudiengang) |
| PhD / doctoral studies | Doktorat |
| students | Studierende |
| credits (ECTS) | Kreditpunkte (ECTS) |
| tuition fees | Studiengebühren |
| scholarship | Stipendium |
| admission / application / enrolment | Zulassung / Bewerbung / Immatrikulation |
| study plan / curriculum | Studienplan |
| semester | Semester |
| Open Day | Infotag |
| Study Advisory Service | Studienberatung |
| West Campus / East Campus | Campus West / Campus Ost |
| Ticino / Canton Ticino | Tessin / Kanton Tessin |
| Lake Lugano | Luganersee |
| Swiss National Science Foundation (SNSF) | Schweizerischer Nationalfonds (SNF) |
| research institute | Forschungsinstitut |
| start-up | Start-up |
| Home (breadcrumb) | Startseite |
| Student Corporation | Studierendenschaft |
| Student Council / General Assembly | Studierendenrat / Studierendenvollversammlung |
| University Council / Academic Senate / Rectorate | Universitätsrat / Akademischer Senat / Rektorat |
| Faculty Council | Fakultätsrat |
| International Relations (and Study Abroad) Service | Dienst für Internationale Beziehungen (und Auslandstudium) |
| Equal Opportunities Service | Dienst für Chancengleichheit |
| Research Service / Research and Transfer Service | Forschungsdienst / Dienst für Forschung und Wissenstransfer |
| Housing Service | Wohnungsdienst |
| Institutional Communication Service | Dienst für institutionelle Kommunikation |
| Quality Assurance and Sustainability Service | Dienst für Qualitätssicherung und Nachhaltigkeit |
| Career Service, Alumni Service, Sport Service, InfoDesk, eLab | unchanged (names German speakers use as-is) |
| SERI / FCS | SBFI / ESKAS |
| Fall / Spring semester (FS26 / SS27) | Herbstsemester / Frühjahrssemester (HS26 / FS27) |
| bike | Velo |

Office names follow this table; `scripts/i18n/normalize.mjs` enforces it on the translation memory.
Well-known quotations keep their established German wording (often du-form).

## Do not translate
- Numbers: thousands separator is the Swiss apostrophe (CHF 5’000); times as 7.30–12.00 Uhr.
- Official degree titles (e.g. «Master of Science in Artificial Intelligence», «Bachelor of Science in Informatics»): keep as is.
- Names of people, institutes, projects, journals, events, buildings and streets (IDSIA, Euler Institute, InfoDesk, Via Buffi 13…). Offices: see the terminology table.
- Italian-language proper names and titles of Italian-taught programmes.
- URLs, e-mail addresses, phone numbers, course codes, dates and numbers (keep digits as given).
- Acronyms (ECTS, CHF, SNSF→SNF only when the full name is translated alongside).

## HTML
Many strings contain HTML. Translate **only the text between tags**. Keep every tag and every attribute exactly as in the source, in the same order — never add, drop, reorder or edit tags or `href` values. Keep HTML entities valid (`&amp;`, `&lt;`, `&gt;`, `&quot;`).
