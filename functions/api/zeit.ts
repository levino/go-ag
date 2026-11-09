// Cloudflare Pages Function: Terminumfrage der Go-AG.
// Braucht ein D1-Binding namens DB (Pages-Projekt → Settings → Bindings).
// Die Tabelle legt die Funktion beim ersten Aufruf selbst an.

interface Env {
  DB?: D1Database
}

const DAYS = ['montag', 'dienstag'] as const
type Day = (typeof DAYS)[number]

const CLASSES = [
  ...Array.from({ length: 13 }, (_, i) => `${i + 1}`),
  'eltern',
  'lehrkraft',
] as const

interface Vote {
  klasse: string
  vorname: string | null
  days: ReadonlyArray<Day>
}

type Tally = Record<Day, number> & { stimmen: number }

const CREATE_TABLE = `CREATE TABLE IF NOT EXISTS stimmen (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  erstellt TEXT NOT NULL DEFAULT (datetime('now')),
  klasse TEXT NOT NULL,
  vorname TEXT,
  montag INTEGER NOT NULL,
  dienstag INTEGER NOT NULL
)`

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
  })

const parseVote = (form: FormData): Vote | string => {
  const klasse = String(form.get('klasse') ?? '')
  if (!(CLASSES as ReadonlyArray<string>).includes(klasse)) {
    return 'Bitte wähle deine Klasse aus.'
  }
  const days = DAYS.filter((day) => form.getAll('tag').includes(day))
  if (days.length === 0) {
    return 'Bitte kreuze mindestens einen Tag an.'
  }
  const vorname = String(form.get('vorname') ?? '').trim().slice(0, 40)
  return { klasse, vorname: vorname === '' ? null : vorname, days }
}

const tally = async (db: D1Database): Promise<Tally> => {
  const row = await db
    .prepare(
      'SELECT COUNT(*) AS stimmen, COALESCE(SUM(montag), 0) AS montag, COALESCE(SUM(dienstag), 0) AS dienstag FROM stimmen',
    )
    .first<Tally>()
  return row ?? { stimmen: 0, montag: 0, dienstag: 0 }
}

const withDb = async (
  env: Env,
  run: (db: D1Database) => Promise<Response>,
): Promise<Response> => {
  if (!env.DB) {
    return json({ fehler: 'Die Umfrage ist noch nicht eingerichtet.' }, 503)
  }
  await env.DB.prepare(CREATE_TABLE).run()
  return run(env.DB)
}

export const onRequestGet: PagesFunction<Env> = ({ env }) =>
  withDb(env, async (db) => json(await tally(db)))

export const onRequestPost: PagesFunction<Env> = ({ env, request }) =>
  withDb(env, async (db) => {
    const wantsJson = (request.headers.get('Accept') ?? '').includes('application/json')
    const vote = parseVote(await request.formData())
    if (typeof vote === 'string') {
      return wantsJson
        ? json({ fehler: vote }, 400)
        : Response.redirect(new URL(`/zeit?fehler=${encodeURIComponent(vote)}`, request.url).toString(), 303)
    }
    await db
      .prepare('INSERT INTO stimmen (klasse, vorname, montag, dienstag) VALUES (?, ?, ?, ?)')
      .bind(
        vote.klasse,
        vote.vorname,
        vote.days.includes('montag') ? 1 : 0,
        vote.days.includes('dienstag') ? 1 : 0,
      )
      .run()
    return wantsJson
      ? json(await tally(db))
      : Response.redirect(new URL('/zeit?danke=1', request.url).toString(), 303)
  })
