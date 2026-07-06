pragma Singleton

import Quickshell

Singleton {
    property alias enabled: clock.enabled
    readonly property date date: clock.date
    readonly property int hours: clock.hours
    readonly property int minutes: clock.minutes
    readonly property int seconds: clock.seconds

    function format(fmt: string): string {
        return Qt.formatDateTime(clock.date, fmt);
    }

    readonly property var days: ["domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado"]
    readonly property var shortDays: ["dom", "lun", "mar", "mié", "jue", "vie", "sáb"]
    readonly property var months: ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"]

    function dayName(): string {
        return days[clock.date.getDay()]
    }

    function shortDayName(): string {
        return shortDays[clock.date.getDay()]
    }

    function monthName(): string {
        return months[clock.date.getMonth()]
    }

    function compactDate(): string {
        return `${shortDayName()} ${clock.date.getDate()}`
    }

    function longDate(): string {
        return `${dayName()}, ${monthName()} ${clock.date.getDate()}`
    }

    function longDateTime(): string {
        return `${monthName()} ${clock.date.getDate()}, ${clock.date.getFullYear()}  •  ${format("hh:mm")}`
    }

    function monthYear(): string {
        return `${monthName()} ${clock.date.getFullYear()}`
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
