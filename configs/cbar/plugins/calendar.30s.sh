#!/usr/bin/env python3
# cbar: Minimalist Calendar (Current & Upcoming Event Only)
# deps: python3, sqlite3, base64

import glob
import sqlite3
import os
import re
import datetime
import base64

# Clean, 22x22 SVG icons matching COSMIC aesthetics (rendered 2x bigger than text glyphs)
SVG_CALENDAR = (
    '<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" '
    'fill="none" stroke="#f2f2f2" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'
    '<rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>'
    '<line x1="16" y1="2" x2="16" y2="6"/>'
    '<line x1="8" y1="2" x2="8" y2="6"/>'
    '<line x1="3" y1="10" x2="21" y2="10"/>'
    '</svg>'
)

SVG_MEET = (
    '<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" '
    'fill="none" stroke="#4ade80" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'
    '<polygon points="23 7 16 12 23 17 23 7"/>'
    '<rect x="1" y="5" width="15" height="14" rx="2" ry="2"/>'
    '</svg>'
)

B64_CALENDAR = base64.b64encode(SVG_CALENDAR.encode()).decode()
B64_MEET = base64.b64encode(SVG_MEET.encode()).decode()

def main():
    now = datetime.datetime.now()
    today_date = now.date()
    today_dow = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'][now.weekday()]

    events = []

    db_files = glob.glob(os.path.expanduser('~/.cache/evolution/calendar/*/cache.db'))
    for db in db_files:
        try:
            con = sqlite3.connect(f"file:{db}?mode=ro", uri=True)
            cur = con.cursor()
            cur.execute('SELECT summary, ECacheOBJ, description, location FROM ECacheObjects WHERE ECacheOBJ IS NOT NULL')
            rows = cur.fetchall()
            con.close()
        except Exception:
            continue

        for summary, obj_str, desc, loc in rows:
            if not summary or not obj_str:
                continue

            obj_clean = obj_str.replace('\r\n ', '').replace('\n ', '')

            # Extract Google Meet (or Zoom/Teams) link
            meet_match = re.search(r'https://meet\.google\.com/[a-z]{3}-[a-z]{4}-[a-z]{3}', (desc or '') + ' ' + (loc or '') + ' ' + obj_clean)
            meet_url = meet_match.group(0) if meet_match else None

            if not meet_url:
                zoom_match = re.search(r'https://[a-zA-Z0-9\.\-]*zoom\.us/j/[0-9]+[^\s"<>]*', (desc or '') + ' ' + (loc or '') + ' ' + obj_clean)
                meet_url = zoom_match.group(0) if zoom_match else None

            # Parse DTSTART and RRULE
            dtstart = None
            rrule = None
            for line in obj_clean.splitlines():
                if line.startswith('DTSTART'):
                    parts = line.split(':', 1)
                    dtstart = parts[1].strip() if len(parts) > 1 else None
                elif line.startswith('RRULE:'):
                    rrule = line.split(':', 1)[1].strip()

            if not dtstart:
                continue

            time_part = None
            event_date = None
            if 'T' in dtstart:
                d_str, t_str = dtstart.split('T')
                try:
                    event_date = datetime.date(int(d_str[:4]), int(d_str[4:6]), int(d_str[6:8]))
                    time_part = datetime.time(int(t_str[:2]), int(t_str[2:4]))
                except Exception:
                    continue
            else:
                try:
                    event_date = datetime.date(int(dtstart[:4]), int(dtstart[4:6]), int(dtstart[6:8]))
                    time_part = datetime.time(0, 0)
                except Exception:
                    continue

            is_today = False
            if event_date == today_date:
                is_today = True
            elif rrule:
                if 'BYDAY=' in rrule and today_dow in rrule:
                    if 'UNTIL=' in rrule:
                        until_match = re.search(r'UNTIL=([0-9T]+)', rrule)
                        if until_match:
                            u = until_match.group(1)[:8]
                            try:
                                until_date = datetime.date(int(u[:4]), int(u[4:6]), int(u[6:8]))
                                if today_date <= until_date and today_date >= event_date:
                                    is_today = True
                            except Exception:
                                pass
                    else:
                        if today_date >= event_date:
                            is_today = True

            if is_today and time_part:
                events.append({
                    'summary': summary.strip(),
                    'time': time_part,
                    'meet': meet_url
                })

    # Deduplicate events
    unique_events = {}
    for ev in events:
        key = (ev['summary'].lower(), ev['time'])
        if key not in unique_events or (not unique_events[key]['meet'] and ev['meet']):
            unique_events[key] = ev

    events = sorted(unique_events.values(), key=lambda x: x['time'])

    # Find ONLY current and upcoming event
    current_ev = None
    upcoming_ev = None

    for ev in events:
        ev_dt = datetime.datetime.combine(today_date, ev['time'])
        diff_minutes = (ev_dt - now).total_seconds() / 60

        # Current event: started within last 45m and not yet finished
        if -45 <= diff_minutes <= 0 and not current_ev:
            current_ev = ev
        # Upcoming event: strictly in the future
        elif diff_minutes > 0 and not upcoming_ev:
            upcoming_ev = ev

    # 1. Top Panel Title (Current event takes priority, otherwise upcoming event)
    active_display = current_ev or upcoming_ev
    if active_display:
        t_str = active_display['time'].strftime('%H:%M')
        icon_b64 = B64_MEET if active_display['meet'] else B64_CALENDAR
        print(f"{t_str} {active_display['summary']} | image={icon_b64}")
    else:
        print(f"No Events | image={B64_CALENDAR}")

    print("---")

    # 2. Minimalist Dropdown: ONLY Current and Upcoming Event
    if not current_ev and not upcoming_ev:
        print("No more events scheduled for today | disabled=true")
    else:
        if current_ev:
            t_str = current_ev['time'].strftime('%H:%M')
            if current_ev['meet']:
                print(f"Join Now ({t_str}): {current_ev['summary']} | href={current_ev['meet']}")
            else:
                print(f"Current: {t_str} - {current_ev['summary']} | disabled=true")

        if upcoming_ev:
            t_str = upcoming_ev['time'].strftime('%H:%M')
            if upcoming_ev['meet']:
                print(f"Join Upcoming ({t_str}): {upcoming_ev['summary']} | href={upcoming_ev['meet']}")
            else:
                print(f"Upcoming: {t_str} - {upcoming_ev['summary']} | disabled=true")

    print("---")
    print("Open Calendar | shell=chromium param1=--app=https://calendar.google.com/calendar/u/0/r")

if __name__ == '__main__':
    main()
