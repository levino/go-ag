// Terminumfrage der Go-AG. Läuft zur Laufzeit im Worker und speichert in D1
// (Binding DB, siehe wrangler.jsonc). Die Tabelle wird beim ersten Aufruf angelegt.
import type { APIRoute } from 'astro'
import { env } from 'cloudflare:workers'

export const prerender = false

const DAYS = ['montag', 'dienstag'] as const
type Day = (typeof DAYS)[number]

const CLASSES: ReadonlyArray<string> = [
  ...Array.from({ length: 13 }, (_, i) => `${i + 1}`),
  'eltern',
  'lehrkraft',
]

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
  if (!CLASSES.includes(klasse)) {
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

const withDb = async (run: (db: D1Database) => Promise<Response>): Promise<Response> => {
  await env.DB.prepare(CREATE_TABLE).run()
  return run(env.DB)
}

export const GET: APIRoute = () => withDb(async (db) => json(await tally(db)))

export const POST: APIRoute = ({ request, redirect }) =>
  withDb(async (db) => {
    const wantsJson = (request.headers.get('Accept') ?? '').includes('application/json')
    const vote = parseVote(await request.formData())
    if (typeof vote === 'string') {
      return wantsJson
        ? json({ fehler: vote }, 400)
        : redirect(`/zeit?fehler=${encodeURIComponent(vote)}`, 303)
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
    return wantsJson ? json(await tally(db)) : redirect('/zeit?danke=1', 303)
  })
